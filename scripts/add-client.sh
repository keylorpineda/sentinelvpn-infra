set -e

CLIENT_NAME="$1"

if [ -z "$CLIENT_NAME" ]; then
  echo "Usage: $0 <client-name>"
  exit 1
fi

BASE_DIR="/opt/vpn"
CLIENT_DIR="$BASE_DIR/clients/$CLIENT_NAME"
STATE_FILE="$BASE_DIR/state/last_ip.txt"
WG_CONF="/etc/wireguard/wg0.conf"
SERVER_PUBLIC_KEY="$(wg show wg0 public-key)"
SERVER_ENDPOINT="20.220.16.129:51820"

if [ -d "$CLIENT_DIR" ]; then
  echo "Client already exists"
  exit 1
fi

LAST_IP=$(cat "$STATE_FILE")
CLIENT_IP="10.8.0.$LAST_IP"

NEXT_IP=$((LAST_IP + 1))
echo "$NEXT_IP" > "$STATE_FILE"

mkdir -p "$CLIENT_DIR"
chmod 700 "$CLIENT_DIR"

wg genkey | tee "$CLIENT_DIR/private.key" | wg pubkey > "$CLIENT_DIR/public.key"

CLIENT_PRIVATE_KEY=$(cat "$CLIENT_DIR/private.key")
CLIENT_PUBLIC_KEY=$(cat "$CLIENT_DIR/public.key")

cat >> "$WG_CONF" <<EOF

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32
EOF

wg-quick down wg0
wg-quick up wg0

cat > "$CLIENT_DIR/$CLIENT_NAME.conf" <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/24
DNS = 8.8.8.8
MTU = 1380
Table = off

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

chmod 600 "$CLIENT_DIR/$CLIENT_NAME.conf"

echo "Client '$CLIENT_NAME' created successfully"
echo "Config: $CLIENT_DIR/$CLIENT_NAME.conf"
