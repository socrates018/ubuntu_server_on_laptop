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

# List mappings
upnpc -l | awk -v ip="$external_ip" '/^ *[0-9]+ / {
    split($3, a, "->")
    print $2, ip ":" a[1], "->", a[2]
}'

echo
echo "🚧 Attempting to delete UPnP mappings..."

# Get list of mappings to delete
map_list=$(upnpc -l | awk '/^ *[0-9]+ / {split($3, a, "->"); print $2, a[1]}')

if [[ -z "$map_list" ]]; then
    echo "✅ No UPnP mappings found to delete."
    exit 0
fi

# Iterate and delete
while read -r proto extport; do
    echo -n "Deleting $proto $extport... "
    if upnpc -d "$extport" "$proto" | grep -q "failed"; then
        echo "❌ Failed"
    else
        echo "✅ Removed"
    fi
done <<< "$map_list"

echo
echo "==========================="
echo "📋 UPnP Mappings After Cleanup:"
echo "==========================="

# List mappings again
upnpc -l | awk -v ip="$external_ip" '/^ *[0-9]+ / {
    split($3, a, "->")
    print $2, ip ":" a[1], "->", a[2]
}'
