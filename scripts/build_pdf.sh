#!/usr/bin/env bash

set -euo pipefail

input_file="${1:-index.md}"
output_file="${2:-build/cv.pdf}"

if [[ ! -f "$input_file" ]]; then
  echo "Input Markdown file not found: $input_file" >&2
  exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
  echo "pandoc is required to build the PDF" >&2
  exit 1
fi

if ! command -v xelatex >/dev/null 2>&1; then
  echo "xelatex is required to build the PDF" >&2
  exit 1
fi

if ! command -v pdfinfo >/dev/null 2>&1; then
  echo "pdfinfo is required to validate the PDF" >&2
  exit 1
fi

if ! command -v pdftotext >/dev/null 2>&1; then
  echo "pdftotext is required to validate the PDF" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_file")"

pandoc "$input_file" \
  --output="$output_file" \
  --pdf-engine=xelatex \
  --highlight-style=tango \
  --include-in-header="$(dirname "$0")/cv-header.tex" \
  -V geometry:margin=0.72in \
  -V fontsize=10pt \
  -V mainfont="Noto Sans" \
  -V monofont="Noto Sans Mono"

if [[ ! -s "$output_file" ]]; then
  echo "PDF was not generated: $output_file" >&2
  exit 1
fi

pdfinfo "$output_file" >/dev/null

text_file="$(mktemp)"
trap 'rm -f "$text_file"' EXIT
pdftotext "$output_file" "$text_file"

grep -q "Maksym Shaposhnikov" "$text_file"
grep -qi "DevOps" "$text_file"

echo "Generated and validated $output_file"
