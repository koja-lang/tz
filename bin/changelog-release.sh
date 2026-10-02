#!/usr/bin/env bash
# Opens a new release section at the top of CHANGELOG.md with one
# entry, dated today. Refuses when the file has an `## [Unreleased]`
# heading, because that work needs a person to decide how it ships.
#
# Usage: bin/changelog-release.sh <version> <section> <entry>
#
#   bin/changelog-release.sh 2026.5.0 Changed "tzdata 2026e."
#
# writes
#
#   ## [2026.5.0] - 2026-10-01
#
#   ### Changed
#
#   - tzdata 2026e.
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: bin/changelog-release.sh <version> <section> <entry>" >&2
  exit 2
fi

version="$1"
section="$2"
entry="$3"
root="$(cd "$(dirname "$0")/.." && pwd)"
changelog="$root/CHANGELOG.md"

if grep -q '^## \[Unreleased\]$' "$changelog"; then
  echo "error: $changelog has unreleased work, release it before $version" >&2
  exit 1
fi

# The new section goes before the first release heading, or at the
# end when the file has none yet.
updated="$(mktemp)"
awk -v version="$version" -v date="$(date -u +%Y-%m-%d)" \
  -v section="$section" -v entry="$entry" '
  function heading() {
    return "## [" version "] - " date "\n\n### " section "\n\n- " entry
  }
  !done && /^## \[/ { print heading() "\n"; done = 1 }
  { print }
  END { if (!done) print "\n" heading() }
' "$changelog" > "$updated"
mv "$updated" "$changelog"
