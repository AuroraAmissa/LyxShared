{ self, nixpkgs, flake-utils }:

flake-utils.lib.eachDefaultSystem (system:
    let
        pkgs = nixpkgs.legacyPackages.${system};
        build_script = pkgs.writeScriptBin "build-script" ''
            #! ${pkgs.nix}/bin/nix-shell
            #! nix-shell --pure -i bash -p bash
            #! nix-shell -I nixpkgs=${nixpkgs}
            echo "Hello, world!"
            env
        '';
    in {
        apps = rec {
            build = flake-utils.lib.mkApp { drv = build_script; };
        };
    }
)
