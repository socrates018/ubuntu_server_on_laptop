#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

# Install unattended-upgrades if missing
if ! command -v unattended-upgrade &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq unattended-upgrades > /dev/null
fi

# Enable automatic upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades

# Restart service to apply
systemctl restart unattended-upgrades
