## Participants

- amkisko

## Decisions

- Relock phoenix_live_view on the library mix.lock to 1.2.11 so CVE-2026-64941 / GHSA-36m4-rm57-3prf is patched on the 1.2 line.
- Keep example apps on the 1.1 line. Floor those mix.exs files to ~> 1.1.33 and pin mix.lock at 1.1.33.
- Do not unconstrained-update example graphs onto 1.2. An earlier free update jumped 1.1.27 to 1.2.11.
- mix hex.audit on the library after the LiveView bump reported no retired packages and exit 0. cowlib remains 2.19.0, the latest published Hex version. A later pass added hex ignore_advisories for CVE-2026-43969, CVE-2026-43971, CVE-2026-43966 and the EEF-CVE IDs CI printed.
- Unused Dependabot npm and docker ecosystems were dropped where they appeared on the Elixir library.

## Effects

- Library mix.lock: phoenix_live_view 1.2.11, phoenix 1.8.13, phoenix_pubsub 2.3.0.
- Example mix.lock files pin phoenix_live_view 1.1.33.
- CHANGELOG.md was not given an Unreleased bullet. This is a lockfile advisory refresh, not a public library contract change.

## Source

- usr/docs/issues/20260907141000_engineering-and-dependency-audit.md
- usr/docs/dependencies/20260907141000_phoenix-live-view-cve-2026-64941.md
