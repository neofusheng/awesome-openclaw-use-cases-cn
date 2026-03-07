#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OLD_JSON=""
NEW_JSON="${ROOT_DIR}/docs/USECASES.json"
OUT_MD="${ROOT_DIR}/docs/DIFF.md"
OUT_JSON="${ROOT_DIR}/docs/DIFF.json"
PREVIEW_LIMIT=30

usage() {
  cat <<'USAGE' >&2
Usage:
  scripts/generate_usecases_diff.sh [options] [old_json] [new_json]

Options:
  --old <file>        Previous index JSON file (optional).
  --new <file>        Current index JSON file (default: docs/USECASES.json)
  --out-md <file>     Diff markdown output (default: docs/DIFF.md)
  --out-json <file>   Diff JSON output (default: docs/DIFF.json)
  --preview-limit <n> Preview rows per section in markdown (default: 30)
  -h, --help          Show help.
USAGE
}

positionals=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --old)
      OLD_JSON="${2:-}"
      shift 2
      ;;
    --new)
      NEW_JSON="${2:-}"
      shift 2
      ;;
    --out-md)
      OUT_MD="${2:-}"
      shift 2
      ;;
    --out-json)
      OUT_JSON="${2:-}"
      shift 2
      ;;
    --preview-limit)
      PREVIEW_LIMIT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        positionals+=("$1")
        shift
      done
      ;;
    -*)
      echo "Error: unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      positionals+=("$1")
      shift
      ;;
  esac
done

