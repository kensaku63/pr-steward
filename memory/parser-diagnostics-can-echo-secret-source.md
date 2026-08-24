# Parser diagnostics can echo secret source

## Risk

secret-bearing owner-local config を parse する library error は、値を明示的に format していなくても source excerpt や入力行を `Display` に含めることがある。その error を CLI、Session log、bootstrap failure、server report へそのまま連結すると、「provider value は表示しない」という局所確認だけでは redaction contract を満たせない。

## Review and fix pattern

- secret-bearing parser error の実際の `Display` を malformed fixture で確認する。
- parse/load boundary で raw error を bounded category に変換し、source text、path、provider stdout/stderr を上位 caller へ渡さない。
- CLI だけでなく、prepare log、durable failure record、network report まで propagation path を監査する。
- regression test は sentinel secret が各 user-visible / durable output に不在であることを直接 assert する。
