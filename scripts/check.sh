#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/check.sh

Read-only validation for the PR Steward agent repository.

Checks:
  - required agent assets exist
  - every skill has valid minimal frontmatter and a matching name
  - stable policy documents do not write PR-specific push counts to memory
  - secret handling is not classified as an automatic reject
  - tracked files have no whitespace errors

Output:
  stdout: one PASS line on success
  stderr: actionable validation failures

Exit:
  0: all checks passed
  1: one or more checks failed
EOF
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 0 ]]; then
  usage >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(dirname -- "$script_dir")
failures=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

required_files=(
  "README.md"
  "identity.md"
  "environment.yaml"
  "knowledge/aachat-review-doc-schema.md"
  "knowledge/github-pr-operations.md"
  "knowledge/human-approval-policy.md"
  "knowledge/review-priority-rubric.md"
  ".agents/skills/pr-checkout/SKILL.md"
  ".agents/skills/merge-value-gate/SKILL.md"
  ".agents/skills/parallel-pr-review/SKILL.md"
  ".agents/skills/review-issue-docs/SKILL.md"
  ".agents/skills/implementation-handoff/SKILL.md"
  ".agents/skills/final-merge-blocker-review/SKILL.md"
  ".agents/skills/pr-push-safety/SKILL.md"
)

for path in "${required_files[@]}"; do
  [[ -f "$repo_root/$path" ]] || fail "missing required file: $path"
done

while IFS= read -r reference; do
  relative_path=${reference#\$AA_AGENT_DIR/}
  [[ -e "$repo_root/$relative_path" ]] || fail "broken agent asset reference: $reference"
done < <(
  grep -R -h -o -E '\$AA_AGENT_DIR/[A-Za-z0-9._/-]+' \
    "$repo_root/README.md" "$repo_root/identity.md" "$repo_root/knowledge" "$repo_root/.agents/skills" \
    | sort -u
)

while IFS= read -r skill_dir; do
  skill_file="$skill_dir/SKILL.md"
  relative_file=${skill_file#"$repo_root/"}
  if [[ ! -f "$skill_file" ]]; then
    fail "skill directory has no SKILL.md: ${skill_dir#"$repo_root/"}"
    continue
  fi

  first_line=$(sed -n '1p' "$skill_file")
  frontmatter_end=$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$skill_file")
  declared_name=$(sed -n '2,8p' "$skill_file" | sed -n 's/^name:[[:space:]]*//p' | head -1)
  expected_name=$(basename -- "$skill_dir")

  [[ "$first_line" == "---" && -n "$frontmatter_end" ]] || fail "invalid frontmatter delimiters: $relative_file"
  [[ "$declared_name" == "$expected_name" ]] || fail "skill name mismatch in $relative_file: expected $expected_name"
  sed -n '2,8p' "$skill_file" | grep -q '^description:' || fail "missing description in $relative_file"
done < <(find "$repo_root/.agents/skills" -mindepth 1 -maxdepth 1 -type d | sort)

if find "$repo_root/memory" -maxdepth 1 -type f -name 'pr-*-push-count.md' | grep -q .; then
  fail "PR-specific push-count state must live in the Project audit record, not agent memory"
fi

if grep -R -n -F -e '回数は `$AA_AGENT_DIR/memory/` に記録' -e '回数を `$AA_AGENT_DIR/memory/` に記録' \
  "$repo_root/README.md" "$repo_root/identity.md" "$repo_root/knowledge" "$repo_root/.agents/skills" >/dev/null; then
  fail "stable policy still routes push counts to agent memory"
fi

if grep -n -F -e '例: secret 混入' -e '例: credential 混入' \
  "$repo_root/.agents/skills/merge-value-gate/SKILL.md" >/dev/null; then
  fail "merge-value gate still classifies secret detection as automatic reject"
fi

if [[ -d "$repo_root/.git" || -f "$repo_root/.git" ]]; then
  git -C "$repo_root" diff --check || fail "git diff --check reported whitespace errors"
fi

if (( failures > 0 )); then
  printf '%d check(s) failed.\n' "$failures" >&2
  exit 1
fi

printf 'PASS: PR Steward agent repository checks passed.\n'
