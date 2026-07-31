#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
tmp_root="${TMPDIR:-/tmp}/fstack-validator-tests.$$"
fixture="$tmp_root/fstack fixture"

cleanup() {
  rm -rf "$tmp_root"
}

trap cleanup EXIT HUP INT TERM
umask 077
mkdir -p "$fixture/scripts" "$fixture/skills/fstack" "$fixture/skills/fstack-run"
cp "$root/scripts/validate.sh" "$fixture/scripts/validate.sh"

write_valid_fixture() {
  cat > "$fixture/README.md" <<'MARKDOWN'
`/fstack`
`/fstack-run`
MARKDOWN

  cat > "$fixture/skills/fstack/SKILL.md" <<'MARKDOWN'
---
name: fstack
description: Front door.
---
MARKDOWN

  cat > "$fixture/skills/fstack-run/SKILL.md" <<'MARKDOWN'
---
name: fstack-run
description: Continuous runner.
---
MARKDOWN
}

expect_failure() {
  expected=$1
  if sh "$fixture/scripts/validate.sh" > "$tmp_root/stdout" 2> "$tmp_root/stderr"; then
    printf 'ERROR: validator unexpectedly passed: %s\n' "$expected" >&2
    exit 1
  fi
  if ! grep -Fq "$expected" "$tmp_root/stderr"; then
    printf 'ERROR: validator failed without expected message: %s\n' "$expected" >&2
    cat "$tmp_root/stderr" >&2
    exit 1
  fi
}

write_valid_fixture
output=$(sh "$fixture/scripts/validate.sh")
if [ "$output" != 'Validated 2 skills.' ]; then
  printf 'ERROR: unexpected validator output: %s\n' "$output" >&2
  exit 1
fi

sed 's/name: fstack-run/name: wrong-name/' \
  "$fixture/skills/fstack-run/SKILL.md" > "$tmp_root/invalid-skill"
mv "$tmp_root/invalid-skill" "$fixture/skills/fstack-run/SKILL.md"
expect_failure 'declares name wrong-name but directory is fstack-run.'

write_valid_fixture
cat > "$fixture/README.md" <<'MARKDOWN'
`/fstack`
MARKDOWN
expect_failure 'README.md does not document /fstack-run.'

printf '%s\n' 'Validator tests passed.'
