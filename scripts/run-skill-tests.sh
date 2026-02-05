#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find "$ROOT_DIR/skills" -type f -path "*/tests/smoke.sh" | while read -r test; do
  echo "Running $test"
  bash "$test"
  echo
  done

echo "All skill smoke tests passed."
