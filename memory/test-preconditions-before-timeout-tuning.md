# Check test preconditions before attributing timeouts to load

Observed during a Rust/Web delivery session, 2026-09-05:

- Several runtime tests timed out waiting for their first outbound prompt. An isolated rerun failed too. Their shared mocked accepted response omitted a newly required summary field, so deserialization failed before the awaited action. Updating the common fixture fixed all affected tests without changing production behavior or timeouts.
- A DB projection regression that directly switches an existing row's delivery state must also maintain the schema's delivered timestamp and error invariants. Inspect the complete constraint set before writing the fixture; do not discover each constraint through another expensive full-suite run. Exercise the corrected test alone before repeating the required gate.
- A shell test running `cd ... && pwd` inherited CDPATH and received two output lines. Remove CDPATH in the test process when the assertion requires one canonical directory; do not alter production shell behavior to accommodate the fixture.

For a timeout, inspect the path to the awaited event: request/response decoding, required fields, fixture setup, and earlier failure exits. Treat shared failures as a possible common precondition error. Classify load sensitivity only from actual rerun evidence. Keep original failures in the audit and never weaken assertions or thresholds merely to obtain a pass.

For expensive suites, preserve the gate's package/feature selection when running focused filters where practical, so diagnostic reruns reuse the same build artifacts. Confirm actual executed test counts; a filtered zero-test success is not evidence.
