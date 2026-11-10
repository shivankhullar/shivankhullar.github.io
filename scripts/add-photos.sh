#!/bin/bash
# Shrink DSLR photos and copy them into the website's Photography gallery.
#
# Usage (from anywhere):
#   scripts/add-photos.sh ~/Pictures/DSLR/IMG_1234.JPG ~/Pictures/DSLR/IMG_5678.JPG ...
#
# Each photo is resized so its longest side is at most 3000 px and saved as a
# JPEG at quality 85 (typically 1-2 MB instead of 10-30 MB), using macOS's
# built-in `sips`. The originals are never modified. The website then makes its
# own smaller WebP copies for visitors when it is built.
#
# Files are numbered in the order given (01-, 02-, ...) continuing after the
# photos already in the gallery, which sets their order on the page. Rename
# them afterwards to reorder.

set -euo pipefail

MAX_EDGE=3000
QUALITY=85
DEST="$(cd "$(dirname "$0")/.." && pwd)/content/photography"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 photo1.jpg [photo2.jpg ...]" >&2
  exit 1
fi

mkdir -p "$DEST"

# Continue numbering after the highest existing NN- prefix (10# = read "08" as decimal).
last=$(ls "$DEST" 2>/dev/null | grep -oE '^[0-9]+' | sort -n | tail -1 || true)
n=$((10#${last:-0}))

for src in "$@"; do
  if [[ ! -f "$src" ]]; then
    echo "skip: $src (not found)" >&2
    continue
  fi
  n=$((n + 1))
  name=$(basename "$src")
  base=$(printf '%s' "${name%.*}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
  out="$DEST/$(printf '%02d' "$n")-${base}.jpg"

  # Only shrink, never enlarge.
  w=$(sips -g pixelWidth "$src" | awk '/pixelWidth/ {print $2}')
  h=$(sips -g pixelHeight "$src" | awk '/pixelHeight/ {print $2}')
  if (( w > MAX_EDGE || h > MAX_EDGE )); then
    sips --resampleHeightWidthMax "$MAX_EDGE" --setProperty format jpeg \
         --setProperty formatOptions "$QUALITY" "$src" --out "$out" >/dev/null
  else
    sips --setProperty format jpeg --setProperty formatOptions "$QUALITY" \
         "$src" --out "$out" >/dev/null
  fi

  printf '%-40s %6s -> %6s  %s\n' "$name" \
    "$(du -h "$src" | cut -f1)" "$(du -h "$out" | cut -f1)" "$(basename "$out")"
done
