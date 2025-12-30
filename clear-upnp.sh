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

# Get list of mappings to delete
map_list=$(upnpc -l | awk '/^ *[0-9]+ / {split($3, a, "->"); print $2, a[1]}')

if [[ -n "$map_list" ]]; then
    # Iterate and delete
    while read -r proto extport; do
        upnpc -d "$extport" "$proto" > /dev/null
    done <<< "$map_list"
fi

# List mappings again
upnpc -l | awk -v ip="$external_ip" '/^ *[0-9]+ / {
    split($3, a, "->")
    print $2, ip ":" a[1], "->", a[2]
}'
