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

# Use the unique middle for odd counts and the lower middle for even counts.
printf 'one\ntwo\nthree\nfour\nfive\n' > odd
printf 'one\n' > single
expect '3:three' odd
expect $'2:two\n3:three\n4:four' -C1 odd
expect '2:two' file
expect '1:one' single

# Count a final record even when it has no newline.
printf 'one' > partial_single
printf 'one\ntwo\nthree\nfour\nfive' > partial
: > empty
expect '1:one' partial_single
expect '3:three' partial
expect $'1:one\n2:two\n3:three\n4:four\n5:five' -C10 partial
expect $'one\ntwo\nthree\nfour\nfive' -n -C10 partial
expect '' empty
