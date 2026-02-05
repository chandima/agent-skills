#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_BASE="/tmp/h5p-type-scaffold-smoke"

cleanup() {
  rm -rf "$TMP_BASE"
}
trap cleanup EXIT

mkdir -p "$TMP_BASE"

echo "=== Smoke Test: h5p-type-scaffold ==="

echo "Testing content template (default snordian)..."
bash "$SCRIPT_DIR/scripts/scaffold.sh" \
  --title "Smoke Content" \
  --machine "H5P.SmokeContent" \
  --out "$TMP_BASE" >/dev/null

CONTENT_DIR="$TMP_BASE/h5p-smoke-content"

if [[ ! -f "$CONTENT_DIR/library.json" ]]; then
  echo "Missing library.json" >&2
  exit 1
fi

if ! rg -q '"runnable"\s*:\s*1' "$CONTENT_DIR/library.json"; then
  echo "Content library.json should be runnable" >&2
  exit 1
fi

if [[ ! -f "$CONTENT_DIR/src/entries/dist.js" ]]; then
  echo "Missing snordian entrypoint" >&2
  exit 1
fi

if rg -q '__[A-Z_]+' "$CONTENT_DIR"; then
  echo "Found unresolved template tokens in content output" >&2
  exit 1
fi

echo "Testing editor template..."
bash "$SCRIPT_DIR/scripts/scaffold.sh" \
  --title "Smoke Editor" \
  --kind editor \
  --machine "H5PEditor.SmokeEditor" \
  --out "$TMP_BASE" >/dev/null

EDITOR_DIR="$TMP_BASE/h5peditor-smoke-editor"

if [[ ! -f "$EDITOR_DIR/library.json" ]]; then
  echo "Missing editor library.json" >&2
  exit 1
fi

if ! rg -q '"runnable"\s*:\s*0' "$EDITOR_DIR/library.json"; then
  echo "Editor library.json should be non-runnable" >&2
  exit 1
fi

if [[ ! -f "$EDITOR_DIR/src/entries/dist.js" ]]; then
  echo "Missing editor entrypoint" >&2
  exit 1
fi

if rg -q '__[A-Z_]+' "$EDITOR_DIR"; then
  echo "Found unresolved template tokens in editor output" >&2
  exit 1
fi

echo "✓ Smoke tests passed"
