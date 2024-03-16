#!/bin/sh

cd "$(realpath "$(dirname "$0")")/.." || exit 1

if [ "$#" -ne 1 ]; then
    TARGET="draft"
else
    TARGET="$1"
fi

if test -n "$(git status --porcelain)"; then
    echo "(Repository is really dirty!)"
    touch isDirtyForReal
fi

RulebookShared/hooks/gitInfo2 || exit 1
cp -v .git/gitHeadInfo.gin gitHeadInfo.gin || exit 1

touch dirtyrepohack || exit 1

git add dirtyrepohack gitHeadInfo.gin || exit 1
if [ -f isDirtyForReal ]; then
    git add isDirtyForReal || exit 1
fi
nix run .?submodules=1#build_"$TARGET"

git rm -f dirtyrepohack gitHeadInfo.gin
if [ -f isDirtyForReal ]; then
    git rm -f isDirtyForReal
fi
