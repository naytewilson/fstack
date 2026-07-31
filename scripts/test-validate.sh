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

  mkdir -p "$fixture/.cursor/skills" "$fixture/scripts"
  cat > "$fixture/.cursor/environment.json" <<'JSON'
{
  "install": "sh scripts/install-cursor-cloud-skills.sh"
}
JSON
  cp "$root/scripts/install-cursor-cloud-skills.sh" \
    "$fixture/scripts/install-cursor-cloud-skills.sh"
  ln -sfn ../../skills/fstack "$fixture/.cursor/skills/fstack"
  ln -sfn ../../skills/fstack-run "$fixture/.cursor/skills/fstack-run"
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

write_valid_fixture
rm -f "$fixture/.cursor/skills/fstack-run"
expect_failure '.cursor/skills/fstack-run does not resolve to SKILL.md.'

write_valid_fixture
rm -f "$fixture/.cursor/environment.json"
expect_failure 'missing .cursor/environment.json for Cursor cloud skill install.'

write_valid_fixture
install_dest="$tmp_root/cursor-skills-home"
CURSOR_CLOUD_SKILLS_HOME="$install_dest" \
  sh "$fixture/scripts/install-cursor-cloud-skills.sh" > "$tmp_root/install-out"
if [ ! -f "$install_dest/fstack/SKILL.md" ] || [ ! -f "$install_dest/fstack-run/SKILL.md" ]; then
  printf 'ERROR: install-cursor-cloud-skills.sh did not copy skills.\n' >&2
  exit 1
fi
if grep -Fq 'local-path:' "$install_dest/fstack-run/SKILL.md"; then
  printf 'ERROR: install script must copy skills without installer metadata.\n' >&2
  exit 1
fi

printf '%s\n' 'Validator tests passed.'
