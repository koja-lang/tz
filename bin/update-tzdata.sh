#!/usr/bin/env bash
# Moves the package to one IANA tzdata release. Downloads the release,
# compiles it with zic into build/tzdata/, runs `koja run tz.generate`
# to rewrite src/data/, and formats the result.
#
# Usage: bin/update-tzdata.sh [release]
#
#   bin/update-tzdata.sh 2026c    one named release
#   bin/update-tzdata.sh latest   whatever IANA publishes as newest
#   bin/update-tzdata.sh          same as latest
#
# Needs curl, tar, awk, zic, and koja. macOS ships zic in /usr/sbin,
# and Debian and Ubuntu carry it in libc-bin.
set -euo pipefail

release="${1:-latest}"
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/build/tzdata"
source="$out/source"
releases="https://data.iana.org/time-zones/releases"

# The main data files, as the tz Makefile's TDATA lists them. The
# `factory` placeholder zone is left out.
data_files=(africa antarctica asia australasia europe northamerica
  southamerica etcetera backward)

rm -rf "$out"
mkdir -p "$source"

# IANA keeps `tzdata-latest.tar.gz` pointing at the newest release and
# every release carries its name in a one-line `version` file, so the
# alias tarball is both the lookup and the download.
if [ "$release" = "latest" ]; then
  url="https://data.iana.org/time-zones/tzdata-latest.tar.gz"
else
  url="$releases/tzdata${release}.tar.gz"
fi

echo "fetching $url"
curl -fsSL "$url" -o "$out/tzdata.tar.gz"
tar -xzf "$out/tzdata.tar.gz" -C "$source"

version="$(tr -d '[:space:]' < "$source/version")"
if [ "$release" != "latest" ] && [ "$version" != "$release" ]; then
  echo "error: asked for tzdata $release but the tarball says $version" >&2
  exit 1
fi
echo "tzdata $version"

# Reproduce the Makefile's two awk passes. ziguard.awk normalizes the
# source form and zishrink.awk writes the compact tzdata.zi, one line
# per zone, rule, and link.
(
  cd "$source"
  LC_ALL=C awk -v DATAFORM=main -v PACKRATDATA='' -v PACKRATLIST='' \
    -f ziguard.awk "${data_files[@]}" > main.zi
  LC_ALL=C awk -v dataform=main -v deps='' -v redo='' -v version="$version" \
    -f zishrink.awk main.zi > tzdata.zi
)

# Slim output carries transitions up to the last rule change and
# leaves the future to the POSIX rule in the footer.
zic -b slim -d "$out/zoneinfo" "$source/tzdata.zi"

cp "$source/tzdata.zi" "$out/tzdata.zi"
printf '%s\n' "$version" > "$out/version"
echo "compiled tzdata $version into $out"

cd "$root"
koja run tz.generate
koja format src/data > /dev/null
echo "src/data is at tzdata $version"
