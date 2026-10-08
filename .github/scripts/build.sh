#!/usr/bin/env bash
set -euo pipefail

fonts="$(typst fonts)"
for family in 'Times New Roman' 'Songti SC' 'Heiti SC' 'Kaiti SC'; do
  if ! grep -Fxq "$family" <<< "$fonts"; then
    echo "::error::缺少字体：$family"
    exit 1
  fi
done

mkdir -p dist
diagnostics="$(mktemp)"
trap 'rm -f "$diagnostics"' EXIT
for kind in design thesis; do
  output=dist/main.pdf
  if [[ "$kind" == thesis ]]; then output=dist/main-thesis.pdf; fi
  if ! typst compile --root . --input ntu-platform=darwin --input "kind=$kind" \
    .github/ci.typ "$output" 2> "$diagnostics"; then
    cat "$diagnostics" >&2
    exit 1
  fi
  if [[ -s "$diagnostics" ]]; then
    cat "$diagnostics" >&2
    echo '::error::编译存在警告，停止发布。'
    exit 1
  fi
done
