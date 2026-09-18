#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$script_dir/.env" ]; then
  set -a
  . "$script_dir/.env"
  set +a
fi

workspace_resource="${WORKSPACE_RESOURCE:-$script_dir}"

mkdir -p "$workspace_resource/shell"
touch "$workspace_resource/shell/zsh_history"

docker compose -f "$script_dir/compose.yml" up -d --build --force-recreate "$@"
