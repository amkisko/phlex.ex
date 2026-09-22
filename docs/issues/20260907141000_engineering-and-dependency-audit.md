Recorded 2026-09-07. Elixir library. CI mix hex.audit failed on phoenix_live_view 1.2.8. Library mix.lock now pins 1.2.11. Example apps on the 1.1 line pin 1.1.33.

## Participants

- amkisko

## Decisions

- Patch LiveView on the line each lock already used. Library stays on 1.2.11. Examples stay on 1.1.33.
- mix hex.audit after the library bump exited 0 with no retired packages. A later pass added mix.exs hex ignore_advisories for the three cowlib IDs CI still names on 2.19.0.

## Effects

- Library mix.lock pins phoenix_live_view 1.2.11.
- Example mix.exs files declare ~> 1.1.33.
- mix.exs lists EEF-CVE-2026-43969, EEF-CVE-2026-43971, EEF-CVE-2026-43966 and the CVE aliases under hex ignore_advisories.

## Next

- When Hex publishes cowlib past 2.19.0, bump the lock and drop ignore IDs that no longer match.

## Source

- usr/docs/changelogs/20260907141000_live-view-advisory-refresh.md
- usr/docs/dependencies/20260907141000_phoenix-live-view-cve-2026-64941.md
