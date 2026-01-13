#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install-temurin.sh <major> [options]

Download and install Temurin JDK from GitHub releases for Debian/Ubuntu.

Options:
  -v, --version <version>   Full version (e.g. 17.0.9+9). If omitted, uses latest.
  -d, --install-dir <path>  Install root (default: /opt/temurin).
  --arch <x64|aarch64>      Override architecture (default: detect via uname -m).
  -h, --help                Show this help.

Examples:
  ./install-temurin.sh 17
  ./install-temurin.sh 11 --version 11.0.22+7
  ./install-temurin.sh 21 --install-dir /usr/lib/jvm
USAGE
}

die() {
  echo "Error: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

major="$1"
shift

version=""
install_root="/opt/temurin"
arch=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--version)
      version="${2:-}"
      [[ -n "$version" ]] || die "Missing value for --version"
      shift 2
      ;;
    -d|--install-dir)
      install_root="${2:-}"
      [[ -n "$install_root" ]] || die "Missing value for --install-dir"
      shift 2
      ;;
    --arch)
      arch="${2:-}"
      [[ -n "$arch" ]] || die "Missing value for --arch"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

case "$major" in
  11|17|21) ;;
  *) die "Unsupported major version: $major (use 11, 17, or 21)";;
esac

if [[ -n "$version" && "$version" == *%2B* ]]; then
  die "Use '+' in --version (e.g. 17.0.9+9), not '%2B'"
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    debian|ubuntu) ;;
    *) echo "Warning: This script targets Debian/Ubuntu; detected ID=${ID:-unknown}." >&2 ;;
  esac
fi

if [[ -z "$arch" ]]; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) arch="x64" ;;
    aarch64|arm64) arch="aarch64" ;;
    *) die "Unsupported architecture: $arch" ;;
  esac
else
  case "$arch" in
    x64|aarch64) ;;
    *) die "Unsupported --arch value: $arch (use x64 or aarch64)" ;;
  esac
fi

need_cmd curl
need_cmd tar

repo="temurin${major}-binaries"
platform="linux"
jvm="hotspot"

if [[ -n "$version" ]]; then
  tag="jdk-${version}"
  tag_url="${tag//+/%2B}"
  version_underscored="${version//+/_}"
  asset="OpenJDK${major}U-jdk_${arch}_${platform}_${jvm}_${version_underscored}.tar.gz"
  url="https://github.com/adoptium/${repo}/releases/download/${tag_url}/${asset}"
else
  api="https://api.github.com/repos/adoptium/${repo}/releases/latest"
  url="$(curl -fsSL "$api" | \
    grep -Eo "https://github.com/adoptium/${repo}/releases/download/[^\" ]+/OpenJDK${major}U-jdk_${arch}_${platform}_${jvm}_[^\" ]+\\.tar\\.gz" | \
    head -n 1)"
  [[ -n "$url" ]] || die "Could not find a matching asset in latest release. Try --version."
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

tarball="${tmp_dir}/temurin-${major}.tar.gz"
echo "Downloading: $url"
curl -fL --retry 3 --retry-delay 1 -o "$tarball" "$url"

if ! tar -tzf "$tarball" >/dev/null 2>&1; then
  echo "Error: downloaded file is not a valid .tar.gz archive." >&2
  if command -v file >/dev/null 2>&1; then
    file "$tarball" >&2
  fi
  echo "First 1KB (printable chars only):" >&2
  head -c 1024 "$tarball" | sed -e 's/[^[:print:]\t]/./g' >&2
  exit 1
fi

top_dir="$(tar -tzf "$tarball" | head -n 1 | cut -d/ -f1 || true)"
[[ -n "$top_dir" ]] || die "Unable to determine archive top directory"

dest_dir="${install_root}/${top_dir}"
if [[ -e "$dest_dir" ]]; then
  die "Target exists: $dest_dir (remove it or choose a different --install-dir)"
fi

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

$SUDO mkdir -p "$install_root"
$SUDO tar -xzf "$tarball" -C "$install_root"
$SUDO ln -sfn "$dest_dir" "${install_root}/jdk-${major}"

echo "Installed JDK ${major} to $dest_dir"
echo "Symlinked ${install_root}/jdk-${major} -> $dest_dir"
