#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/openclaw-sources-test-XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

SRC_A="${TMP_DIR}/source_a"
SRC_B="${TMP_DIR}/source_b"
OUT_MD="${TMP_DIR}/SOURCES.md"

mkdir -p "${SRC_A}/usecases" "${SRC_B}/usecases"

cat > "${SRC_A}/usecases/a.md" <<'MD'
# A Case
MD
cat > "${SRC_B}/usecases/b.md" <<'MD'
# B Case
MD
cat > "${SRC_A}/LICENSE" <<'TXT'
MIT License
TXT

git -C "$TMP_DIR" init source_a >/dev/null

git -C "$SRC_A" add .
git -C "$SRC_A" -c user.name='test' -c user.email='test@example.com' commit -m 'init source a' >/dev/null

git -C "$TMP_DIR" init source_b >/dev/null

git -C "$SRC_B" add .
git -C "$SRC_B" -c user.name='test' -c user.email='test@example.com' commit -m 'init source b' >/dev/null

A_COMMIT="$(git -C "$SRC_A" rev-parse --short HEAD)"
B_COMMIT="$(git -C "$SRC_B" rev-parse --short HEAD)"

"${ROOT_DIR}/scripts/generate_sources_report.sh" \
  --src-a "$SRC_A" \
  --src-b "$SRC_B" \
  --out "$OUT_MD"

[[ -s "$OUT_MD" ]] || { echo "Missing sources output" >&2; exit 1; }

grep -Fq "Commit: \`${A_COMMIT}\`" "$OUT_MD" || { echo "Missing source A commit" >&2; exit 1; }
grep -Fq "Commit: \`${B_COMMIT}\`" "$OUT_MD" || { echo "Missing source B commit" >&2; exit 1; }
grep -Fq "License Files: LICENSE" "$OUT_MD" || { echo "Missing source A license line" >&2; exit 1; }
grep -Fq "未发现显式许可证文件" "$OUT_MD" || { echo "Missing source B no-license note" >&2; exit 1; }

echo "test_generate_sources_report.sh: PASS"
