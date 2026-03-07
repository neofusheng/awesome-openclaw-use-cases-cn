#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/openclaw-usecases-test-XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUT_MD="${TMP_DIR}/USECASES.md"
OUT_JSON="${TMP_DIR}/USECASES.json"
OUT_STATS="${TMP_DIR}/STATS.md"

assert_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -qE "$pattern" "$file"; then
    echo "Assertion failed: pattern '$pattern' not found in $file" >&2
    exit 1
  fi
}

"${ROOT_DIR}/scripts/generate_usecases_index.sh" \
  --src-a "${ROOT_DIR}/tests/fixtures/source_a" \
  --src-b "${ROOT_DIR}/tests/fixtures/source_b" \
  --out-md "$OUT_MD" \
  --out-json "$OUT_JSON" \
  --out-stats "$OUT_STATS"

[[ -s "$OUT_MD" ]] || { echo "Missing markdown output" >&2; exit 1; }
[[ -s "$OUT_JSON" ]] || { echo "Missing json output" >&2; exit 1; }
[[ -s "$OUT_STATS" ]] || { echo "Missing stats output" >&2; exit 1; }

assert_contains "$OUT_MD" '总计: 3'
assert_contains "$OUT_MD" 'beta case'
assert_contains "$OUT_JSON" '"source_a": 2'
assert_contains "$OUT_JSON" '"source_b": 1'
assert_contains "$OUT_JSON" '"overall": 3'
assert_contains "$OUT_STATS" '潜在重复标题: 0'
jq -e '.usecases | all(has("license_status") and has("source_confidence") and has("security_risk") and has("reproducibility_score"))' "$OUT_JSON" >/dev/null
jq -e '.sources | all(has("license_status"))' "$OUT_JSON" >/dev/null

echo "test_generate_usecases_index.sh: PASS"
