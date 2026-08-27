#!/usr/bin/env bash
set -euo pipefail

echo "Clearing build directory."
rm -rf build/

targets=$(grep -A1 '^\[\[output\]\]' Tectonic.toml | grep '^name' | sed -E 's/name = "(.*)"/\1/')
for name in $targets; do
	echo "Building $name..."
	tectonic -X build --target "$name" "$@"
done
