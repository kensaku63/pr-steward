# Idempotent replay after mutable validation failure

## Reusable lesson

An accepted-response preflight before a mutable remote check is necessary but not sufficient for replay safety.

If a concurrent request has acquired the idempotency advisory lock but has not committed yet, an unlocked preflight cannot see its accepted row. When the remote check then fails, an immediate unlocked replay query can also miss the same winner and incorrectly return the transient validation error.

## Safe ordering

1. Build the canonical idempotency identity before remote validation.
2. Run a short unlocked replay preflight so already committed retries skip remote I/O.
3. For a request that still appears new, perform remote validation without holding a DB transaction or advisory lock.
4. On validation failure, acquire the same idempotency advisory lock used by acceptance writers, then re-read the authoritative replay row.
5. Return the accepted response if the concurrent writer committed; return the original validation error only if no accepted row exists after the writer committed or rolled back.
6. Keep the writer-side locked replay check before insertion as the final race guard.

## Review and test guidance

- Check both the already-committed retry and the uncommitted concurrent-winner boundary.
- A deterministic race test should coordinate the writer lock/commit and verifier failure rather than relying on timing sleeps.
- Confirm that no external I/O occurs while the DB transaction or advisory lock is held.
- Confirm that the same nonce with a different canonical hash still returns the existing conflict response.

This pattern applies whenever idempotent acceptance competes with mutable authorization, availability, or existence checks.

## External side effects before acceptance

The same ordering rule applies to storage uploads, message sends, and other external side effects. A replay preflight must happen before the side effect; otherwise an already accepted retry can fail only because the external dependency is currently unavailable, or can repeat a non-transactional effect.

For concurrent requests using the same nonce, serialize before the first external side effect when duplicate effects are not acceptable. After acquiring the nonce lock, re-read the authoritative replay row and return it before touching the external dependency. Keep canonical actor/hash mismatch checks on every replay path so the shortcut cannot weaken idempotency identity validation.

## Small-pool transaction trap

Do not call a helper that reacquires a pooled connection while an acceptance transaction already owns the only connection. This can self-deadlock with a pool size of one even when the SQL is otherwise correct. Provide a transaction-aware helper or register the derived row directly through the existing transaction, and add a pool-size-one regression test for the full route.
