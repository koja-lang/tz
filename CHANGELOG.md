# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The version follows the IANA tz database release, so `2026.4.0` carries tzdata
`2026d`.

## [2026.5.0] - 2026-10-02

### Changed

- tzdata 2026e.

## [2026.4.0] - 2026-09-23

Requires Koja 0.19.

### Changed

- tzdata 2026d.

### Added

- `TZ.zone` builds a `TimeZone.Named` for an IANA identifier, resolving links
  such as `US/Central` to their target's rules.
- `TZ.identifiers` lists every zone and link in the release.
- `TZ.IANA_VERSION` reports the tzdata release in code.
- `koja run tz.generate` and `bin/update-tzdata.sh` rebuild `src/data/` from
  an IANA release.
