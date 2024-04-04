#!/bin/sh -eu

# TODO: Make this shit significantly less hacky.

cd "$(realpath "$(dirname "$0")")/.."

if [ "$#" -ne 1 ]; then
    TARGET="draft"
else
    TARGET="$1"
fi

if test -n "$(git status --porcelain)"; then
    echo "(Repository is really dirty!)"
    touch isDirtyForReal
fi

RulebookShared/hooks/gitInfo2
cp -v .git/gitHeadInfo.gin gitHeadInfo.gin

touch dirtyrepohack

git add dirtyrepohack gitHeadInfo.gin
if [ -f isDirtyForReal ]; then
    git add isDirtyForReal
fi
nix run .?submodules=1#build_"$TARGET"

git rm -f dirtyrepohack gitHeadInfo.gin
if [ -f isDirtyForReal ]; then
    git rm -f isDirtyForReal
fi
