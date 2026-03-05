#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SRC_A="${1:-${OPENCLAW_SRC_A:-}}"
SRC_B="${2:-${OPENCLAW_SRC_B:-}}"
OUT_MD="${3:-$ROOT_DIR/docs/USECASES.md}"

A_REPO="hesamsheikh/awesome-openclaw-usecases"
B_REPO="EvoLinkAI/awesome-openclaw-usecases-moltbook"
A_URL="https://github.com/${A_REPO}/blob/main/usecases"
B_URL="https://github.com/${B_REPO}/blob/main/usecases"

usage() {
  cat <<'USAGE' >&2
Usage:
  scripts/generate_usecases_index.sh <source_a_repo_dir> <source_b_repo_dir> [output_markdown]

Example:
  scripts/generate_usecases_index.sh \
    /tmp/openclaw/usecases \
    /tmp/openclaw/moltbook \
    docs/USECASES.md

Environment variable fallback:
  OPENCLAW_SRC_A=/path/to/awesome-openclaw-usecases
  OPENCLAW_SRC_B=/path/to/awesome-openclaw-usecases-moltbook
USAGE
}

if [[ -z "$SRC_A" || -z "$SRC_B" ]]; then
  usage
  exit 1
fi

A_DIR="${SRC_A}/usecases"
B_DIR="${SRC_B}/usecases"

if [[ ! -d "$A_DIR" ]]; then
  echo "Error: missing directory: ${A_DIR}" >&2
  exit 1
fi
if [[ ! -d "$B_DIR" ]]; then
  echo "Error: missing directory: ${B_DIR}" >&2
  exit 1
fi

escape_pipe() {
  printf '%s' "$1" | sed 's/|/\\|/g'
}

extract_title() {
  local file="$1"
  local title
  title="$(awk '/^# /{sub(/^# /, ""); print; exit}' "$file")"
  if [[ -z "$title" ]]; then
    title="$(basename "$file" .md | tr '-' ' ')"
  fi
  printf '%s' "$title"
}

A_COUNT="$(find "$A_DIR" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
B_COUNT="$(find "$B_DIR" -maxdepth 1 -type f -name '*.md' ! -name 'TEMPLATE.md' | wc -l | tr -d ' ')"
TOTAL_COUNT="$((A_COUNT + B_COUNT))"
GENERATED_AT="$(date '+%Y-%m-%d %H:%M:%S %Z')"

mkdir -p "$(dirname "$OUT_MD")"

{
  echo "# OpenClaw Usecases 中文总索引"
  echo
  echo "> 自动生成文件，请勿手工编辑。"
  echo
  echo "- 生成时间: ${GENERATED_AT}"
  echo "- 来源 A: \`${A_REPO}\` (${A_COUNT})"
  echo "- 来源 B: \`${B_REPO}\` (${B_COUNT})"
  echo "- 总计: ${TOTAL_COUNT}"
  echo
  echo "## 来源 A（社区合集）"
  echo
  echo "| # | 用例 | 上游链接 | 相对路径 |"
  echo "|---|---|---|---|"

  idx=1
  while IFS= read -r file; do
    base="$(basename "$file")"
    title="$(escape_pipe "$(extract_title "$file")")"
    printf '| %d | %s | [查看](%s/%s) | `usecases/%s` |\n' \
      "$idx" "$title" "$A_URL" "$base" "$base"
    idx=$((idx + 1))
  done < <(find "$A_DIR" -maxdepth 1 -type f -name '*.md' | sort)

  echo
  echo "## 来源 B（Moltbook）"
  echo
  echo "| # | 用例 | 上游链接 | 相对路径 |"
  echo "|---|---|---|---|"

  idx=1
  while IFS= read -r file; do
    base="$(basename "$file")"
    title="$(escape_pipe "$(extract_title "$file")")"
    printf '| %d | %s | [查看](%s/%s) | `usecases/%s` |\n' \
      "$idx" "$title" "$B_URL" "$base" "$base"
    idx=$((idx + 1))
  done < <(find "$B_DIR" -maxdepth 1 -type f -name '*.md' ! -name 'TEMPLATE.md' | sort)
} > "$OUT_MD"

echo "Generated: ${OUT_MD}"
