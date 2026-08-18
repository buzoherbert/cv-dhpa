#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${1:-.}"
cd "$SRC_DIR"

echo "Building PDFs with Tectonic..."
$RUN_BUILD

targets=$(grep -A1 '^\[\[output\]\]' Tectonic.toml | grep '^name' | sed -E 's/name = "(.*)"/\1/')

for name in $targets; do
	BUILT_PATH="build/$name/$name.pdf"
	COMMITTED_PATH="docs/$name.pdf"

	if [ ! -f "$BUILT_PATH" ]; then
		echo "❌ Error: $BUILT_PATH not found!"
		exit 1
	fi

	if [ ! -f "$COMMITTED_PATH" ]; then
		echo "❌ Error: $COMMITTED_PATH not found!"
		exit 1
	fi

	TMP=$(mktemp -d)
	pdftoppm -r 150 -png "$BUILT_PATH" "$TMP/built"
	pdftoppm -r 150 -png "$COMMITTED_PATH" "$TMP/committed"

	MISMATCH=0
	built_pages=("$TMP"/built-*.png)
	committed_pages=("$TMP"/committed-*.png)

	if [ "${#built_pages[@]}" -ne "${#committed_pages[@]}" ]; then
		MISMATCH=1
		echo "❌ Page count differs: built=${#built_pages[@]} committed=${#committed_pages[@]}"
	else
		for built_page in "${built_pages[@]}"; do
			page_num=$(basename "$built_page" | sed 's/built-//;s/.png//')
			committed_page="$TMP/committed-${page_num}.png"
			if [ ! -f "$committed_page" ]; then
				MISMATCH=1
				echo "❌ Page $page_num missing in committed."
				continue
			fi
			ae=$(compare -metric AE "$built_page" "$committed_page" null: 2>&1 >/dev/null | grep -oE '^[0-9]+' || echo "0")
			if [ "$ae" != "0" ]; then
				MISMATCH=1
				echo "❌ Page $page_num differs."
			fi
		done
	fi

	rm -rf "$TMP"

	if [ "$MISMATCH" -eq 1 ]; then
		echo "❌ $name visual mismatch!"
		echo "   Built:     $BUILT_PATH"
		echo "   Committed: $COMMITTED_PATH"
		echo ""
		echo "   Run 'nix run .#build' locally and commit the updated PDFs to docs./"
		exit 1
	fi
	echo "✅ $name matches"
done

echo "✅ All PDFs match"
