#!/bin/bash
set -euo pipefail

# Auto-install TLP if missing
if ! command -v tlp &> /dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq tlp > /dev/null
fi

# Show battery status using tlp
sudo tlp-stat -b | grep -E "Battery|Charge" || echo "No battery information found."

