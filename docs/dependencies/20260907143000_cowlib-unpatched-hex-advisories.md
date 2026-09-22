## Dependency

- cowlib 2.19.0 (latest Hex release as of 2026-09-07)
- Transitive through cowboy and Phoenix HTTP stacks
- mix.lock pin remains 2.19.0

## Symptom

CI mix hex.audit fails on Hex 2.5 advisory checks for cowlib 2.19.0. Local mix hex.audit that only checks retired packages can still exit 0.

## Evidence

- Hex package page lists advisories on 2.19.0, including cookie header injection from 2.9.0 onward with no later patched release.
- CI logs named EEF-CVE-2026-43969, EEF-CVE-2026-43971, and EEF-CVE-2026-43966.
- CVE-2026-43969 is the cookie encoder injection case. Affected from cowlib 2.9.0 onward. No published Hex version past 2.19.0.

## Suggested fix

- mix.exs project hex ignore_advisories lists EEF-CVE-2026-43969, EEF-CVE-2026-43971, EEF-CVE-2026-43966 and the CVE aliases. Hex matches primary IDs and aliases. The dual list covers CI Hex 2.5 output and the CVE form in the public records.
- Do not continue-on-error the whole audit step. Do not ignore LiveView or other packages that already have a patched release.
- When Hex publishes cowlib past 2.19.0, bump the lock and drop IDs that no longer match.

## Next

- Watch Hex for a cowlib release past 2.19.0. Re-run mix hex.audit and remove stale ignore entries.

## Source

- https://hex.pm/packages/cowlib
- https://osv.dev/vulnerability/CVE-2026-43969
- usr/docs/issues/20260907141000_engineering-and-dependency-audit.md
