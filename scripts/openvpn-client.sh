#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${OPENVPN_CONFIG_DIR:-/etc/openvpn/client}"
RUN_DIR="${OPENVPN_RUN_DIR:-/run/openvpn-client}"
LOG_FILE="${OPENVPN_LOG_FILE:-/var/log/openvpn-client.log}"
PID_FILE="$RUN_DIR/openvpn.pid"

command="${1:-start}"
case "$command" in
  start|stop|restart|status)
    shift || true
    ;;
  *)
    command="start"
    ;;
esac

if [ "$(id -u)" != "0" ]; then
  exec sudo /usr/local/bin/ovpn "$command" "$@"
fi

find_config() {
  local config="${1:-${OPENVPN_CONFIG:-}}"

  if [ -z "$config" ]; then
    local configs=("$CONFIG_DIR"/*.ovpn "$CONFIG_DIR"/*.conf)

    for candidate in "${configs[@]}"; do
      if [ -f "$candidate" ]; then
        config="$candidate"
        break
      fi
    done
  fi

  if [ -z "$config" ] || [ ! -f "$config" ]; then
    echo "No OpenVPN config found. Pass one as an argument or mount *.ovpn/*.conf into $CONFIG_DIR." >&2
    exit 1
  fi

  printf '%s\n' "$config"
}

is_running() {
  [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

start_openvpn() {
  if is_running; then
    echo "OpenVPN is already running with PID $(cat "$PID_FILE")."
    return
  fi

  local config
  config="$(find_config "${1:-}")"

  install -d -m 755 "$RUN_DIR"
  touch "$LOG_FILE"

  /usr/sbin/openvpn \
    --config "$config" \
    --daemon openvpn-client \
    --writepid "$PID_FILE" \
    --log-append "$LOG_FILE"

  echo "OpenVPN started with config $config."
}

stop_openvpn() {
  if ! is_running; then
    rm -f "$PID_FILE"
    echo "OpenVPN is not running."
    return
  fi

  local pid
  pid="$(cat "$PID_FILE")"
  kill "$pid"

  for _ in $(seq 1 20); do
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f "$PID_FILE"
      echo "OpenVPN stopped."
      return
    fi
    sleep 0.5
  done

  echo "OpenVPN did not stop cleanly; sending SIGKILL." >&2
  kill -9 "$pid" 2>/dev/null || true
  rm -f "$PID_FILE"
}

case "$command" in
  start)
    start_openvpn "${1:-}"
    ;;
  stop)
    stop_openvpn
    ;;
  restart)
    stop_openvpn
    start_openvpn "${1:-}"
    ;;
  status)
    if is_running; then
      echo "OpenVPN is running with PID $(cat "$PID_FILE")."
    else
      echo "OpenVPN is not running."
      exit 1
    fi
    ;;
esac
