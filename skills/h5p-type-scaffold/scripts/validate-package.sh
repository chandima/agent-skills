#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: validate-package.sh [options]

Validate an unpacked H5P package directory against the intended upload flow.

Options:
  --mode MODE      Validation mode: library-install | content-import
                   (default: library-install)
  --dir PATH       Unpacked package directory to validate (default: .)
  --help           Show help
USAGE
}

MODE="library-install"
PACKAGE_DIR="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"; shift 2 ;;
    --dir)
      PACKAGE_DIR="$2"; shift 2 ;;
    --help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$MODE" != "library-install" && "$MODE" != "content-import" ]]; then
  echo "Invalid --mode '$MODE'. Expected library-install or content-import." >&2
  exit 1
fi

if [[ ! -d "$PACKAGE_DIR" ]]; then
  echo "Directory does not exist: $PACKAGE_DIR" >&2
  exit 1
fi

if [[ "$MODE" == "library-install" ]]; then
  if [[ ! -f "$PACKAGE_DIR/library.json" ]]; then
    echo "library-install mode requires library.json at package root." >&2
    exit 1
  fi

  if [[ -f "$PACKAGE_DIR/h5p.json" ]]; then
    echo "library-install mode should not include h5p.json at package root." >&2
    exit 1
  fi

  if [[ -d "$PACKAGE_DIR/content" ]]; then
    echo "library-install mode should not include content/ at package root." >&2
    exit 1
  fi

  echo "OK: library-install layout is valid."
  exit 0
fi

if [[ ! -f "$PACKAGE_DIR/h5p.json" ]]; then
  echo "content-import mode requires h5p.json at package root." >&2
  exit 1
fi

if [[ ! -f "$PACKAGE_DIR/content/content.json" ]]; then
  echo "content-import mode requires content/content.json." >&2
  exit 1
fi

python - <<'PY' "$PACKAGE_DIR/h5p.json" "$PACKAGE_DIR/content/content.json"
import json
import sys

h5p_json_path = sys.argv[1]
content_json_path = sys.argv[2]

def fail(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)

try:
    with open(h5p_json_path, "r", encoding="utf-8") as f:
        h5p = json.load(f)
except Exception as exc:
    fail(f"Invalid JSON in h5p.json: {exc}")

try:
    with open(content_json_path, "r", encoding="utf-8") as f:
        json.load(f)
except Exception as exc:
    fail(f"Invalid JSON in content/content.json: {exc}")

required_scalar = ["title", "mainLibrary", "license"]
missing = [k for k in required_scalar if not h5p.get(k)]
if missing:
    fail(f"h5p.json missing required field(s): {', '.join(missing)}")

deps_key = None
for candidate in ("preloadedDependencies", "preloadDependencies"):
    if candidate in h5p:
        deps_key = candidate
        break

if deps_key is None:
    fail("h5p.json missing required field: preloadedDependencies (or preloadDependencies)")

deps = h5p[deps_key]
if not isinstance(deps, list):
    fail(f"h5p.json field {deps_key} must be an array.")

for idx, dep in enumerate(deps):
    if not isinstance(dep, dict):
        fail(f"h5p.json {deps_key}[{idx}] must be an object.")
    for key in ("machineName", "majorVersion", "minorVersion"):
        if key not in dep:
            fail(f"h5p.json {deps_key}[{idx}] missing '{key}'.")

print("OK: content-import layout is valid.")
PY
