#!/bin/bash

# ============================
# WireGuard Client Remover
# Level: MID
# ============================

set -e

CLIENT_NAME="$1"

if [ -z "$CLIENT_NAME" ]; then
  echo "Usage: $0 <client-name>"
  exit 1
fi

BASE_DIR="/opt/vpn"
CLIENT_DIR="$BASE_DIR/clients/$CLIENT_NAME"
WG_CONF="/etc/wireguard/wg0.conf"

if [ ! -d "$CLIENT_DIR" ]; then
  echo "Client '$CLIENT_NAME' does not exist"
  exit 1
fi

CLIENT_PUBLIC_KEY=$(cat "$CLIENT_DIR/public.key")

# Backup config
cp "$WG_CONF" "$WG_CONF.bak.$(date +%s)"

# Remove peer block from wg0.conf
awk -v key="$CLIENT_PUBLIC_KEY" '
BEGIN { skip=0 }
/^\[Peer\]/ { block=$0; skip=0 }
/PublicKey =/ {
  if ($0 ~ key) skip=1
}
{
  if (skip==0) print
}
' "$WG_CONF" > /tmp/wg0.conf.tmp

mv /tmp/wg0.conf.tmp "$WG_CONF"

# Reload WireGuard
wg-quick down wg0
wg-quick up wg0

# Remove client files
rm -rf "$CLIENT_DIR"

echo "Client '$CLIENT_NAME' removed successfully"
