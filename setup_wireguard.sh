#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

# Auto-install curl
if ! command -v curl &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq curl > /dev/null
fi

# Download installer
curl -sL "https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh" -o wireguard-install.sh
chmod +x wireguard-install.sh

# Run (headless by default)
export HEADLESS_INSTALL=y
./wireguard-install.sh