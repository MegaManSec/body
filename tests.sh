#!/bin/bash
set -euo pipefail

body=$(cd "$(dirname "$0")" && pwd)/body
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
cd "$test_dir"

expect() {
  local expected=$1 actual
  shift
  actual=$("$body" --color=never "$@")
  if [ "$actual" != "$expected" ]; then
    printf 'FAIL: %s\nExpected: %q\nActual:   %q\n' "$*" "$expected" "$actual" >&2
    exit 1
  fi
}

printf 'one\ntwo\nthree\nfour\n' > file

# Filenames must remain literal in both output modes.
for name in "$test_dir/absolute" 'a&b' 'a|b' 'a\b' $'a\nb' 'x|;e touch injected;#'; do
  cp file "$name"
  expect "$name:2:two"$'\nfile:2:two' "$name" file
  expect "$name:two"$'\nfile:two' -n "$name" file
done
[ ! -e injected ]
