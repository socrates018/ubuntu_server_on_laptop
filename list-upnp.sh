#!/bin/bash
set -u

# Auto-install miniupnpc if missing
if ! command -v upnpc &> /dev/null; then
    echo "upnpc not found. Installing miniupnpc..."
    sudo apt-get update && sudo apt-get install -y miniupnpc
fi

echo "==========================="
echo "📡 Current UPnP Mappings:"
echo "==========================="

# Extract the External IP address
external_ip=$(upnpc -l | grep "ExternalIPAddress" | awk -F" = " '{print $2}')
if [[ -z "$external_ip" ]]; then
    echo "❌ Could not retrieve External IP address."
    exit 1
fi

# List each mapping
upnpc -l | awk -v ip="$external_ip" '
    /^[[:space:]]*[0-9]+ / {
        split($3, a, "->")
        printf "%s %s:%s -> %s\n", $2, ip, a[1], a[2]
    }
'
