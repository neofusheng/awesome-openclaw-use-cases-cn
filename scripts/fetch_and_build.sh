#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${1:-$(mktemp -d /tmp/openclaw-usecases-cn-src-XXXXXX)}"

if [[ -e "$WORK_DIR" && ! -d "$WORK_DIR" ]]; then
  echo "Error: work dir exists and is not a directory: ${WORK_DIR}" >&2
  exit 1
fi

mkdir -p "$WORK_DIR"

SRC_A="${WORK_DIR}/awesome-openclaw-usecases"
SRC_B="${WORK_DIR}/awesome-openclaw-usecases-moltbook"

if [[ -d "$SRC_A" || -d "$SRC_B" ]]; then
  echo "Error: target source directories already exist in ${WORK_DIR}" >&2
  echo "Please use an empty work directory or a new path." >&2
  exit 1
fi

git clone --depth 1 https://github.com/hesamsheikh/awesome-openclaw-usecases "$SRC_A"
git clone --depth 1 https://github.com/EvoLinkAI/awesome-openclaw-usecases-moltbook "$SRC_B"

"${ROOT_DIR}/scripts/generate_usecases_index.sh" "$SRC_A" "$SRC_B" "${ROOT_DIR}/docs/USECASES.md"

echo "Done. Index written to ${ROOT_DIR}/docs/USECASES.md"
echo "Source cache: ${WORK_DIR}"
