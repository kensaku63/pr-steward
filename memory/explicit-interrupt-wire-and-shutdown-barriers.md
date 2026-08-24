# Explicit interrupt needs wire and shutdown barriers

When reviewing a bounded interrupt or replacement-turn change, verify the whole interval from command acceptance to child exit. A deadline branch in an outer `select` is not evidence of bounded convergence by itself.

## Review invariants

1. A lazy request future is not a sent frame. If an interrupt command can already be queued when the turn runner starts, require a real prompt-write completion barrier before the matching cancel notification is consumed. Reordering biased `select` branches is insufficient when the request write can be pending on a lock, write, or flush.
2. The absolute interrupt deadline must remain pollable inside nested inbound handling. If the selected branch awaits HTTP, filesystem, permission, or transport work inline, that await can suspend the outer deadline. Race post-interrupt inbound work against the same prompt response and absolute deadline; do not add operation-specific timeout policies.
3. A prompt response-channel close after cancel is not cooperative completion. With a pending replacement, transport loss must use the explicit failure path and must not construct the next turn on the broken transport.
4. Deadline expiry is not bounded convergence if cleanup precedes child shutdown. Backpressured dispatcher drains or ACK emission can keep the old process alive after the deadline. For explicit interruption, start bounded child shutdown before nonessential queue cleanup, then terminalize the exact old turn.
5. Persisted actionable failure text must survive projection. When runtime facts select a generic warning such as unconfirmed shutdown, preserve the canonical message that says whether the replacement ran, whether the workspace remains, and how to recover.

## Simplicity boundary

Keep these fixes inside the existing transport, turn-runner, shutdown-sequence, terminal, and view-projection owners. Prefer a private request write/response-wait split, one existing absolute deadline, and ordering changes. Do not introduce durable state, retry machinery, workers, a second source of truth, or a caller-visible protocol solely to close these races.
