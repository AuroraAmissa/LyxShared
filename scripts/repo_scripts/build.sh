#!/bin/sh
cd "$(realpath "$(dirname "$0")")/.." || exit 1
nix run .?submodules=1#build
