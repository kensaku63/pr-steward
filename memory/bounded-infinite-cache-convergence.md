# Bounded infinite cache convergence

When a query represents a bounded window or a snapshot-scoped page chain, a realtime event must not be merged as though the cache were a complete list.

- Append a newly created row directly only when the cached window is known to include the relevant live edge. If an anchored window has an `after` boundary, invalidate or refetch instead of jumping over unknown rows.
- Replacing an infinite query with a new initial page silently discards loaded depth. Rebuild the same depth with cursors from the new snapshot, then atomically replace the chain.
- Never retain old pages while attaching a new snapshot's cursor. Preserving visible content and preserving cursor validity are separate requirements; use a focused-item projection when the new initial page does not include the item the user is reading.
- Apply the same completeness rule to WebSocket events, optimistic sends, and HTTP success handlers. Separate implementations drift quickly.

This pattern is reusable for conversations, threads, feeds, and any cursor-paginated cache where the client does not know the omitted interval.
