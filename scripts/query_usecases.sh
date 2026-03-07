#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INPUT_JSON="${ROOT_DIR}/docs/USECASES.json"
KEYWORD=""
CATEGORY=""
SOURCE=""
RISK=""
MIN_CONFIDENCE=0
MIN_REPRODUCIBILITY=0
LIMIT=20
AS_JSON=0

usage() {
  cat <<USAGE
Usage:
  scripts/query_usecases.sh [options]

Options:
  --input <file>        Input JSON index file (default: docs/USECASES.json)
  --keyword <text>      Keyword filter (matches title/path/category, case-insensitive)
  --category <name>     Category filter (exact match)
  --source <A|B>        Source filter
  --risk <low|medium|high>
                        Security risk filter (exact match)
  --min-confidence <n>  Minimum source confidence score
  --min-repro <n>       Minimum reproducibility score
  --limit <n>           Max results (default: 20)
  --json                Print JSON array instead of markdown table
  -h, --help            Show help

Examples:
  scripts/query_usecases.sh --keyword security
  scripts/query_usecases.sh --category 安全 --source B --limit 10
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      INPUT_JSON="${2:-}"
      shift 2
      ;;
    --keyword)
      KEYWORD="${2:-}"
      shift 2
      ;;
    --category)
      CATEGORY="${2:-}"
      shift 2
      ;;
    --source)
      SOURCE="${2:-}"
      shift 2
      ;;
    --risk)
      RISK="${2:-}"
      shift 2
      ;;
    --min-confidence)
      MIN_CONFIDENCE="${2:-}"
      shift 2
      ;;
    --min-repro)
      MIN_REPRODUCIBILITY="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    --json)
      AS_JSON=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not found." >&2
  exit 1
fi

if [[ ! -f "$INPUT_JSON" ]]; then
  echo "Error: input file not found: $INPUT_JSON" >&2
  exit 1
fi

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
  echo "Error: --limit must be a non-negative integer." >&2
  exit 1
fi

if ! [[ "$MIN_CONFIDENCE" =~ ^[0-9]+$ ]]; then
  echo "Error: --min-confidence must be a non-negative integer." >&2
  exit 1
fi

if ! [[ "$MIN_REPRODUCIBILITY" =~ ^[0-9]+$ ]]; then
  echo "Error: --min-repro must be a non-negative integer." >&2
  exit 1
fi

jq_filter='def normalize: ascii_downcase;
  .usecases
  | map(select((($kw == "") or ((.title + " " + .path + " " + .category) | normalize | contains($kw | normalize)))
           and (($category == "") or (.category == $category))
           and (($source == "") or (.source == $source))
           and (($risk == "") or ((.security_risk // "") == $risk))
           and ((.source_confidence // 0) >= $min_confidence)
           and ((.reproducibility_score // 0) >= $min_repro)))
  | .[:$limit]'

if [[ "$AS_JSON" -eq 1 ]]; then
  jq \
    --arg kw "$KEYWORD" \
    --arg category "$CATEGORY" \
    --arg source "$SOURCE" \
    --arg risk "$RISK" \
    --argjson min_confidence "$MIN_CONFIDENCE" \
    --argjson min_repro "$MIN_REPRODUCIBILITY" \
    --argjson limit "$LIMIT" \
    "$jq_filter" "$INPUT_JSON"
  exit 0
fi

results_json="$(jq \
  --arg kw "$KEYWORD" \
  --arg category "$CATEGORY" \
  --arg source "$SOURCE" \
  --arg risk "$RISK" \
  --argjson min_confidence "$MIN_CONFIDENCE" \
  --argjson min_repro "$MIN_REPRODUCIBILITY" \
  --argjson limit "$LIMIT" \
  "$jq_filter" "$INPUT_JSON")"
count="$(printf '%s' "$results_json" | jq 'length')"

echo "# Query Result"
echo
echo "- Input: $INPUT_JSON"
echo "- Keyword: ${KEYWORD:-<empty>}"
echo "- Category: ${CATEGORY:-<empty>}"
echo "- Source: ${SOURCE:-<empty>}"
echo "- Risk: ${RISK:-<empty>}"
echo "- Min Confidence: $MIN_CONFIDENCE"
echo "- Min Reproducibility: $MIN_REPRODUCIBILITY"
echo "- Limit: $LIMIT"
echo "- Matched: $count"
echo

if [[ "$count" -eq 0 ]]; then
  echo "无匹配结果。"
  exit 0
fi

echo "| # | Source | Category | Risk | Confidence | Reproducibility | Title | URL |"
echo "|---|---|---|---|---:|---:|---|---|"
printf '%s' "$results_json" | jq -r '.[] | "| \(.index) | \(.source) | \(.category) | \(.security_risk // "unknown") | \(.source_confidence // 0) | \(.reproducibility_score // 0) | \(.title | gsub("\\|"; "\\\\|")) | [link](\(.url)) |"'
