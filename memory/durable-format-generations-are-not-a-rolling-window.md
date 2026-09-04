# Durable format generations are not a rolling window

Code that reconstructs an artifact from a stored hash — a rendered prompt, a signed payload, a canonical serialization — often keeps "current" plus "the one before it". That structure is a trap: it reads as a compatibility mechanism, but it only holds while exactly two generations have ever been accepted. The next change to the text silently drops the oldest generation, and rows written before it become unreadable with an internal error.

The tell is a helper named `legacy_*` (singular) plus a two-branch reconstruction that tries legacy, then current. When a PR edits the current text, check whether it also overwrote the legacy body with the previous current. If it did, one whole generation just lost its renderer.

How to establish the real generation count: `git log -S` the distinguishing sentence of the current text to find when it landed, then read that commit's message and diff. A commit that introduced the legacy helper usually says outright that it exists for stored-hash compatibility, which both confirms the intent and dates the boundary. Every generation from the first one onward is potentially still in the database; row age, not code age, decides reachability.

The fix is to replace "current + legacy" with "current + a finite ordered list of known past generations", and to have reconstruction pick the generation whose hash matches. This usually *reduces* branching, adds no persistent state, and needs no migration. Rejected alternative: persisting the rendered text as a new column — that creates a second source of truth and a migration for a problem the renderer can still solve.

Guard the recurrence with fixed fixtures, not generated ones. Assert each generation's full literal text and its literal sha256 hex. A test that derives the expectation from the same mutable helper it is testing passes right through the regression that matters.
