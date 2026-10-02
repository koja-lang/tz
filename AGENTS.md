# Agent Guide

This is a [Koja](https://kojalang.org) project. Koja is a statically
typed, compiled language with Ruby-inspired syntax, value semantics,
and Erlang-style concurrency.

## This package

`TZ` builds `TimeZone.Named` values from the IANA tz database. The
public surface is `zone`, `identifiers`, `Error`, and `IANA_VERSION`
in `src/tz.koja`. Everything else is package-private.

`src/data/` is generated. Never edit it by hand. Run
`bin/update-tzdata.sh <release>` to move to a new IANA release. It
downloads the release, compiles it with `zic`, runs the
`tz.generate` task in `src/generate.koja`, and formats the output.
The packed text format is described at the top of `src/packed.koja`.

The version follows the IANA release, so `2026.4.0` is tzdata `2026d`.
`CHANGELOG.md` follows Keep a Changelog. A tzdata bump is a `Changed`
entry in a new release section, which `bin/changelog-release.sh`
writes for the daily workflow. The workflow fails while the file has
an `## [Unreleased]` heading, so release pending work before IANA
publishes, or expect the next run to stop and wait.

## Look up documentation

`koja doc <symbol>` prints the full doc for any stdlib or project
symbol, like `koja doc List.append`. `koja doc search <query>`
lists every symbol whose name or doc mentions the query.

The standard library sources are extracted to `~/.koja/stdlib/`,
one directory per compiler build. Read or grep them there when the
docs are not enough.

## Commands

Set `KOJA_DIAGNOSTICS=short` to print each diagnostic on one line.

- `koja check` type checks without compiling
- `koja test` runs `test "description"` blocks from `src/` and
  `test/`. `assert expr` fails the test when `expr` is false, and
  `fail "message"` fails it outright. Reaching `end` passes.
- `koja run` builds and executes the project
- `koja format` formats the project in place (`--check` to verify)

## Language essentials

- No `let`, `var`, `mut`, or semicolons. Assignment creates a
  variable, and blocks close with `end`.
- No `else if`. Use `cond` for multi-branch conditionals.
- Values never alias. A mutating function takes `self` and returns a
  new value, so rebind the result: `list = list.append(42)`.
- `-> T ! E` declares a fallible function. `try expr` unwraps or
  propagates the error, `fail e` returns an error, and
  `expr rescue e -> handler` handles it inline.
- Files in one package share a namespace. Same-package code needs no
  imports. Use `alias Pkg.Type` to shorten external package paths.
