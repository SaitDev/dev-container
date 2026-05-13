#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${SSH_USER:-dev}"

if ! getent passwd "$TARGET_USER" >/dev/null; then
  echo "User $TARGET_USER not found" >&2
  exit 1
fi

/usr/local/bin/setup-ssh.sh

ssh-keygen -A
exec /usr/sbin/sshd -D -e
