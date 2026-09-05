# Wake hints preserve authority

Use an in-process notification only as a wake-up hint when a bounded request must observe durable state changes without timer polling.

- Subscribe before the initial authoritative read. This closes the read/subscribe race without making the channel authoritative.
- Carry only the identity needed to filter relevant updates, such as a Session ID or agent ID. Do not put a projected status, receipt, or lifecycle decision in the notification.
- Re-read the canonical DB row and current runtime/router snapshot after a relevant notification. On broadcast lag and at the common deadline, always perform a final authoritative read.
- Ignore unrelated identities without touching the DB. Query volume should follow relevant changes, not elapsed time.
- For a batch response, reclassify every target at the common return point. Do not freeze a reversible projection such as `offline` in the same slot as a durable terminal state while sibling targets are still pending.
- A missed notification may delay observation until the deadline, but must never change the returned truth. If correctness depends on reliable notification delivery, the notification has accidentally become a second source of truth.

Tests should cover subscribe-before-read convergence, unrelated-event filtering, lag/deadline final reads, and a mixed-target transition where an early provisional result changes while another target is still pending.
