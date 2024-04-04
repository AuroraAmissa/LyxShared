#!/bin/sh -eu

cd "$(realpath "$(dirname "$0")")/.."

echo "Updating git submodules..."
git submodule update --init
echo

echo "Setting up git hooks..."
git config --local core.hooksPath RulebookShared/hooks
echo

echo "Setup lfs"
git lfs pull
echo
