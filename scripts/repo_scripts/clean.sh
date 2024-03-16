#!/bin/sh
cd "$(realpath "$(dirname "$0")")/.." || exit 1
rm -rfv dist
