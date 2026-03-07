#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/openclaw-quickstarts-test-XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

INDEX_JSON="${TMP_DIR}/USECASES.json"
OUT_MD="${TMP_DIR}/QUICKSTARTS.md"
OUT_JSON="${TMP_DIR}/QUICKSTARTS.json"

"${ROOT_DIR}/scripts/generate_usecases_index.sh" \
  --src-a "${ROOT_DIR}/tests/fixtures/source_a" \
  --src-b "${ROOT_DIR}/tests/fixtures/source_b" \
  --out-md "${TMP_DIR}/USECASES.md" \
  --out-json "$INDEX_JSON" \
  --out-stats "${TMP_DIR}/STATS.md"

"${ROOT_DIR}/scripts/generate_quickstarts.sh" \
  --index "$INDEX_JSON" \
  --out-md "$OUT_MD" \
  --out-json "$OUT_JSON" \
  --top 2

[[ -s "$OUT_MD" ]] || { echo "Missing quickstarts markdown output" >&2; exit 1; }
[[ -s "$OUT_JSON" ]] || { echo "Missing quickstarts json output" >&2; exit 1; }

jq -e '.selected_count == 2 and (.quickstarts | length == 2)' "$OUT_JSON" >/dev/null
jq -e '.quickstarts | all(has("ranking_score") and has("quickstart"))' "$OUT_JSON" >/dev/null
jq -e '.quickstarts[0].quickstart | has("preflight") and has("steps") and has("verification") and has("rollback")' "$OUT_JSON" >/dev/null
grep -Fq "## 总览" "$OUT_MD"
grep -Fq "### Steps" "$OUT_MD"

echo "test_generate_quickstarts.sh: PASS"
