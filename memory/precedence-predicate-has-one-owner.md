# A precedence predicate must have exactly one owner

When a PR introduces a new intermediate state — "stopped but not yet terminal", "queued but not yet claimed", "reserved but not yet delivered" — it also introduces a question that several components must now answer the same way: *may this thing still proceed?* Reviewers usually report the resulting bugs one site at a time, as a missing guard. Planning should not accept that framing before enumerating every place that already answers the same question.

The recognizable shape is that the correct answer already exists somewhere in the diff. In PR #1125 the same "may this Workflow Attempt still accept a continuation?" question was written three times: the session terminal path checked four precedence facts and was right; the wait settle path checked three and missed access revocation; the repair worker's candidate query checked none and permanently excluded the very rows that needed converging. Only one of the three sites produced a reported symptom, but all three were the same defect.

How to plan it:

- Grep for each fact the correct site reads (`terminal_outcome`, `completion_intent`, `access_revoke_reason`, `cancel_requested_at`) and list every query that reads *any* of them. Sites that read a proper subset are the drift.
- Pick the site with the most complete predicate as the existing authority. Extract it as one shared SQL const or helper and apply it at the other sites. This removes concepts instead of adding a guard, so it stays inside a `none` simplicity budget.
- Split the predicate along ownership, not along convenience. Facts owned by the same rows (attempt/run precedence) belong in the shared const; facts each site already owns locally (its own session liveness, its own transition target) stay local. Forcing all of it into one const makes the const wrong at one of the call sites.
- Check the exclusion filters, not just the accept checks. A worker that *skips* rows expresses the same predicate inverted, and a too-broad skip turns a latency optimization into a permanent stall. This one is easy to miss because it produces silence, not an error.

Related trap: removing a too-broad exclusion outright looks like the smaller fix, but it can reintroduce the cost the exclusion was added for — periodic no-op passes, redundant change events. Correcting the exclusion's predicate keeps both properties, and correcting is a smaller diff than removing plus compensating.

Related: [[approved-scope-acceptance-outranks-review-remedy]]
