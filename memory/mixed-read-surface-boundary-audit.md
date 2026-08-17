# Mixed read surface boundary audit

When one CLI command exposes the same pagination or state fields across a new authoritative read path and a legacy path, review each branch for argument consumption and semantic parity. A flag that is parsed or echoed but ignored is a false bounded-read claim; reject it with an actionable error unless that branch has a real cursor and limit authority.

For submission tracking, do not derive terminality from submission rows and transcript messages alone. Delivery can succeed before result persistence fails, leaving only a user message while the Session lifecycle is already terminal. Terminal-state review should reconcile per-submission state, durable assistant completion, active-turn state, and Session lifecycle, with durable completion taking precedence over a broader Session failure.

Any bounded excerpt used as a decision fact must surface truncation as a machine-readable gap with an exact safe locator to the fuller source. An ellipsis is presentation, not completeness evidence.
