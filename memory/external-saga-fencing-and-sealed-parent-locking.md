# External saga fencing and sealed parent locking

## Reusable lesson

A DB lease is only proof that a runner is current at the instant the lease is checked. Refreshing it once per phase is insufficient when that phase can perform multiple external mutations.

For a resumable external saga:

1. Bound the manifest by entry count, per-entry bytes, and total bytes before starting remote writes.
2. Persist and hash the fixed manifest before creating or adopting the target.
3. Renew and fence the claim immediately before every remote mutation, including each blob/tree write and each commit/ref write. A stale runner may finish harmless reads, but it must not begin the next mutation or persist progress.
4. Fence every progress, error, receipt, and finalization write by claim token and generation. A completed operation must not regress.
5. Read the final remote identity and content back from the provider. A locally injected receipt does not verify provider sequencing or recovery behavior.

## Provider-boundary verification

Use a deterministic local provider fixture that records request method, path, order, and body. Cover at least:

- source branch movement after the source commit/tree was pinned;
- saved target identity mismatch without recreate;
- unexpected adopted target content with no mutation;
- stale claim before the first mutation and between successive mutations;
- final remote HEAD/tree mismatch after a ref update.

Database tests that directly insert the expected receipt are useful for finalization constraints, but they cannot replace these provider-path tests.

## Sealed snapshot concurrency

A child trigger that merely reads `parent.sealed_at` has a check-then-commit race: a child transaction can observe unsealed state, another transaction can seal and commit, and the child can commit afterward.

The child mutation must lock every affected parent row before checking its sealed state. For updates that can move a child between parents, lock old and new parent rows in a deterministic identifier order. A DB-backed concurrency test should hold an in-flight child mutation, prove sealing waits, then prove sealing proceeds only after that child transaction commits. Sequential post-seal rejection tests alone do not establish this invariant.
