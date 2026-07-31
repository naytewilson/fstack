#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
names_file="${TMPDIR:-/tmp}/fstack-skill-names.$$"
files_file="${TMPDIR:-/tmp}/fstack-skill-files.$$"

cleanup() {
  rm -f "$names_file" "$files_file"
}

trap cleanup EXIT HUP INT TERM
: > "$names_file"
find "$root/skills" -type f -name SKILL.md -print | LC_ALL=C sort > "$files_file"

if [ ! -s "$files_file" ]; then
  printf '%s\n' 'ERROR: no skills/*/SKILL.md files found.' >&2
  exit 1
fi

failures=0
count=0

while IFS= read -r file; do
  count=$((count + 1))
  relative=${file#"$root/"}
  directory=$(basename "$(dirname "$file")")
  first_line=$(sed -n '1p' "$file")
  closing_line=$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$file")
  name=$(awk '
    NR == 1 { next }
    $0 == "---" { exit }
    /^name:[[:space:]]*/ {
      sub(/^name:[[:space:]]*/, "")
      print
      exit
    }
  ' "$file")
  description=$(awk '
    NR == 1 { next }
    $0 == "---" { exit }
    /^description:[[:space:]]*/ {
      sub(/^description:[[:space:]]*/, "")
      print
      exit
    }
  ' "$file")
  lines=$(wc -l < "$file" | tr -d ' ')

  if [ "$first_line" != '---' ] || [ -z "$closing_line" ]; then
    printf 'ERROR: %s must start with a closed YAML frontmatter block.\n' "$relative" >&2
    failures=$((failures + 1))
  fi

  if [ -z "$name" ]; then
    printf 'ERROR: %s is missing frontmatter name.\n' "$relative" >&2
    failures=$((failures + 1))
  elif ! printf '%s\n' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    printf 'ERROR: %s has invalid skill name: %s\n' "$relative" "$name" >&2
    failures=$((failures + 1))
  elif [ "$name" != "$directory" ]; then
    printf 'ERROR: %s declares name %s but directory is %s.\n' "$relative" "$name" "$directory" >&2
    failures=$((failures + 1))
  fi

  if [ -z "$description" ]; then
    printf 'ERROR: %s is missing frontmatter description.\n' "$relative" >&2
    failures=$((failures + 1))
  else
    description_bytes=$(LC_ALL=C printf '%s' "$description" | wc -c | tr -d ' ')
    if [ "$description_bytes" -gt 1024 ]; then
      printf 'ERROR: %s description exceeds 1024 bytes.\n' "$relative" >&2
      failures=$((failures + 1))
    fi
  fi

  if [ "$lines" -gt 500 ]; then
    printf 'ERROR: %s has %s lines; SKILL.md must stay at or below 500.\n' "$relative" "$lines" >&2
    failures=$((failures + 1))
  fi

  if [ -n "$name" ]; then
    if grep -Fxq "$name" "$names_file"; then
      printf 'ERROR: duplicate skill name: %s\n' "$name" >&2
      failures=$((failures + 1))
    else
      printf '%s\n' "$name" >> "$names_file"
    fi

    if ! grep -Fq "\`/$name\`" "$root/README.md"; then
      printf 'ERROR: README.md does not document /%s.\n' "$name" >&2
      failures=$((failures + 1))
    fi
  fi
done < "$files_file"

if [ "$failures" -ne 0 ]; then
  printf 'Validation failed: %s problem(s) across %s skill(s).\n' "$failures" "$count" >&2
  exit 1
fi

printf 'Validated %s skills.\n' "$count"
