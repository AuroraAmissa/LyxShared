#!/bin/sh
cd "$(realpath "$(dirname "$0")")/.." || exit 1

echo "Updating git submodules..."
git submodule update --init || exit 1
echo

echo "Setting up git hooks..."
git config --local core.hooksPath RulebookShared/hooks || exit 1
echo

echo "Setup lfs"
git lfs pull || exit 1
echo
