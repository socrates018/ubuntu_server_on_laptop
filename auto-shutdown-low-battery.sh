#!/bin/bash
# Auto-shutdown when battery < 30% (only when unplugged)

if [ "$1" = "--install" ]; then
    SCRIPT="$(readlink -f "$0")"
    (crontab -l 2>/dev/null | grep -v "$SCRIPT"; echo "* * * * * $SCRIPT") | crontab -
    echo "✓ Installed to cron (runs every minute)"
    exit 0
fi

BAT=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
AC=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -1)

[ "$AC" = "1" ] && exit 0  # On AC power, do nothing
[ -z "$BAT" ] && exit 0    # No battery found

if [ "$BAT" -lt 30 ]; then
    wall "WARNING: Battery ${BAT}%. Shutting down NOW!"
    shutdown -h now
fi
