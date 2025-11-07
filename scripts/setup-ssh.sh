#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${SSH_USER:-dev}"

# Find home dir of target user
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ]; then
  echo "User $TARGET_USER not found" >&2
  exit 1
fi

SHARED_DIR="$TARGET_HOME/.ssh/shared"
DEST_DIR="$TARGET_HOME/.ssh"

# Nothing to do if shared mount isn't there
if [ ! -d "$SHARED_DIR" ]; then
  echo "No shared SSH directory at $SHARED_DIR; skipping copy."
  exit 0
fi

# Ensure .ssh exists
mkdir -p "$DEST_DIR"

# Copy files from shared (read-only mount) into real .ssh
if [ -f "$SHARED_DIR/mdaq" ]; then
  cp "$SHARED_DIR/mdaq" "$DEST_DIR/mdaq"
fi

if [ -f "$SHARED_DIR/config" ]; then
  cp "$SHARED_DIR/config" "$DEST_DIR/config"
fi

# Optional: copy known_hosts if you bind-mount it later
if [ -f "$SHARED_DIR/known_hosts" ]; then
  cp "$SHARED_DIR/known_hosts" "$DEST_DIR/known_hosts"
fi

# Fix ownership & permissions
chown -R "$TARGET_USER:$TARGET_USER" "$DEST_DIR"
chmod 700 "$DEST_DIR"
[ -f "$DEST_DIR/mdaq" ] && chmod 600 "$DEST_DIR/mdaq"
[ -f "$DEST_DIR/config" ] && chmod 600 "$DEST_DIR/config"
[ -f "$DEST_DIR/known_hosts" ] && chmod 644 "$DEST_DIR/known_hosts"

echo "SSH keys/config copied to $DEST_DIR for $TARGET_USER."
