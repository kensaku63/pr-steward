# Typed JSON reads and comparison boundaries

Use when an opt-in historical comparison adds corruption handling to an existing typed DB reader, or when Rust and JavaScript disagree on JSON equality.

## Preserve the ordinary reader

`Json<T>` decodes directly into T. Replacing it with `Json<Value>` followed by `from_value` creates an intermediate tree and another traversal for every caller. Verify callers and the decoder in the pinned dependency before claiming a performance effect; the extra work is a code fact, while end-to-end latency remains unmeasured without a measurement.

A small boundary can keep one SELECT and the existing derived FromRow: fetch the raw row, decode it once into the typed row, and map only the intended column decode errors for the opt-in caller. SQLx 0.9.0 reports named ColumnDecode indexes in Debug form, including quotes such as `"definition"`. Verify the pinned implementation, exercise actual malformed values through DB/HTTP, and separately test that other columns, SQL and connection errors preserve their existing errors. Drop the raw row after decode rather than retaining its buffer across later awaits.

If serde defaults erase whether a field was present, retain the original persisted-presence predicate at its existing authority. An empty decoded value is not proof that legacy repair is required. A comparison-only SQL CASE can return a scalar flag without adding another JSON scan to the normal path; inspect both CASE evaluation paths and the query payload, rather than inferring cost from the flag alone.

## Validate historical containers at their authority

Prefer the existing container validator over a second path/size validator. Preserve the original file vector for response order and content bytes; a temporary validated container may sort internally. Reuse the same container for existing legacy derivation, and keep modern history free of current-schema recompilation or latest-version substitution.

Postgres jsonb rejects U+0000. A NUL test that cannot be persisted does not establish HTTP behavior: exercise the production validation helper in a unit test and use persistable invalid paths and exact capacity violations for DB/HTTP rejection. Keep these evidence scopes distinct.

## Keep numeric equality scoped

JSON has one number type, but serde_json distinguishes integer and float representations while JavaScript does not. If the approved comparison treats `1` and `1.0` as equal, use that rule consistently for both overall equality and changed entries. Preserve option presence, JSON types, array order, object key membership, and original left/right values.

Keep integer-to-integer equality exact. For mixed integer/float comparisons, check finite/integral values and the integer range before casting. The rounded upper endpoints 2^63 and 2^64 must be excluded; converting all numbers to f64 can collapse distinct integers. Test signed/unsigned boundaries, symmetry, negative/exponent representations, and source-bytes-changed/resolved-unchanged in shared fixtures. This local repair does not solve JavaScript's general large-integer precision or authorize a new wire/parser contract.
