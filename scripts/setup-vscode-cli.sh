#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-dev}"
TARGET_HOME="${TARGET_HOME:-}"

if [ -z "$TARGET_HOME" ]; then
  if getent passwd "$TARGET_USER" >/dev/null 2>&1; then
    TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
  else
    TARGET_HOME="/home/$TARGET_USER"
  fi
fi

VSCODE_CLI_BIN_DIR="${VSCODE_CLI_BIN_DIR:-$TARGET_HOME/.local/share/vscode-cli/bin}"
VSCODE_CLI_DATA_DIR="${VSCODE_CLI_DATA_DIR:-$TARGET_HOME/.vscode}"
BLOCK_BEGIN="# >>> vscode-cli >>>"
BLOCK_END="# <<< vscode-cli <<<"
BLOCK_CONTENT="export VSCODE_CLI_USE_FILE_KEYCHAIN=\"\${VSCODE_CLI_USE_FILE_KEYCHAIN:-1}\"
export VSCODE_CLI_DATA_DIR=\"\${VSCODE_CLI_DATA_DIR:-$VSCODE_CLI_DATA_DIR}\"
case \":\$PATH:\" in
  *\":$VSCODE_CLI_BIN_DIR:\"*) ;;
  *) export PATH=\"$VSCODE_CLI_BIN_DIR:\$PATH\" ;;
esac"

mkdir -p "$VSCODE_CLI_BIN_DIR" "$VSCODE_CLI_DATA_DIR"

for rc_file in "$TARGET_HOME/.bashrc" "$TARGET_HOME/.zshrc" "$TARGET_HOME/.zprofile"; do
  touch "$rc_file"
  tmp_file="$(mktemp)"
  awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$rc_file" > "$tmp_file"
  {
    cat "$tmp_file"
    printf '%s\n%s\n%s\n' "$BLOCK_BEGIN" "$BLOCK_CONTENT" "$BLOCK_END"
  } > "$rc_file"
  rm -f "$tmp_file"
done

if [ "$(id -u)" = "0" ] && getent passwd "$TARGET_USER" >/dev/null 2>&1; then
  chown -R "$TARGET_USER:$TARGET_USER" "$VSCODE_CLI_BIN_DIR" \
    "$VSCODE_CLI_DATA_DIR" \
    "$TARGET_HOME/.bashrc" \
    "$TARGET_HOME/.zshrc" \
    "$TARGET_HOME/.zprofile"
fi
