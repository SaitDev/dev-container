#!/usr/bin/env bash
set -euo pipefail

CODEX_TARGET="${CODEX_TARGET:-x86_64-unknown-linux-musl}"
CODEX_DIR="${CODEX_DIR:-/opt/codex}"
CODEX_VERSION="${CODEX_VERSION:-latest}"

if [ "$CODEX_VERSION" = "latest" ]; then
  CODEX_BASE_URL="https://github.com/openai/codex/releases/latest/download"
else
  CODEX_VERSION="${CODEX_VERSION#rust-v}"
  CODEX_VERSION="${CODEX_VERSION#v}"
  CODEX_BASE_URL="https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}"
fi

download() {
  curl -fL -o "$2" "$1"
}

staging_dir="$(mktemp -d)"
archive="/tmp/codex.tar.gz"
host_archive="/tmp/codex-code-mode-host.tar.gz"

cleanup() {
  rm -rf "$staging_dir" "$archive" "$host_archive"
}
trap cleanup EXIT

package_url="${CODEX_BASE_URL}/codex-package-${CODEX_TARGET}.tar.gz"
legacy_url="${CODEX_BASE_URL}/codex-${CODEX_TARGET}.tar.gz"
host_url="${CODEX_BASE_URL}/codex-code-mode-host-${CODEX_TARGET}.tar.gz"

if download "$package_url" "$archive"; then
  tar -xzf "$archive" -C "$staging_dir"
elif download "$legacy_url" "$archive"; then
  tar -xzf "$archive" -C "$staging_dir"
  if download "$host_url" "$host_archive"; then
    tar -xzf "$host_archive" -C "$staging_dir"
  else
    echo "Warning: codex-code-mode-host asset was not found for ${CODEX_TARGET}." >&2
  fi
else
  echo "Failed to download Codex for target ${CODEX_TARGET} from ${CODEX_BASE_URL}" >&2
  exit 1
fi

# Some package archives unpack as <temp>/codex-*/bin/codex instead of
# <temp>/bin/codex. Flatten that layout so the install path is stable.
if [ ! -x "$staging_dir/bin/codex" ]; then
  for candidate in "$staging_dir"/*/bin/codex; do
    [ -x "$candidate" ] || continue
    package_root="$(dirname "$(dirname "$candidate")")"
    flat_dir="$(mktemp -d)"
    cp -a "$package_root/." "$flat_dir/"
    rm -rf "$staging_dir"
    staging_dir="$flat_dir"
    break
  done
fi

# New packages use bin/codex and bin/codex-code-mode-host. Legacy archives use
# codex-<target> and optionally codex-code-mode-host-<target>. Normalize both.
if [ -x "$staging_dir/bin/codex" ]; then
  ln -sf bin/codex "$staging_dir/codex-${CODEX_TARGET}"
  if [ -x "$staging_dir/bin/codex-code-mode-host" ]; then
    ln -sf bin/codex-code-mode-host "$staging_dir/codex-code-mode-host"
  fi
elif [ -x "$staging_dir/codex-${CODEX_TARGET}" ]; then
  if [ -x "$staging_dir/codex-code-mode-host-${CODEX_TARGET}" ]; then
    ln -sf "codex-code-mode-host-${CODEX_TARGET}" "$staging_dir/codex-code-mode-host"
  fi
else
  echo "Downloaded Codex archive did not contain a known Codex executable layout." >&2
  find "$staging_dir" -maxdepth 3 -type f -print >&2
  exit 1
fi

rm -rf "$CODEX_DIR"
mkdir -p "$(dirname "$CODEX_DIR")"
mv "$staging_dir" "$CODEX_DIR"
trap - EXIT
rm -f "$archive" "$host_archive"
