#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="."
COMMANDS="lint,test,build"
STRICT_REQUIRED=0
ALLOW_EMPTY=0

PASS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0
EXECUTED=0

usage() {
  cat <<USAGE
Usage:
  scripts/run_quality_gates.sh [options]

Options:
  --project-dir <dir>      Target project directory (default: .)
  --commands <csv>         Gates to run, e.g. lint,test,build (default: all)
  --strict-required        Treat missing requested gates as failures
  --allow-empty            Allow zero executed checks without failing
  -h, --help               Show help
USAGE
}

record() {
  local level="$1"
  local message="$2"
  printf '[%s] %s\n' "$level" "$message"
  case "$level" in
    PASS) PASS_COUNT=$((PASS_COUNT + 1)) ;;
    SKIP) SKIP_COUNT=$((SKIP_COUNT + 1)) ;;
    FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
  esac
}

run_gate() {
  local gate_name="$1"
  shift

  if "$@"; then
    record PASS "$gate_name"
    EXECUTED=$((EXECUTED + 1))
  else
    record FAIL "$gate_name"
  fi
}

gate_lint() {
  bash -n scripts/*.sh tests/*.sh
}

gate_test() {
  bash tests/test_generate_usecases_index.sh
  bash tests/test_generate_sources_report.sh
  bash tests/test_generate_usecases_diff.sh
  bash tests/test_generate_quickstarts.sh
}

gate_build() {
  local tmp_dir out_md out_json out_stats out_diff_md out_diff_json out_quick_md out_quick_json status

  tmp_dir="$(mktemp -d /tmp/openclaw-qg-build-XXXXXX)"
  out_md="${tmp_dir}/USECASES.md"
  out_json="${tmp_dir}/USECASES.json"
  out_stats="${tmp_dir}/STATS.md"
  out_diff_md="${tmp_dir}/DIFF.md"
  out_diff_json="${tmp_dir}/DIFF.json"
  out_quick_md="${tmp_dir}/QUICKSTARTS.md"
  out_quick_json="${tmp_dir}/QUICKSTARTS.json"

  scripts/generate_usecases_index.sh \
    --src-a tests/fixtures/source_a \
    --src-b tests/fixtures/source_b \
    --out-md "$out_md" \
    --out-json "$out_json" \
    --out-stats "$out_stats" >/dev/null

  scripts/generate_usecases_diff.sh \
    --new "$out_json" \
    --out-md "$out_diff_md" \
    --out-json "$out_diff_json" >/dev/null

  scripts/generate_quickstarts.sh \
    --index "$out_json" \
    --out-md "$out_quick_md" \
    --out-json "$out_quick_json" \
    --top 2 >/dev/null

  status=0
  [[ -s "$out_md" && -s "$out_json" && -s "$out_stats" && -s "$out_diff_md" && -s "$out_diff_json" && -s "$out_quick_md" && -s "$out_quick_json" ]] || status=1

  rm -rf "$tmp_dir"
  return "$status"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      PROJECT_DIR="${2:-}"
      shift 2
      ;;
    --commands)
      COMMANDS="${2:-}"
      shift 2
      ;;
    --strict-required)
      STRICT_REQUIRED=1
      shift
      ;;
    --allow-empty)
      ALLOW_EMPTY=1
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

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Project directory not found: $PROJECT_DIR" >&2
  exit 2
fi

cd "$PROJECT_DIR"

IFS=',' read -r -a gates <<< "$COMMANDS"
for raw_gate in "${gates[@]}"; do
  gate="$(printf '%s' "$raw_gate" | xargs | tr '[:upper:]' '[:lower:]')"
  [[ -n "$gate" ]] || continue

  case "$gate" in
    lint)
      run_gate "lint (bash -n scripts/*.sh tests/*.sh)" gate_lint
      ;;
    test)
      run_gate "test (index + sources report tests)" gate_test
      ;;
    build)
      run_gate "build (fixture generation smoke)" gate_build
      ;;
    *)
      if [[ "$STRICT_REQUIRED" -eq 1 ]]; then
        record FAIL "unknown gate requested: $gate"
      else
        record SKIP "unknown gate skipped: $gate"
      fi
      ;;
  esac
done

echo "== Gate Summary =="
printf 'PASS=%d SKIP=%d FAIL=%d EXECUTED=%d\n' "$PASS_COUNT" "$SKIP_COUNT" "$FAIL_COUNT" "$EXECUTED"

if [[ "$EXECUTED" -eq 0 && "$ALLOW_EMPTY" -eq 0 ]]; then
  echo "No gates executed. Use --allow-empty only when expected." >&2
  exit 1
fi

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
