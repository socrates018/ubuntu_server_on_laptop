#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

CONFIG_FILE="/etc/systemd/resolved.conf"
BACKUP_FILE="/etc/systemd/resolved.conf.bak"

# Backup the current configuration file
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# Enable LLMNR in resolved.conf
# Handle both commented out lines (#LLMNR=...) and existing lines
if grep -q "^#LLMNR=" "$CONFIG_FILE"; then
    sed -i 's/^#LLMNR=.*/LLMNR=yes/' "$CONFIG_FILE"
elif grep -q "^LLMNR=" "$CONFIG_FILE"; then
    sed -i 's/^LLMNR=.*/LLMNR=yes/' "$CONFIG_FILE"
else
    # If the line doesn't exist at all, add it under [Resolve]
    sed -i '/\[Resolve\]/a LLMNR=yes' "$CONFIG_FILE"
fi

# Restart the service to apply changes
systemctl restart systemd-resolved

# Open the firewall port (UDP 5355) if ufw is active
if systemctl is-active --quiet ufw; then
    ufw allow 5355/udp
fi

echo "✓ LLMNR enabled"