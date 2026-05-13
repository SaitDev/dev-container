#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${SSH_USER:-dev}"

# Home dir of target user
if ! TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"; then
  echo "User $TARGET_USER not found" >&2
  exit 1
fi

DEST_DIR="$TARGET_HOME/.ssh"
SHARED_DIR="$DEST_DIR/shared"
KEYS_DIR="$SHARED_DIR/keys"
IS_ROOT=0

if [ "$(id -u)" = "0" ]; then
  IS_ROOT=1
fi

# Ensure .ssh exists
mkdir -p "$DEST_DIR"
chmod 700 "$DEST_DIR"
[ "$IS_ROOT" = "1" ] && chown "$TARGET_USER:$TARGET_USER" "$DEST_DIR"

if [ -d "$SHARED_DIR" ]; then
  # Copy without preserving root:root ownership from bind mounts.
  if [ -d "$KEYS_DIR" ]; then
    for key in "$KEYS_DIR"/*; do
      [ -f "$key" ] || continue
      key_name="$(basename "$key")"
      [ "${key_name##*.}" = "pub" ] && continue
      cp "$key" "$DEST_DIR/$key_name"
    done
  fi

  [ -f "$SHARED_DIR/authorized_keys" ] && cp "$SHARED_DIR/authorized_keys" "$DEST_DIR/authorized_keys"
  [ -f "$SHARED_DIR/config" ] && cp "$SHARED_DIR/config" "$DEST_DIR/config"
else
  echo "No shared SSH directory at $SHARED_DIR; skipping SSH file copy."
fi

if [ "$IS_ROOT" = "1" ]; then
  for dest in "$DEST_DIR"/*; do
    [ -f "$dest" ] || continue
    chown "$TARGET_USER:$TARGET_USER" "$dest"
  done
fi

for dest in "$DEST_DIR"/*; do
  [ -f "$dest" ] || continue
  chmod 600 "$dest"
done

echo "SSH setup complete for $TARGET_USER."
