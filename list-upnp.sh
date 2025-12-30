#!/bin/bash
set -u

# Auto-install miniupnpc if missing
if ! command -v upnpc &> /dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq miniupnpc > /dev/null
fi

# Extract the External IP address
external_ip=$(upnpc -l | grep "ExternalIPAddress" | awk -F" = " '{print $2}')
if [[ -z "$external_ip" ]]; then
    exit 1
fi

# List each mapping
upnpc -l | awk -v ip="$external_ip" '
    /^[[:space:]]*[0-9]+ / {
        split($3, a, "->")
        printf "%s %s:%s -> %s\n", $2, ip, a[1], a[2]
    }
'
