#!/usr/bin/env bash
set -euo pipefail

dir="${1:-.}"
failed=0

echo "Running spellcheck..."
while IFS= read -r f; do
	echo "Processing $f..."
	# Redirect stderr (2>/dev/null) to hide the kpathsea configuration warnings
	typos=$(
		grep -v '\\define' "$f" |
			sed 's/\\[a-zA-Z]*{[a-z][a-z]*}//g' |
			sed 's/[{}]/ /g' |
			sed '/\\usepackage/d; /\\RequirePackage/d; /\\documentclass/d; /\\input/d; /\\include/d' |
			detex 2>/dev/null |
			sed 's/\([a-z]\)\([A-Z][a-z]\)/\1 \2/g' |
			sed 's/[^ ]*[0-9][^ ]*//g' |
			hunspell -l -p "$dir/.spelling.pws" -d en_US
	)
	if [ -n "$typos" ]; then
		echo "❌ Spelling errors in $f:"
		echo "$typos" | sort -u | sed 's/^/  - /'
		failed=1
	fi
done < <(find "$dir" -name "*.tex" -not -path "*/.*")

if [ "$failed" -eq 1 ]; then
	echo "Spellcheck failed due to typos."
	exit 1
fi

[ -n "${out:-}" ] && touch "$out"
