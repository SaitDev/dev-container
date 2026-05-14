#!/usr/bin/env bash
set -euo pipefail

CODEX_TARGET="${CODEX_TARGET:-x86_64-unknown-linux-musl}"
CODEX_DIR="${CODEX_DIR:-/opt/codex}"
CODEX_ARCHIVE="/tmp/codex.tar.gz"
CODEX_URL="https://github.com/openai/codex/releases/latest/download/codex-${CODEX_TARGET}.tar.gz"

mkdir -p "$CODEX_DIR"

curl -fL -o "$CODEX_ARCHIVE" "$CODEX_URL"
tar -xzf "$CODEX_ARCHIVE" -C "$CODEX_DIR" --overwrite
rm -f "$CODEX_ARCHIVE"
