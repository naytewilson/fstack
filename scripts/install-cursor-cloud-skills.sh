#!/bin/sh
# Install fstack skills into the Cursor Cloud Agent home path so they persist
# across cloud sessions that reuse this environment.
#
# Idempotent: safe to re-run from .cursor/environment.json install.
# Canonical skills stay in skills/; this only copies into ~/.cursor/skills.

set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
src="$root/skills"
dest="${CURSOR_CLOUD_SKILLS_HOME:-${HOME}/.cursor/skills}"

if [ ! -d "$src" ]; then
  printf '%s\n' "ERROR: missing skills directory: $src" >&2
  exit 1
fi

mkdir -p "$dest"

installed=0
for skill_dir in "$src"/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    printf '%s\n' "skip $name (no SKILL.md)"
    continue
  fi
  rm -rf "$dest/$name"
  cp -R "$skill_dir" "$dest/$name"
  installed=$((installed + 1))
  printf '%s\n' "installed $name -> $dest/$name"
done

if [ "$installed" -eq 0 ]; then
  printf '%s\n' 'ERROR: no skills installed.' >&2
  exit 1
fi

printf '%s\n' "Installed $installed Cursor cloud skill(s) into $dest."
