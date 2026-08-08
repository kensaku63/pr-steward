# Persisted UI intent must be cleared at its authority

When reply or selection intent survives component remounts in a shared store, local React state is not evidence that the intent is absent. A component can remount with local `null` while the persisted store still routes the next submit to an old target.

- Put the routing identity needed for safety checks in the persisted intent itself, such as the canonical conversation root ID.
- On cross-root navigation, clear the canonical store entry directly. Clearing only local props/state may not trigger a child synchronization effect when those values already start as `null`.
- Preserve unrelated draft payload such as text, references, attachments, and the client nonce; clear only reply metadata.
- Avoid a second local root-ID state when the external reply object and persisted intent already contain the authority. Duplicate state hides restored-draft edges.
- Test the remount boundary: seed a persisted reply, mount with empty local state, switch to another root, and assert the persisted reply is gone while the draft remains.

This applies to composers and other durable UI intents whose visible component state is only a projection of a longer-lived store.
