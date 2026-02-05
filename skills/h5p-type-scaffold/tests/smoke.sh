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

if [[ ! -f "$CONTENT_DIR/README.md" ]]; then
  echo "Missing content README.md" >&2
  exit 1
fi

if [[ ! -f "$CONTENT_DIR/DEV.md" ]]; then
  echo "Missing content DEV.md" >&2
  exit 1
fi

if rg -q '__[A-Z_]+' "$CONTENT_DIR"; then
  echo "Found unresolved template tokens in content output" >&2
  exit 1
fi

echo "Testing content template (vanilla)..."
bash "$SCRIPT_DIR/scripts/scaffold.sh" \
  --title "Smoke Vanilla" \
  --machine "H5P.SmokeVanilla" \
  --template vanilla \
  --out "$TMP_BASE" >/dev/null

VANILLA_DIR="$TMP_BASE/h5p-smoke-vanilla"

if [[ ! -f "$VANILLA_DIR/library.json" ]]; then
  echo "Missing vanilla library.json" >&2
  exit 1
fi

if ! rg -q '"runnable"\s*:\s*1' "$VANILLA_DIR/library.json"; then
  echo "Vanilla library.json should be runnable" >&2
  exit 1
fi

if [[ ! -f "$VANILLA_DIR/semantics.json" ]]; then
  echo "Missing vanilla semantics.json" >&2
  exit 1
fi

if [[ ! -f "$VANILLA_DIR/src/entries/h5p-smoke-vanilla.js" ]]; then
  echo "Missing vanilla entrypoint" >&2
  exit 1
fi

if [[ ! -f "$VANILLA_DIR/README.md" ]]; then
  echo "Missing vanilla README.md" >&2
  exit 1
fi

if [[ ! -f "$VANILLA_DIR/DEV.md" ]]; then
  echo "Missing vanilla DEV.md" >&2
  exit 1
fi

if rg -q '__[A-Z_]+' "$VANILLA_DIR"; then
  echo "Found unresolved template tokens in vanilla output" >&2
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

if [[ ! -f "$EDITOR_DIR/README.md" ]]; then
  echo "Missing editor README.md" >&2
  exit 1
fi

if [[ ! -f "$EDITOR_DIR/DEV.md" ]]; then
  echo "Missing editor DEV.md" >&2
  exit 1
fi

if rg -q '__[A-Z_]+' "$EDITOR_DIR"; then
  echo "Found unresolved template tokens in editor output" >&2
  exit 1
fi

if [[ ! -x "$SCRIPT_DIR/scripts/h5p-dev.sh" ]]; then
  echo "Missing or non-executable h5p-dev.sh helper" >&2
  exit 1
fi

echo "✓ Smoke tests passed"
