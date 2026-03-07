#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/openclaw-diff-test-XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

OLD_JSON="${TMP_DIR}/old.json"
NEW_JSON="${TMP_DIR}/new.json"
OUT_MD="${TMP_DIR}/DIFF.md"
OUT_JSON="${TMP_DIR}/DIFF.json"

cat > "$OLD_JSON" <<'JSON'
{
  "generated_at": "2026-03-01 00:00:00 CST",
  "usecases": [
    {
      "source": "A",
      "path": "usecases/a.md",
      "title": "Alpha Old",
      "url": "https://example.com/a",
      "category": "通用",
      "license_status": "explicit_license",
      "source_confidence": 80,
      "security_risk": "low",
      "reproducibility_score": 76
    },
    {
      "source": "B",
      "path": "usecases/b.md",
      "title": "Beta Removed",
      "url": "https://example.com/b",
      "category": "通用",
      "license_status": "missing_explicit_license",
      "source_confidence": 60,
      "security_risk": "medium",
      "reproducibility_score": 58
    }
  ]
}
JSON

cat > "$NEW_JSON" <<'JSON'
{
  "generated_at": "2026-03-07 00:00:00 CST",
  "usecases": [
    {
      "source": "A",
      "path": "usecases/a.md",
      "title": "Alpha Updated",
      "url": "https://example.com/a",
      "category": "通用",
      "license_status": "explicit_license",
      "source_confidence": 78,
      "security_risk": "low",
      "reproducibility_score": 76
    },
    {
      "source": "A",
      "path": "usecases/c.md",
      "title": "Gamma New",
      "url": "https://example.com/c",
      "category": "学习知识",
      "license_status": "explicit_license",
      "source_confidence": 84,
      "security_risk": "low",
      "reproducibility_score": 82
    }
  ]
}
JSON

"${ROOT_DIR}/scripts/generate_usecases_diff.sh" \
  --old "$OLD_JSON" \
  --new "$NEW_JSON" \
  --out-md "$OUT_MD" \
  --out-json "$OUT_JSON" \
  --preview-limit 10

[[ -s "$OUT_MD" ]] || { echo "Missing diff markdown output" >&2; exit 1; }
[[ -s "$OUT_JSON" ]] || { echo "Missing diff json output" >&2; exit 1; }

jq -e '.totals.new_count == 1 and .totals.updated_count == 1 and .totals.removed_count == 1' "$OUT_JSON" >/dev/null
jq -e '.updated[0].changed_fields | index("title") != null' "$OUT_JSON" >/dev/null
jq -e '.updated[0].changed_fields | index("source_confidence") != null' "$OUT_JSON" >/dev/null
grep -Fq "## NEW" "$OUT_MD"
grep -Fq "## UPDATED" "$OUT_MD"
grep -Fq "## REMOVED" "$OUT_MD"

echo "test_generate_usecases_diff.sh: PASS"
