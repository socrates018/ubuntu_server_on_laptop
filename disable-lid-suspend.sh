#!/bin/bash
set -euo pipefail

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

CONFIG_FILE="/etc/systemd/logind.conf"
BACKUP_FILE="/etc/systemd/logind.conf.bak"

# Backup the original config file
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backing up $CONFIG_FILE to $BACKUP_FILE..."
    cp "$CONFIG_FILE" "$BACKUP_FILE"
else
    echo "Backup already exists at $BACKUP_FILE"
fi

# Function to update or append a config line
set_config_value() {
    local key="$1"
    local value="$2"

    if grep -qE "^\s*#?\s*$key=" "$CONFIG_FILE"; then
        sed -i "s|^\s*#\?\s*$key=.*|$key=$value|" "$CONFIG_FILE"
    else
        echo "$key=$value" | tee -a "$CONFIG_FILE" > /dev/null
    fi
}

# Set desired values
echo "Updating logind.conf settings..."
set_config_value HandleLidSwitch ignore
set_config_value HandleLidSwitchDocked ignore
set_config_value LidSwitchIgnoreInhibited no

# Restart systemd-logind to apply changes
echo "Restarting systemd-logind service..."
systemctl restart systemd-logind

echo "Lid close behavior set to ignore. LidSwitchIgnoreInhibited=no applied."
