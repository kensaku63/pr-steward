# URL-backed filter state and responsive ownership

## When to reuse this lesson

Use these checks when reviewing a client-side search, filter, or sort UI whose durable state is encoded in the URL, especially when the same results have separate desktop and mobile presentations.

## Review invariants

- Treat the URL as one authority. Each interaction must compose onto the latest live URL, not a render-time query snapshot that may be stale while navigation is pending.
- Preserve unrelated query parameters and the hash when rewriting owned parameters.
- Encode multi-select values as opaque elements. Repeated query parameters are safer than a delimiter grammar unless the value contract explicitly forbids that delimiter.
- Keep selection independent from current availability. A selected value that no longer exists must remain visible and removable and should produce an empty result, not silently broaden the result set.
- Omit or explain controls whose available and selected option sets are both empty.
- Verify rapid consecutive actions, back and forward navigation, reload and shared URLs, IME input, clearing, and values containing punctuation.

## Responsive ownership

CSS visibility does not prevent hidden React trees from mounting, rendering, or subscribing. If rows contain reactive or expensive content, choose the active responsive representation before mapping rows so only one tree owns those effects. Keep filter and sort semantics and identifying metadata shared across representations, and verify capability parity on narrow and wide layouts.

## Projection completeness

When a table replaces a grouped or partitioned catalog view, check every authoritative partition, including distinguished root records, before accepting a new flatten helper. A helper test should cover both a normal mixed catalog and a catalog containing only the distinguished record.

## Evidence boundary

Component tests can prove branch ownership and URL composition, but keyboard, IME, history navigation, layout, and device behavior remain `UNMEASURED` until exercised in a real browser or device.
