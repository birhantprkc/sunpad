# Historical SunPad source snapshots

These patches reconstruct the earlier Preview 10/12 dependency sources and remain
available for downstream projects referencing the original donor snapshots.
Normal SunPad bootstrap no longer applies them. Runtime changes now belong in
maintained forks selected by pinned submodules.

See the [current source graph](../docs/DEPENDENCIES.md),
[migration record](../config/dependency-migration.json), and
[engineering review](../docs/UPSTREAM-REVIEW.md). The migration record maps each
snapshot hash to a source commit with upstream history intact. Apple and tvOS
retain separate source pins to preserve their different audio implementations.

For new work, run `scripts/bootstrap-dependencies.sh` in a fresh checkout. Do not
apply these historical snapshots to arbitrary fork revisions. The ARM64 fallback
repair credited to Douglas Whittingham in RecompCore PR #6 already exists in the
pinned ancestry. An unspecified JIT allegation is not a reason to apply it again.
