# TZ

[![CI](https://github.com/koja-lang/tz/actions/workflows/ci.yml/badge.svg)](https://github.com/koja-lang/tz/actions/workflows/ci.yml)
[![Last Updated](https://img.shields.io/github/last-commit/koja-lang/tz.svg)](https://github.com/koja-lang/tz/commits/main)

IANA time zone rules for [Koja](https://github.com/koja-lang/koja). The
standard library ships `TimeZone.UTC` and `TimeZone.Fixed`. This package adds
the named zones, `America/Chicago` and the rest, by embedding the
[tz database](https://www.iana.org/time-zones) and building a
`TimeZone.Named` value for an identifier.

## Installation

Add the package to `koja.toml` and run `koja deps get`:

```toml
[dependencies]
TZ = { github = "koja-lang/tz", tag = "2026.4.0" }
```

## Usage

```koja
alias TZ.zone

chicago = try zone("America/Chicago")

# An instant viewed in the zone.
now = DateTime.now(chicago)
IO.puts(now.to_string())

# A clock time placed in the zone. The result says whether the zone
# skipped or repeated that time, and `match` has to answer for both.
date = try Date.new(2026, 3, 8)
time = try Time.new(2, 30, 0)

meeting =
  match date.at(time).in_zone(chicago)
    TimeZone.Resolution.Unique(value) -> value
    TimeZone.Resolution.Gap(_, following) -> following
    TimeZone.Resolution.Ambiguous(earlier, _) -> earlier
  end
```

A zone value carries its whole transition table. Nothing consults this package
again after `zone` returns, so the value can be stored, sent to another
process, or compared like any other value.

`zone` fails with `TZ.Error.Unknown` for an identifier the release does not
have. `TZ.identifiers()` lists every identifier it accepts. A link such as
`US/Central` resolves to the rules of its target and keeps the name it was
asked for.

## Versions

The version follows the IANA release. `2026.4.0` carries tzdata `2026d`. The
first number is the year, the second is the release letter as a number, and
the third is a patch. A new release from IANA becomes a new minor version. The
patch changes for a fix to this package or a bump of the minimum Koja version.
`TZ.IANA_VERSION` reports the release in code.

There is no runtime download. A change to a zone's rules reaches your program
when you update the dependency. `koja deps outdated` tells you when a newer
tag exists.

## Updating the data

```sh
bin/update-tzdata.sh          # whatever IANA publishes as newest
bin/update-tzdata.sh 2026d    # one named release
```

The script downloads the release from IANA, compiles it with `zic`, runs
`koja run tz.generate` to rewrite `src/data/`, and formats the output. The
generator reads the TZif files, packs each zone into one string, and checks
that the string decodes back to the same rules. It needs `curl`, `tar`, `awk`,
`zic`, and `koja`. A daily workflow runs it when IANA publishes a release,
cuts the next version in `CHANGELOG.md` and `koja.toml`, and opens a pull
request with the result.

## License

MIT. The tz database itself is in the public domain.
