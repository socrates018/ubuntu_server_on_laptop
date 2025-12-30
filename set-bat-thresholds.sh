#!/bin/bash
set -euo pipefail

# Script to install TLP and set battery charge threshold

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# Check if TLP is installed
if ! command -v tlp &> /dev/null; then
    echo "Installing TLP..."
    apt-get update && apt-get install -y tlp
fi

# Enable and start TLP service
echo "Enabling TLP..."
systemctl enable tlp
systemctl start tlp

# Modify TLP config
CONFIG_FILE="/etc/tlp.conf"
BACKUP_FILE="/etc/tlp.conf.bak"

# Backup original config
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backing up original TLP config..."
    cp "$CONFIG_FILE" "$BACKUP_FILE"
else
    echo "Backup already exists at $BACKUP_FILE"
fi

# Function to set or replace config lines
set_tlp_config() {
    local key="$1"
    local value="$2"
    if grep -qE "^\s*#?\s*$key=" "$CONFIG_FILE"; then
        sed -i "s|^\s*#\?\s*$key=.*|$key=$value|" "$CONFIG_FILE"
    else
        echo "$key=$value" | tee -a "$CONFIG_FILE" > /dev/null
    fi
}

# Get thresholds with defaults
read -rp "Enter START charge threshold (default 75): " start_thresh
read -rp "Enter STOP charge threshold (default 80): " stop_thresh

# Apply defaults if empty
start_thresh=${start_thresh:-75}
stop_thresh=${stop_thresh:-80}

# Set the thresholds
echo "Setting thresholds - Start: ${start_thresh}% Stop: ${stop_thresh}%"
set_tlp_config START_CHARGE_THRESH_BAT0 "$start_thresh"
set_tlp_config STOP_CHARGE_THRESH_BAT0 "$stop_thresh"
set_tlp_config START_CHARGE_THRESH_BAT1 "$start_thresh"
set_tlp_config STOP_CHARGE_THRESH_BAT1 "$stop_thresh"

# Restart TLP to apply config changes
echo "Restarting TLP service..."
systemctl restart tlp

# Show status and battery threshold info
echo ""
echo "----------------------------------------"
echo "TLP Service Status:"
echo "----------------------------------------"
systemctl status tlp --no-pager

echo ""
echo "----------------------------------------"
echo "TLP Battery Charge Thresholds:"
echo "----------------------------------------"
tlp-stat -b | grep -i 'charge'

echo ""
echo "TLP setup complete."
