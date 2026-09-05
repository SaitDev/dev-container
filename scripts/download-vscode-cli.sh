#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-dev}"
TARGET_HOME="${TARGET_HOME:-}"
VSCODE_CLI_OS="${VSCODE_CLI_OS:-cli-alpine-x64}"

if [ -z "$TARGET_HOME" ]; then
  if getent passwd "$TARGET_USER" >/dev/null 2>&1; then
    TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
  else
    TARGET_HOME="/home/$TARGET_USER"
  fi
fi

INSTALL_DIR="${VSCODE_CLI_BIN_DIR:-$TARGET_HOME/.local/share/vscode-cli/bin}"
ARCHIVE="/tmp/vscode_cli.tar.gz"
URL="https://code.visualstudio.com/sha/download?build=stable&os=$VSCODE_CLI_OS"

mkdir -p "$INSTALL_DIR"
curl -Lk "$URL" --output "$ARCHIVE"
tar -xf "$ARCHIVE" -C "$INSTALL_DIR"
rm -f "$ARCHIVE"

if [ "$(id -u)" = "0" ] && getent passwd "$TARGET_USER" >/dev/null 2>&1; then
  chown -R "$TARGET_USER:$TARGET_USER" "$INSTALL_DIR"
fi
