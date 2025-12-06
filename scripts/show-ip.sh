#!/usr/bin/env bash
# show-ip.sh - print the machine's primary LAN IP and example URLs for phone access
IP=$(hostname -I | awk '{print $1}')
if [ -z "$IP" ]; then
  echo "Could not determine IP address. Make sure you're connected to a network." >&2
  exit 1
fi
cat <<EOF
Detected local IP: $IP

Open these on your phone (same Wi-Fi):
 - Client (Vite): http://$IP:5173
 - API: http://$IP:4000

If you plan to generate QR codes for testing, run:
 export QR_HOST="http://$IP:4000"
 node server/scripts/generate-qr.js

Note: ensure ports 5173 and 4000 are open on your firewall for the local network.
EOF
