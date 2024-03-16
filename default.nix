{ self, nixpkgs, flake-utils, local }:

flake-utils.lib.eachDefaultSystem (system:
    let
        pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import ./overlays.nix) ];
        };

        mk_build_script = kind: rec {
            LuminousTheDream-pdf = pkgs.stdenv.mkDerivation {
                name = "LuminousTheDream-pdf";
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

                    # Set up repository properly
                    rm -v dirtyrepohack isDirtyForReal
                    mkdir -vp .git
                    mv -v gitHeadInfo.gin .git

                    # Initialize build
                    . ${./build_pdfs.sh}
                    init_build "${kind}"

                    # Build source archive
                    export SOURCE_NAME="${local.sourceArcName}"
                    create_source_archive "${local.sourceArcName}$ZIP_FILE_SUFFIX $ZVERSION"

                    # Build PDF documents
                    create_build_dirs
                    ${local.buildScripts}

                    # Build output archive
                    export DIST_NAME="${local.distArcName}"
                    create_archive "${local.distArcName}$ZIP_FILE_SUFFIX $ZVERSION"
                '';
                installPhase = ''
                    mkdir -p $out
                    mv -v *.tar.zst $out
                    mv -v *.zip $out
                '';
            };
            build_script = pkgs.writeScriptBin "build-script" ''
                #! ${pkgs.bash}/bin/bash
                echo "${LuminousTheDream-pdf}"
                ls "${LuminousTheDream-pdf}"
                tar tvf "${LuminousTheDream-pdf}"/*.tar.zst
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
