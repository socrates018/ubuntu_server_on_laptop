#!/bin/bash
set -euo pipefail

# Auto-install TLP if missing
if ! command -v tlp &> /dev/null; then
    echo "TLP not found. Installing..."
    sudo apt-get update && sudo apt-get install -y tlp
fi

# Show battery status using tlp
echo "Checking battery status..."
sudo tlp-stat -b | grep -E "Battery|Charge" || echo "No battery information found."

