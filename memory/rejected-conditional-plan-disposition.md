# Rejected conditional plan disposition

When issue dispositions depend on a conditional integrated design, they must be reconciled again after the human architecture decision. If the human rejects the design, do not leave issues as `accepted` or `superseded` merely because the conditional plan would have resolved them.

- Keep independently invalid or out-of-scope issues `rejected`.
- Move factually valid issues that will not be handled by the current PR to `deferred`.
- Remove `superseded` when the accepted design change that would have absorbed the issue was itself rejected.
- Record both the pre-answer conditional conservation and the final conservation so the transition remains auditable.
- Do not launch a partial implementation from the locally safe pieces when the rejected architecture is necessary for the PR's minimum value.

After an answer such as “redesign or withdraw,” re-read live GitHub state before creating a follow-up Ask or mutating the PR. If the PR is already closed, treat that external state as the withdrawal outcome, record who did and did not perform the operation, and do not create a redundant close Ask. A future redesign requires a separately approved scope and a fresh review package against the then-current base and head.
