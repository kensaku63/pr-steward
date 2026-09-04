# Approved scope acceptance outranks a review remedy

A PR body that says "this behavior is accepted by the approved spec" is a claim about authority, not a defense to discount. Planning must verify it before treating a reviewer's finding as a defect, because the verification flips the disposition.

Verify three things separately, and record which ones stayed unconfirmed:

- The canonical spec text. Look for the exact behavior the reviewer flagged. A spec that names the symptom and then says it accepts it has already priced the tradeoff.
- The spec's change boundary. A spec that declares a surface out of scope and names the untouched paths makes any fix on that surface a scope expansion, not a completion.
- The approval itself. Authority lives in the answered human decision, not in the spec's `status` field, which often stays `draft` after implementation is approved. Check whether the decision enumerated this specific side effect. An accepted side effect that was listed as a decision point is settled.

Also confirm the PR's changed files match the spec's implementation plan. Exact agreement is strong evidence the PR stayed inside its approved boundary, and it moves the burden onto the reviewer's remedy instead.

When the claim holds, the finding is `deferred`, not `accepted`. The symptom can be real and evidence-validated while the remedy still belongs to the project that owns the specification. Re-opening a side effect a human explicitly accepted is a spec/UX decision, so it needs that project's approval path, not steward judgment. It is not a merge blocker.

Separate a correction from an addition when judging whether a doc or contract fix is in scope. If the PR made an existing statement wrong, fixing it is in scope. If the contract never addressed the area, adding guidance is a new addition and inherits the same scope question. Read the contract at the exact head before deciding which case applies; assuming it went stale is how an out-of-scope edit gets rationalized as a fix.

An approved plan with zero design changes is a valid planning outcome. Record the conservation, skip the implementation handoff, and report. Do not manufacture a change to justify the planning session.

Related: [[rejected-conditional-plan-disposition]]
