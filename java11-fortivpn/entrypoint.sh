#!/bin/bash
set -e

# Load environment variables
if [ -f "/workspace/.env" ]; then
  export $(grep -v '^#' /workspace/.env | xargs)
elif [ -f "/home/$USER/.env" ]; then
  export $(grep -v '^#' /home/$USER/.env | xargs)
fi

# Validate
if [ -z "$VPN_HOST" ] || [ -z "$VPN_USER" ] || [ -z "$VPN_PASS" ] || [ -z "$VPN_CERT" ]; then
  echo "❌ Missing VPN credentials in .env"
  exit 1
fi

echo "🔐 Connecting to VPN at $VPN_HOST ..."
# Connect in background to keep container running
#openfortivpn "$VPN_HOST" -u "$VPN_USER" -p "$VPN_PASS" --persistent=1 &
#VPN_PID=$!
# NOTE: needs root → call via sudo
# --set-dns=1 requires resolvconf to be installed (we installed it)
sudo /usr/bin/openfortivpn "$VPN_HOST" \
  -u "$VPN_USER" -p "$VPN_PASS" --trusted-cert "$VPN_CERT" \
  --persistent=1 \
  --log-level=3 &
VPN_PID=$!

#--set-dns=1 --pppd-use-peerdns

# Wait for tunnel interface up
sleep 5
ip a | grep ppp || echo "⚠️ VPN interface not detected yet"

# Keep container alive while VPN runs
wait $VPN_PID
#while sleep 1000; do :; done
