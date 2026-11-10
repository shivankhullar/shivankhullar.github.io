#!/bin/bash
# Preview the website locally before pushing.
#
# Usage:  scripts/preview.sh
# Then open http://localhost:1313/ — pages reload automatically as you edit
# files. Press Ctrl+C in this terminal to stop.
#
# Uses the SAME Hugo version as the live site (read from
# .github/workflows/publish.yaml). This matters: this theme renders several pages
# (Research, Publications) incorrectly under newer Hugo releases, so a preview
# built with Homebrew's latest Hugo does not match what goes live.
#
# On first run, that Hugo version is downloaded from the official GitHub release,
# checked against the release's published SHA-256 checksum, and kept in
# ~/Library/Caches/hugo-<version>/. Your Homebrew Hugo is left alone.
#
# Nothing is published: this only serves the site on your own machine. Draft
# and future-dated pages are shown too, so you can check them before they go live.

set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(sed -nE "s/^[[:space:]]*WC_HUGO_VERSION:[[:space:]]*'?([0-9.]+)'?.*/\1/p" .github/workflows/publish.yaml)
if [[ -z "$VERSION" ]]; then
  echo "Could not read WC_HUGO_VERSION from .github/workflows/publish.yaml" >&2
  exit 1
fi

CACHE="$HOME/Library/Caches/hugo-$VERSION"
HUGO="$CACHE/hugo"

if [[ ! -x "$HUGO" ]]; then
  echo "Downloading Hugo $VERSION (same version as the live site)..."
  mkdir -p "$CACHE"
  base="https://github.com/gohugoio/hugo/releases/download/v$VERSION"
  file="hugo_extended_${VERSION}_darwin-universal.tar.gz"
  curl -fSL --progress-bar -o "$CACHE/$file" "$base/$file"
  curl -fsSL -o "$CACHE/checksums.txt" "$base/hugo_${VERSION}_checksums.txt"
  want=$(awk -v f="$file" '$2 == f {print $1}' "$CACHE/checksums.txt")
  got=$(shasum -a 256 "$CACHE/$file" | awk '{print $1}')
  if [[ -z "$want" || "$want" != "$got" ]]; then
    echo "Checksum mismatch for $file — not using it." >&2
    rm -f "$CACHE/$file"
    exit 1
  fi
  tar -xzf "$CACHE/$file" -C "$CACHE" hugo
  rm -f "$CACHE/$file"
  echo "Hugo $VERSION ready."
fi

"$HUGO" version
( sleep 3 && open "http://localhost:1313/" ) &
exec "$HUGO" server \
  --port 1313 \
  --buildDrafts --buildFuture \
  --disableFastRender
