#!/bin/bash

# Script to disable suspend or any action on lid close on Ubuntu Server
# and ensure LidSwitchIgnoreInhibited=no

CONFIG_FILE="/etc/systemd/logind.conf"
BACKUP_FILE="/etc/systemd/logind.conf.bak"

# Backup the original config file
echo "Backing up $CONFIG_FILE to $BACKUP_FILE..."
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

# Function to update or append a config line
set_config_value() {
    local key="$1"
    local value="$2"

    if grep -qE "^\s*#?\s*$key=" "$CONFIG_FILE"; then
        sudo sed -i "s|^\s*#\?\s*$key=.*|$key=$value|" "$CONFIG_FILE"
    else
        echo "$key=$value" | sudo tee -a "$CONFIG_FILE" > /dev/null
    fi
}

# Set desired values
echo "Updating logind.conf settings..."
set_config_value HandleLidSwitch ignore
set_config_value HandleLidSwitchDocked ignore
set_config_value LidSwitchIgnoreInhibited no

# Restart systemd-logind to apply changes
echo "Restarting systemd-logind service..."
sudo systemctl restart systemd-logind

echo "Lid close behavior set to ignore. LidSwitchIgnoreInhibited=no applied."
