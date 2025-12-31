#!/bin/bash
# Run all important setup scripts for Ubuntu server on laptop

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
chmod +x *.sh

echo "Installing packages..."
./install-packages.sh

echo "Disabling lid suspend..."
./disable-lid-suspend.sh

echo "Setting battery thresholds..."
./set-bat-thresholds.sh

echo "Configuring console blanking..."
./console-blank.sh

echo "Installing auto-shutdown on low battery..."
./auto-shutdown-low-battery.sh --install

echo "Enabling automatic security updates..."
./enable-auto-upgrades.sh

echo "✓ Setup complete"
