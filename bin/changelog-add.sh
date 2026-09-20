#!/usr/bin/env bash
# Adds one entry to a section of the Unreleased part of CHANGELOG.md.
# When the section exists the entry goes to the top of its list. When
# it does not, the section is created before the first heading that
# follows `## [Unreleased]`.
#
# Usage: bin/changelog-add.sh <section> <entry>
#
#   bin/changelog-add.sh Changed "tzdata 2026d."
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "usage: bin/changelog-add.sh <section> <entry>" >&2
  exit 2
fi

section="$1"
entry="- $2"
root="$(cd "$(dirname "$0")/.." && pwd)"
changelog="$root/CHANGELOG.md"

if ! grep -q '^## \[Unreleased\]$' "$changelog"; then
  echo "error: $changelog has no ## [Unreleased] heading" >&2
  exit 1
fi

# Whether the Unreleased part already has the section.
has_section() {
  awk -v heading="### $section" '
    /^## \[Unreleased\]$/ { unreleased = 1; next }
    /^## / { unreleased = 0 }
    unreleased && $0 == heading { found = 1 }
    END { exit !found }
  ' "$changelog"
}

updated="$(mktemp)"
if has_section; then
  awk -v heading="### $section" -v entry="$entry" '
    /^## \[Unreleased\]$/ { unreleased = 1 }
    /^## / && !/Unreleased/ { unreleased = 0 }
    { print }
    unreleased && $0 == heading {
      getline blank
      print blank
      print entry
    }
  ' "$changelog" > "$updated"
else
  awk -v heading="### $section" -v entry="$entry" '
    /^## \[Unreleased\]$/ { unreleased = 1; print; next }
    unreleased && /^##/ {
      print heading "\n\n" entry "\n"
      unreleased = 0
    }
    { print }
    END { if (unreleased) print "\n" heading "\n\n" entry }
  ' "$changelog" > "$updated"
fi
mv "$updated" "$changelog"
