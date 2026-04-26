#!/usr/bin/env bash
set -euo pipefail

echo "Formatting Nix files..."
while IFS= read -r f; do
  nixfmt "$f"
done < <(find . -name "*.nix" -not -path "*/.*")

echo "Formatting TeX files..."
while IFS= read -r f; do
  echo "Formatting $f..."
  tex-fmt "$f"
done < <(find . -name "*.tex" -not -path "*/.*")