#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${SSH_USER:-dev}"

# Home dir of target user
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ]; then
  echo "User $TARGET_USER not found" >&2
  exit 1
fi

DEST_DIR="$TARGET_HOME/.ssh"
SHARED_DIR="$DEST_DIR/shared"

# Nothing to do if shared mount isn't there
if [ ! -d "$SHARED_DIR" ]; then
  echo "No shared SSH directory at $SHARED_DIR; skipping copy."
  exit 0
fi

# Ensure .ssh exists
mkdir -p "$DEST_DIR"
chmod 700 "$DEST_DIR"
chown "$TARGET_USER:$TARGET_USER" "$DEST_DIR"

# Copy (do NOT use -a; avoid preserving root:root from the mount)
[ -f "$SHARED_DIR/mdaq" ] && cp "$SHARED_DIR/mdaq" "$DEST_DIR/mdaq"
[ -f "$SHARED_DIR/config" ] && cp "$SHARED_DIR/config" "$DEST_DIR/config"
[ -f "$SHARED_DIR/known_hosts" ] && cp "$SHARED_DIR/known_hosts" "$DEST_DIR/known_hosts"

# Fix ownership & perms ONLY on local copies
[ -f "$DEST_DIR/mdaq" ] && chown "$TARGET_USER:$TARGET_USER" "$DEST_DIR/mdaq" && chmod 600 "$DEST_DIR/mdaq"
[ -f "$DEST_DIR/config" ] && chown "$TARGET_USER:$TARGET_USER" "$DEST_DIR/config" && chmod 600 "$DEST_DIR/config"
[ -f "$DEST_DIR/known_hosts" ] && chown "$TARGET_USER:$TARGET_USER" "$DEST_DIR/known_hosts" && chmod 644 "$DEST_DIR/known_hosts"

echo "SSH keys/config copied to $DEST_DIR for $TARGET_USER."
