#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

# Install dependencies
if ! command -v upnpc &> /dev/null || ! command -v crontab &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq miniupnpc cron > /dev/null
fi

KEEPALIVE="/usr/local/bin/upnp-keepalive.sh"
UPNPC=$(command -v upnpc)

# Initialize keepalive script
if [ ! -f "$KEEPALIVE" ]; then
    echo "#!/bin/bash" > "$KEEPALIVE"
    chmod +x "$KEEPALIVE"
fi

# Add to cron if not present
if ! crontab -l 2>/dev/null | grep -q "$KEEPALIVE"; then
    (crontab -l 2>/dev/null; echo "@hourly $KEEPALIVE >/dev/null 2>&1") | crontab -
fi

echo "Enter ports to forward (Press Enter to finish)"

while true; do
    read -rp "Port: " port
    [ -z "$port" ] && break
    
    read -rp "Protocol (TCP/UDP) [TCP]: " proto
    proto=${proto:-TCP}
    
    CMD="$UPNPC -e 'UPnP-$port' -r $port $proto"
    
    if eval "$CMD" > /dev/null 2>&1; then
        echo "Mapped $port/$proto"
        # Add to keepalive if not present
        if ! grep -Fq "$CMD" "$KEEPALIVE"; then
            echo "$CMD" >> "$KEEPALIVE"
        fi
    else
        echo "Failed to map $port/$proto"
    fi
done
