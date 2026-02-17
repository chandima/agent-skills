#!/usr/bin/env bash
set -euo pipefail

# H5P library packager
#
# Creates a .h5p zip file from a built library directory, applying .h5pignore
# rules and omitting directory entries from the archive. Directory entries
# (e.g. "dist/", "language/") cause upload failures on strict validators such
# as the Drupal 11.x H5P 2.0.0 module which rejects entries without an
# allowed file extension.

usage() {
  cat <<'USAGE'
Usage: pack.sh [options]

Create a .h5p zip from a built H5P library directory.

Options:
  --dir PATH       Library directory to pack (default: .)
  --out FILE       Output .h5p file path (default: <machineName>.h5p in cwd)
  --strict         Fail if any file lacks an allowed H5P extension
  --help           Show help

Notes:
  - Reads .h5pignore in the library directory for exclusions.
  - Omits directory entries from the zip to avoid strict-validator rejections
    (e.g. Drupal 11.x H5P 2.0.0 beta).
USAGE
}

ALLOWED_EXT_RE='\.(json|png|jpe?g|gif|bmp|tiff?|svg|eot|ttf|woff2?|otf|webm|mp4|vtt|ogg|mp3|txt|pdf|rtf|docx?|xlsx?|pptx?|odt|ods|odp|xml|csv|diff|patch|swf|md|textile|wav|js|css)$'

LIB_DIR="."
OUT_PATH=""
STRICT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      LIB_DIR="$2"; shift 2 ;;
    --out)
      OUT_PATH="$2"; shift 2 ;;
    --strict)
      STRICT=1; shift ;;
    --help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$LIB_DIR" ]]; then
  echo "Directory does not exist: $LIB_DIR" >&2
  exit 1
fi

if [[ ! -f "$LIB_DIR/library.json" ]]; then
  echo "No library.json found in $LIB_DIR. Is this an H5P library?" >&2
  exit 1
fi

# Determine output path from machineName if not provided
if [[ -z "$OUT_PATH" ]]; then
  MACHINE=$(python3 -c "
import json, sys
with open('$LIB_DIR/library.json') as f:
    print(json.load(f).get('machineName', 'library'))
")
  OUT_PATH="${MACHINE}.h5p"
fi

# Build find exclude arguments from .h5pignore
FIND_EXCLUDES=()
if [[ -f "$LIB_DIR/.h5pignore" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip blank lines and comments
    line="${line%%#*}"
    line="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    FIND_EXCLUDES+=( -not -path "./${line}" -not -path "./${line}/*" )
  done < "$LIB_DIR/.h5pignore"
fi

# Collect files (not directories) respecting .h5pignore
TMP_FILELIST="$(mktemp)"
trap 'rm -f "$TMP_FILELIST"' EXIT

(
  cd "$LIB_DIR"
  find . -type f "${FIND_EXCLUDES[@]}" | sed 's|^\./||' | sort > "$TMP_FILELIST"
)

# Remove hidden files (dotfiles) that shouldn't be in the package
grep -v '^\.' "$TMP_FILELIST" | grep -v '/\.' > "${TMP_FILELIST}.clean" || true
mv "${TMP_FILELIST}.clean" "$TMP_FILELIST"

FILE_COUNT=$(wc -l < "$TMP_FILELIST" | tr -d ' ')
if [[ "$FILE_COUNT" -eq 0 ]]; then
  echo "No files to pack after applying .h5pignore exclusions." >&2
  exit 1
fi

# Check for files without allowed extensions
BAD_FILES=()
while IFS= read -r fpath; do
  if ! echo "$fpath" | grep -Eiq "$ALLOWED_EXT_RE"; then
    BAD_FILES+=("$fpath")
  fi
done < "$TMP_FILELIST"

if [[ ${#BAD_FILES[@]} -gt 0 ]]; then
  echo "Warning: The following files lack an allowed H5P extension:" >&2
  printf '  %s\n' "${BAD_FILES[@]}" >&2
  if [[ "$STRICT" -eq 1 ]]; then
    echo "Aborting due to --strict mode." >&2
    exit 1
  fi
  echo "These may be rejected by strict validators (e.g. Drupal 11.x H5P 2.0.0)." >&2
fi

# Create zip without directory entries (-D flag)
OUT_ABS="$(cd "$(dirname "$OUT_PATH")" 2>/dev/null && pwd)/$(basename "$OUT_PATH")"
(
  cd "$LIB_DIR"
  # Remove existing output if present
  rm -f "$OUT_ABS"
  # -D: do not create directory entries
  # -X: do not store extra file attributes
  cat "$TMP_FILELIST" | zip -D -X -@ "$OUT_ABS" > /dev/null
)

echo "Packed $FILE_COUNT file(s) into $OUT_PATH"
echo "No directory entries included (safe for Drupal 11.x H5P 2.0.0+)."
