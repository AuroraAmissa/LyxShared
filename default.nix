{ self, nixpkgs, flake-utils, local }:

flake-utils.lib.eachDefaultSystem (system:
    let
        pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import ./overlays.nix) ];
        };

        mk_build_script = kind: rec {
            pdf_derivation = pkgs.stdenv.mkDerivation {
                name = "${local.name}-pdf";
                src = ./..;
                buildInputs = [
                    pkgs.lyx
                    pkgs.texliveFull
                    pkgs.qpdf
                    pkgs.zip
                    pkgs.zstd
                ];
                buildPhase = ''
                    # Set up environment variables
                    export IS_REALLY_DIRTY=0
                    if [ -f isDirtyForReal ]; then
                        export IS_REALLY_DIRTY=1
                    fi
                    export DIRTY_SHORT_REV="${self.dirtyShortRev}"
                    export SOURCE_NAME="${local.sourceArcName}"
                    export DIST_NAME="${local.distArcName}"

                    # Set up repository properly
                    rm -vf dirtyrepohack isDirtyForReal
                    mkdir -vp .git
                    mv -v gitHeadInfo.gin .git

                    # Initialize build
                    . ${./build_pdfs.sh}
                    init_build "${kind}"

                    # Build source archive
                    create_source_archive "${local.sourceArcName}$ZIP_FILE_SUFFIX $ZVERSION"

                    # Build PDF documents
                    create_build_dirs
                    ${local.buildScripts}

                    # Build output archive
                    create_archive "${local.distArcName}$ZIP_FILE_SUFFIX $ZVERSION"
                '';
                installPhase = ''
                    mkdir -p $out
                    mv -v *.tar.zst $out
                    mv -v *.zip $out
                '';
            };

            link_cmd = if kind == "ci" then "cp -v" else "ln -sv";
            build_script = pkgs.writeScriptBin "${local.name}-build" ''
                #! ${pkgs.bash}/bin/bash
                mkdir -p dist
                ${link_cmd} "${pdf_derivation}"/* dist/
            '';
        };

        mk_build_app = kind: flake-utils.lib.mkApp {
            drv = (mk_build_script kind).build_script;
        };
    in {
        apps = rec {
            build_release = mk_build_app "release";
            build_playtest = mk_build_app "playtest";
            build_ci = mk_build_app "ci";
            build_draft = mk_build_app "draft";
        };
    }
)
