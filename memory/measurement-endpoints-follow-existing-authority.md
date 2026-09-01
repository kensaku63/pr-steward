# Measurement endpoints follow existing authority

Performance instrumentation must observe an existing product lifecycle; it must not become the authority that defines navigation, acceptance, visibility, or privacy.

## Put each endpoint at the owner of the fact

- Start route-transition timing at the framework's global transition hook when one exists. Per-Link or per-button calls make coverage depend on UI placement and turn cancellation, supersede, and history navigation into a multi-caller protocol.
- Complete data readiness only after the existing loading/error owner admits a renderable state. Empty loaded data is a valid terminal; scroll anchors and content existence are not fetch-readiness authorities.
- Treat accepted server response identity as the authority when HTTP and realtime signals can arrive in either order. Absorb ordering inside the existing bounded pending observation, then resolve only the identity confirmed by the accepted response. Do not introduce a launch nonce, durable rendezvous, or caller sequence requirement.
- Start realtime render timing only after the canonical projection owner accepts scope, identity, revision, and sequence, and only for the currently mounted projection. A raw transport event is not evidence that the UI will change. Background, stale, mismatched, ignored, and mount-only activity must not create or consume timing state.

When an internal owner already returns or can return its accept/reject result, expose that result narrowly to the instrumentation caller instead of copying its validation rules into the measurement module. The measurement module should own only bounded timestamps, matching, expiry, sampling, and once-only emission.

## Apply privacy at every SDK send path

Error events, transactions, spans, logs, and metrics may use distinct final callbacks even when they share one SDK initialization. Enabling a new telemetry event type requires checking the installed SDK types/source and registering the corresponding final-send privacy callback.

Reuse the existing scrub policy. Keep error-specific diagnostic identity in the error path, and apply event-type-specific removal only for fields that have no value for the new metric, such as inherited breadcrumbs, raw transaction URLs, or arbitrary span attributes. Do not rely on callsites omitting attributes: scope and integrations can add data later. Do not create a second allowlist or SDK-version fallback unless explicitly approved.

Tests should cover both semantics and the boundary:

1. global entry coverage, supersede, abandon, and loaded-empty completion;
2. both HTTP/realtime arrival orders plus unrelated identities and discard;
3. accepted-visible versus background/stale/rejected projection events and mount-only commits;
4. direct transaction/span callback fixtures containing raw URL, query, unknown scope data, breadcrumbs, and child span data, while retaining existing error-event behavior.
