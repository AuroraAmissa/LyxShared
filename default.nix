{ self, nixpkgs, flake-utils, local }:

flake-utils.lib.eachDefaultSystem (system:
    let
        pkgs = import nixpkgs {
            inherit system;
            overlays = [
                (self: super: {
                    lyx = super.lyx.overrideAttrs (oldAttrs: rec {
                        version = "2.4.0~RC3";
                        src = super.fetchurl {
                            url = "https://ftp.lip6.fr/pub/lyx/devel/lyx-2.4/lyx-${version}.tar.xz";
                            sha256 = "sha256-wwDG/ptMGo3c0v0w7GNvo7zTxCzzxP0bqs9WlTJJuPc=";
                        };
                    });
                })
            ];
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
                    # Extract information from git
                    export GIT_REV="${self.rev or self.dirtyRev or "0000000000000000000000000000000000000000"}"
                    export GIT_TIMESTAMP="${toString (self.lastModified or 0)}"
                    . ${./lib/git_info_from_nix.sh}

                    # Set up environment variables
                    export SOURCE_NAME="${local.sourceArcName}"
                    export DIST_NAME="${local.distArcName}"

                    # Initialize build
                    . ${./lib/build_pdfs.sh}
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

            link_cmd = if kind == "ci" then "cp -vf" else "ln -svf";
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