if [[ ${#positionals[@]} -gt 2 ]]; then
  echo "Error: too many positional arguments." >&2
  usage
  exit 1
fi

if [[ ${#positionals[@]} -ge 1 && -z "$OLD_JSON" ]]; then
  OLD_JSON="${positionals[0]}"
fi
if [[ ${#positionals[@]} -ge 2 ]]; then
  NEW_JSON="${positionals[1]}"
fi

if ! [[ "$PREVIEW_LIMIT" =~ ^[0-9]+$ ]]; then
  echo "Error: --preview-limit must be a non-negative integer." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not found." >&2
  exit 1
fi

if [[ ! -f "$NEW_JSON" ]]; then
  echo "Error: new JSON not found: ${NEW_JSON}" >&2
  exit 1
fi

tmp_dir="$(mktemp -d /tmp/openclaw-usecases-diff-XXXXXX)"
trap 'rm -rf "$tmp_dir"' EXIT

OLD_EFFECTIVE="${tmp_dir}/old.json"
if [[ -n "$OLD_JSON" && -f "$OLD_JSON" ]]; then
  cp "$OLD_JSON" "$OLD_EFFECTIVE"
else
  cat > "$OLD_EFFECTIVE" <<'JSON'
{"generated_at":"","usecases":[]}
JSON
fi

mkdir -p "$(dirname "$OUT_MD")"
mkdir -p "$(dirname "$OUT_JSON")"

jq -s \
  --arg compared_at "$(date '+%Y-%m-%d %H:%M:%S %Z')" '
  (.[0] // {"generated_at":"","usecases":[]}) as $old |
  (.[1] // {"generated_at":"","usecases":[]}) as $new |

  def usecases($doc): ($doc.usecases // []);

  def tracked($u): {
    source: $u.source,
    path: $u.path,
    title: $u.title,
    url: $u.url,
    category: $u.category,
    license_status: ($u.license_status // "unknown"),
    source_confidence: ($u.source_confidence // 0),
    security_risk: ($u.security_risk // "unknown"),
    reproducibility_score: ($u.reproducibility_score // 0)
  };

  def as_map($arr):
    reduce $arr[] as $u ({}; .[$u.source + "|" + $u.path] = tracked($u));

  def changed_fields($before; $after):
    ["title","url","category","license_status","source_confidence","security_risk","reproducibility_score"]
    | map(select($before[.] != $after[.]));

  (usecases($old)) as $old_items |
  (usecases($new)) as $new_items |
  (as_map($old_items)) as $old_map |
  (as_map($new_items)) as $new_map |

  {
    generated_at: ($new.generated_at // ""),
    compared_at: $compared_at,
    previous_generated_at: ($old.generated_at // ""),
    totals: {
      previous_overall: ($old_items | length),
      current_overall: ($new_items | length),
      new_count: ([ $new_map | to_entries[] | select($old_map[.key] == null) ] | length),
      updated_count: ([ $new_map | to_entries[] | select($old_map[.key] != null and ($old_map[.key] != .value)) ] | length),
      removed_count: ([ $old_map | to_entries[] | select($new_map[.key] == null) ] | length)
    },
    new: [
      $new_map
      | to_entries[]
      | select($old_map[.key] == null)
      | .value
    ],
    updated: [
      $new_map
      | to_entries[]
      | select($old_map[.key] != null and ($old_map[.key] != .value))
      | {
          source: .value.source,
          path: .value.path,
          changed_fields: changed_fields($old_map[.key]; .value),
          before: $old_map[.key],
          after: .value
        }
    ],
    removed: [
      $old_map
      | to_entries[]
      | select($new_map[.key] == null)
      | .value
    ]
  }
' "$OLD_EFFECTIVE" "$NEW_JSON" > "$OUT_JSON"

NEW_COUNT="$(jq -r '.totals.new_count' "$OUT_JSON")"
UPDATED_COUNT="$(jq -r '.totals.updated_count' "$OUT_JSON")"
REMOVED_COUNT="$(jq -r '.totals.removed_count' "$OUT_JSON")"
CURRENT_TOTAL="$(jq -r '.totals.current_overall' "$OUT_JSON")"
PREVIOUS_TOTAL="$(jq -r '.totals.previous_overall' "$OUT_JSON")"
GENERATED_AT="$(jq -r '.generated_at' "$OUT_JSON")"
COMPARED_AT="$(jq -r '.compared_at' "$OUT_JSON")"
PREVIOUS_GENERATED_AT="$(jq -r '.previous_generated_at' "$OUT_JSON")"

{
  echo "# OpenClaw Usecases 增量变化"
  echo
  echo "> 自动生成文件，请勿手工编辑。"
  echo
  echo "- 对比时间: ${COMPARED_AT}"
  echo "- 当前索引时间: ${GENERATED_AT}"
  echo "- 上次索引时间: ${PREVIOUS_GENERATED_AT}"
  echo "- 总量变化: ${PREVIOUS_TOTAL} -> ${CURRENT_TOTAL}"
  echo "- NEW: ${NEW_COUNT}"
  echo "- UPDATED: ${UPDATED_COUNT}"
  echo "- REMOVED: ${REMOVED_COUNT}"
  echo

  echo "## NEW"
  echo
  if [[ "$NEW_COUNT" -eq 0 ]]; then
    echo "- 无新增"
  else
    echo "| Source | Path | Title | Risk | Confidence | Reproducibility |"
    echo "|---|---|---|---|---:|---:|"
    jq -r --argjson limit "$PREVIEW_LIMIT" '
      .new[:$limit][]
      | "| \(.source) | \(.path | gsub("\\|"; "\\\\|")) | \(.title | gsub("\\|"; "\\\\|")) | \(.security_risk) | \(.source_confidence) | \(.reproducibility_score) |"
    ' "$OUT_JSON"
    if (( NEW_COUNT > PREVIEW_LIMIT )); then
      echo
      echo "- 仅展示前 ${PREVIEW_LIMIT} 条，完整结果见 DIFF.json"
    fi
  fi
  echo

  echo "## UPDATED"
  echo
  if [[ "$UPDATED_COUNT" -eq 0 ]]; then
    echo "- 无更新"
  else
    echo "| Source | Path | Changed Fields | Before Title | After Title | Risk | Confidence | Reproducibility |"
    echo "|---|---|---|---|---|---|---:|---:|"
    jq -r --argjson limit "$PREVIEW_LIMIT" '
      .updated[:$limit][]
      | "| \(.source) | \(.path | gsub("\\|"; "\\\\|")) | \(.changed_fields | join(",")) | \(.before.title | gsub("\\|"; "\\\\|")) | \(.after.title | gsub("\\|"; "\\\\|")) | \(.after.security_risk) | \(.after.source_confidence) | \(.after.reproducibility_score) |"
    ' "$OUT_JSON"
    if (( UPDATED_COUNT > PREVIEW_LIMIT )); then
      echo
      echo "- 仅展示前 ${PREVIEW_LIMIT} 条，完整结果见 DIFF.json"
    fi
  fi
  echo

  echo "## REMOVED"
  echo
  if [[ "$REMOVED_COUNT" -eq 0 ]]; then
    echo "- 无下线"
  else
    echo "| Source | Path | Title | Risk | Confidence | Reproducibility |"
    echo "|---|---|---|---|---:|---:|"
    jq -r --argjson limit "$PREVIEW_LIMIT" '
      .removed[:$limit][]
      | "| \(.source) | \(.path | gsub("\\|"; "\\\\|")) | \(.title | gsub("\\|"; "\\\\|")) | \(.security_risk) | \(.source_confidence) | \(.reproducibility_score) |"
    ' "$OUT_JSON"
    if (( REMOVED_COUNT > PREVIEW_LIMIT )); then
      echo
      echo "- 仅展示前 ${PREVIEW_LIMIT} 条，完整结果见 DIFF.json"
    fi
  fi
} > "$OUT_MD"

echo "Generated diff markdown: ${OUT_MD}"
echo "Generated diff json: ${OUT_JSON}"
