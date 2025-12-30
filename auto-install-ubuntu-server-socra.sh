#!/bin/bash
set -euo pipefail

# Check dependencies
if ! command -v xorriso &> /dev/null || ! command -v 7z &> /dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq xorriso p7zip-full > /dev/null
fi

# Check if the generator script exists
if [ ! -f "./ubuntu-autoinstall-generator.sh" ]; then
    echo "Error: ./ubuntu-autoinstall-generator.sh not found."
    exit 1
fi

sudo SKIP_VERIFY=true ./ubuntu-autoinstall-generator.sh \
  -k \
  -a \
  -u ~/autoinstall-config/user-data \
  -m ~/autoinstall-config/meta-data \
  -s /mnt/d/socra/Downloads/ubuntu-24.04.3-live-server-amd64.iso \
  -d /mnt/d/socra/Downloads/ubuntu-auto.iso
  