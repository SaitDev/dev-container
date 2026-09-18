#!/usr/bin/env bash
set -euo pipefail

INSTALL_SCRIPT_URL="${CODEX_INSTALL_SCRIPT_URL:-https://chatgpt.com/codex/install.sh}"
CODEX_RELEASE="${CODEX_RELEASE:-${CODEX_VERSION:-latest}}"
CODEX_INSTALL_DIR="${CODEX_INSTALL_DIR:-$HOME/.local/bin}"
CODEX_STANDALONE_HOME="${CODEX_STANDALONE_HOME:-${CODEX_HOME:-$HOME/.local/share/codex-standalone}}"
CODEX_NON_INTERACTIVE="${CODEX_NON_INTERACTIVE:-1}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [VERSION]
       $(basename "$0") --release VERSION

Installs Codex CLI using the official installer:
  $INSTALL_SCRIPT_URL

Environment:
  CODEX_RELEASE                         Version to install. Default: latest.
  CODEX_VERSION                         Backward-compatible alias for CODEX_RELEASE.
  CODEX_INSTALL_DIR                     Directory for visible codex command. Default: \$HOME/.local/bin.
  CODEX_STANDALONE_HOME                 Package root used by the official installer.
                                        Default: \$HOME/.local/share/codex-standalone.
  CODEX_HOME                            Backward-compatible alias for CODEX_STANDALONE_HOME.
  CODEX_INSTALLER_USE_RELEASES_OPENAI_COM
                                        Set to false/0/no to force GitHub Releases.
  CODEX_NON_INTERACTIVE                 Default: 1.
  CODEX_ALLOW_ROOT_INSTALL              Set to 1 to allow installing as root.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --release)
      [ "$#" -ge 2 ] || { echo "--release requires a value." >&2; exit 1; }
      CODEX_RELEASE="$2"
      shift
      ;;
    --help | -h)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      CODEX_RELEASE="$1"
      ;;
  esac
  shift
done

if [ "$(id -u)" = "0" ] && [ "${CODEX_ALLOW_ROOT_INSTALL:-0}" != "1" ]; then
  echo "Refusing to install Codex as root." >&2
  echo "Run this as the target user, for example: su dev -c '/usr/local/bin/download-codex.sh ${CODEX_RELEASE}'" >&2
  exit 1
fi

mkdir -p "$CODEX_INSTALL_DIR" "$CODEX_STANDALONE_HOME"

curl -fsSL "$INSTALL_SCRIPT_URL" | \
  CODEX_RELEASE="$CODEX_RELEASE" \
  CODEX_INSTALL_DIR="$CODEX_INSTALL_DIR" \
  CODEX_HOME="$CODEX_STANDALONE_HOME" \
  CODEX_NON_INTERACTIVE="$CODEX_NON_INTERACTIVE" \
  sh -s -- --release "$CODEX_RELEASE"
