#!/usr/bin/env bash
set -euo pipefail

dir="${1:-.}"
failed=0

echo "Checking Nix formatting..."
while IFS= read -r f; do
  echo "Checking $f..."
  if ! nixfmt --check "$f" 2>&1; then
    echo "❌ $f is not formatted, run 'nix fmt' to fix"
    failed=1
  fi
done < <(find "$dir" -name "*.nix" -not -path "*/.*")

if [ "$failed" -eq 1 ]; then
  echo "Nix formatting check failed."
  exit 1
fi

[ -n "${out:-}" ] && touch "$out"