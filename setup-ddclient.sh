#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

# Install ddclient if not present (non-interactive)
if ! command -v ddclient &> /dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ddclient
fi

CONFIG_FILE="/etc/ddclient.conf"
BACKUP_FILE="/etc/ddclient.conf.bak"

# Backup existing config
if [ -f "$CONFIG_FILE" ] && [ ! -f "$BACKUP_FILE" ]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# Prompt for credentials
read -rp "Enter Dynu hostname (e.g., yourhost.dynu.net): " hostname
read -rsp "Enter Dynu IP Update Password: " password
echo

# Create ddclient configuration
cat > "$CONFIG_FILE" << EOF
# Dynu DDNS Configuration
daemon=300
syslog=yes
ssl=yes

protocol=dyndns2
use=web, web=checkip.dynu.com/, web-skip='IP Address'
server=api.dynu.com
login=$hostname
password='$password'
$hostname
EOF

# Set secure permissions
chmod 600 "$CONFIG_FILE"

# Enable and restart ddclient
systemctl enable ddclient
systemctl restart ddclient

# Force immediate update
sleep 2
ddclient -force

echo "✓ ddclient configured for Dynu"
