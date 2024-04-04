#!/bin/sh

cd "$(realpath "$(dirname "$0")")/.." || exit 1

if [ "$#" -ne 1 ]; then
    TARGET="draft"
else
    TARGET="$1"
fi

nix run .?submodules=1#build_"$TARGET"
