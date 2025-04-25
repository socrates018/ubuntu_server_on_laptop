#!/bin/bash

# Script to install TLP and set battery charge threshold to 80%

echo "Installing TLP..."
sudo apt update
sudo apt install -y tlp

# Enable and start TLP service
echo "Enabling TLP..."
sudo systemctl enable tlp
sudo systemctl start tlp

# Modify TLP config
CONFIG_FILE="/etc/tlp.conf"
BACKUP_FILE="/etc/tlp.conf.bak"

# Backup original config
echo "Backing up original TLP config..."
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

# Function to set or replace config lines
set_tlp_config() {
    local key="$1"
    local value="$2"
    if grep -qE "^\s*#?\s*$key=" "$CONFIG_FILE"; then
        sudo sed -i "s|^\s*#\?\s*$key=.*|$key=$value|" "$CONFIG_FILE"
    else
        echo "$key=$value" | sudo tee -a "$CONFIG_FILE" > /dev/null
    fi
}

# Set thresholds to 80% for supported hardware (e.g., ThinkPads)
echo "Setting battery charge thresholds..."
set_tlp_config START_CHARGE_THRESH_BAT0 75
set_tlp_config STOP_CHARGE_THRESH_BAT0 80
set_tlp_config START_CHARGE_THRESH_BAT1 75
set_tlp_config STOP_CHARGE_THRESH_BAT1 80

# Restart TLP to apply config changes
echo "Restarting TLP service..."
sudo systemctl restart tlp

# Show status and battery threshold info
echo ""
echo "----------------------------------------"
echo "TLP Service Status:"
echo "----------------------------------------"
sudo systemctl status tlp --no-pager

echo ""
echo "----------------------------------------"
echo "TLP Battery Charge Thresholds:"
echo "----------------------------------------"
sudo tlp-stat -b | grep -i 'charge'

echo ""
echo "TLP setup complete. Threshold set to 80% (if supported)."
