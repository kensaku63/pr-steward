# Non-idempotent response boundary and final review convergence

## Classify mutation outcomes across the full response boundary

A client-side error does not prove that a non-idempotent mutation failed. Trace the server path through the durable commit or side-effect boundary and every fallible step after it. Post-commit hydration, serialization, notification, or response delivery can fail after the intended state already exists.

Use this audit sequence:

1. Locate the durable commit or externally visible side-effect boundary.
2. Inspect every fallible operation between that boundary and the completed client response.
3. Map transport and response failures separately, including post-connect network errors, HTTP 408/429/5xx responses, and successful-response decode failures.
4. If any mapped failure can occur after commit, classify the outcome as unknown and reconcile with a read-only authority before permitting another mutation.
5. Keep failures that prove the request was never sent as ordinary failures.
6. Do not add a nonce, deduplication store, retry protocol, or second authority unless that protocol change is explicitly approved.

Tests should cover both sides of the boundary: connect-before-send failure must remain an ordinary failure, while every response class that could follow a commit must enter reconciliation instead of blind retry.

## Final merge-blocker review converges on an exact HEAD

A final review verdict authorizes only the exact commit it inspected. If a fresh final reviewer finds a blocker:

1. Independently verify that the finding is factual and inside the approved scope.
2. Apply the minimum correction.
3. Rerun the affected focused checks and the required aggregate gates.
4. Commit the correction so the candidate has a new exact identity.
5. Run another genuinely fresh final reviewer against that new HEAD.

Only a no-blocker verdict on the final exact HEAD can authorize push. Earlier verdicts and test evidence do not automatically carry across a corrective commit. Keep failures, flakes, skipped checks, pending checks, and passes distinct in the final evidence.
