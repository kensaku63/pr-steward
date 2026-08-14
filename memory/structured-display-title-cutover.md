# Structured display title cutover

When a PR moves a display-title policy into a canonical persistence boundary, check two independent invariants before approving it.

First, generic prefix truncation can destroy a structured discriminator stored at the end of a title, such as a Workflow Step key. The producer that owns the structure should reserve the discriminator budget and pass a value that the persistence boundary recognizes as already canonical. Do not infer domain structure from an accidental delimiter in arbitrary user text.

Second, a one-shot title backfill does not establish a rolling-release invariant. If migrations run before a blue-green API promotion, N-1 writers can recreate invalid values after the backfill. The migration must make those commits impossible or fail closed, and the test should execute an N-1-shaped write after migration.

Historical normalization must use the same operation order as runtime normalization. In particular, collapse whitespace and decide blankness before measuring and truncating; otherwise the migration can discard meaningful content even though the normalized value fits.
