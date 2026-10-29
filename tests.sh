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

expect_failure() {
  if "$body" "$@" > actual 2> error; then
    printf 'Expected failure: %s\n' "$*" >&2
    exit 1
  fi
  [ -s error ]
}

# An error must survive later successes and empty files.
expect_failure missing
expect_failure missing file
[ "$(cat actual)" = 'file:2:two' ]
expect_failure file missing
expect_failure missing empty
cp file unreadable
chmod 000 unreadable
if [ ! -r unreadable ]; then
  expect_failure unreadable
fi
chmod 600 unreadable

# Detect counting failures and failures in the first stage of a pipeline.
mkdir bin
cat > bin/awk <<'SH'
#!/bin/sh
echo 'forced counting failure' >&2
exit 1
SH
chmod +x bin/awk
PATH="$test_dir/bin:$PATH" expect_failure file
rm bin/awk
cat > bin/sed <<'SH'
#!/bin/sh
case $1 in
  N\;*) exec "$REAL_SED" "$@" ;;
esac
echo 'forced extraction failure' >&2
exit 1
SH
chmod +x bin/sed
REAL_SED=$(command -v sed) PATH="$test_dir/bin:$PATH" expect_failure file
PATH="$test_dir/bin:$PATH" expect_failure -n file

# Leading zeros are decimal in every context option and argument form.
printf '%s\n' {1..30} > many
expect "$(printf '%s\n' {15..25})" -n -A010 many
expect "$(printf '%s\n' {15..23})" -n -A=08 many
expect "$(printf '%s\n' {7..15})" -n -B 08 many
expect "$(printf '%s\n' {7..23})" -n -C0008 many
expect '15' -n -C000 many
for option in -A -B -C; do
  expect_failure "$option"
  expect_failure "${option}-1" many
  expect_failure "${option}1.5" many
done
