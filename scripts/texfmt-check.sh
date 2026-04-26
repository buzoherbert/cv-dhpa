#!/usr/bin/env bash
set -euo pipefail

dir="${1:-.}"
failed=0

echo "Checking TeX formatting..."
while IFS= read -r f; do
	echo "Checking $f..."
	if ! tex-fmt --check "$f" 2>&1; then
		echo "❌ $f is not formatted, run 'fmt' to fix"
		failed=1
	fi
done < <(find "$dir" -name "*.tex" -not -path "*/.*")

if [ "$failed" -eq 1 ]; then
	echo "TeX formatting check failed."
	exit 1
fi

[ -n "${out:-}" ] && touch "$out"
