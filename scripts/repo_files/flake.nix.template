{
    description = "nix build script for tabletop games";

    inputs = {
        nixpkgs = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "08b9151ed40350725eb40b1fe96b0b86304a654b";
        };
        flake-utils = {
            type = "github";
            owner = "numtide";
            repo = "flake-utils";
            rev = "b1d9ab70662946ef0850d488da1c9019f3a9752a";
        };
    };

    outputs = { self, nixpkgs, flake-utils }: import ./RulebookShared {
        inherit self nixpkgs flake-utils;
        local = import ./local.nix { inherit self nixpkgs flake-utils; };
    };
}
