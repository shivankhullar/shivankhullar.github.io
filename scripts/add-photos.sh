#!/bin/bash
# Copy photos into the website's Photography gallery, shrunk to a web-friendly size.
#
# Usage (from anywhere):
#   scripts/add-photos.sh ~/Pictures/IMG_1234.JPG ~/Pictures/IMG_5678.HEIC ...
#
# For each photo, using macOS's built-in `sips` (the originals are never modified):
#   - JPG, PNG, TIFF and iPhone HEIC files are all accepted and saved as JPEG;
#   - the longest side is shrunk to at most 3200 px (never enlarged), quality 88,
#     typically 1.5-3 MB instead of 5-30 MB;
#   - colours are converted to sRGB (iPhones shoot in Display P3, which would
#     otherwise look washed out once the website re-encodes the photo);
#   - GPS position and other camera metadata are removed from the copy (this
#     repository is public), keeping only orientation, date and a copyright tag.
# Files are named by the date the photo was taken (2024-07-21-img-3151.jpg).
#
# The script then prints a caption entry for each photo, with the month/year it
# was taken (and its GPS position, if the camera recorded one, to help you name
# the place). Paste these under `resources:` in content/photography/_index.md.

set -euo pipefail

MAX_EDGE=3200
QUALITY=88
SRGB="/System/Library/ColorSync/Profiles/sRGB Profile.icc"
NOTICE="Copyright Shivan Khullar. All rights reserved."
SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
DEST="$SCRIPTS/../content/photography"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 photo1.jpg [photo2.heic ...]" >&2
  exit 1
fi

mkdir -p "$DEST"
stubs=""

for src in "$@"; do
  if [[ ! -f "$src" ]]; then
    echo "skip: $src (not found)" >&2
    continue
  fi
  name=$(basename "$src")
  base=$(printf '%s' "${name%.*}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')

  # Date taken (Spotlight metadata works for HEIC too); fall back to the file's date.
  taken=$(mdls -raw -name kMDItemContentCreationDate "$src" 2>/dev/null || true)
  [[ "$taken" == "(null)" || -z "$taken" ]] && taken=$(date -r "$src" '+%Y-%m-%d %H:%M:%S')
  day=${taken:0:10}
  out="$DEST/${day}-${base}.jpg"

  args=(--matchTo "$SRGB" --setProperty format jpeg --setProperty formatOptions "$QUALITY")
  w=$(sips -g pixelWidth "$src" | awk '/pixelWidth/ {print $2}')
  h=$(sips -g pixelHeight "$src" | awk '/pixelHeight/ {print $2}')
  if (( w > MAX_EDGE || h > MAX_EDGE )); then
    args+=(--resampleHeightWidthMax "$MAX_EDGE")
  fi
  sips "${args[@]}" "$src" --out "$out" >/dev/null
  # The repo is public: remove GPS and other personal metadata from the copy.
  python3 "$SCRIPTS/clean-exif.py" "$NOTICE" "$out"

  printf '%-36s %6s -> %6s  %s\n' "$name" \
    "$(du -h "$src" | cut -f1)" "$(du -h "$out" | cut -f1)" "$(basename "$out")"

  month=$(date -j -f '%Y-%m-%d' "$day" '+%B %Y' 2>/dev/null || echo "$day")
  lat=$(mdls -raw -name kMDItemLatitude "$src" 2>/dev/null || true)
  lon=$(mdls -raw -name kMDItemLongitude "$src" 2>/dev/null || true)
  gps=""
  if [[ -n "$lat" && "$lat" != "(null)" ]]; then
    gps=$(printf '   # GPS %.4f, %.4f' "$lat" "$lon")
  fi
  stubs+="  - src: $(basename "$out")"$'\n'"    title: PLACE${gps}"$'\n'"    params: { taken: $month }"$'\n'
done

if [[ -n "$stubs" ]]; then
  echo
  echo "Caption entries for content/photography/_index.md (replace PLACE):"
  printf '%s' "$stubs"
fi
