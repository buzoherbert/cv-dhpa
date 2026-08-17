#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${1:-.}"
cd "$SRC_DIR"

echo "Clearing build directory."
rm -rf build/

echo "Building PDFs with Tectonic..."
for name in Daniel_Palencia_CV Daniel_Palencia_Resume; do
  tectonic -X build --target "$name"
done

for name in Daniel_Palencia_CV Daniel_Palencia_Resume; do
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
    echo "   Run 'tectonic -X build' locally and commit the updated PDF to docs./"
    exit 1
  fi
  echo "✅ $name matches"
done

echo "✅ All PDFs match"