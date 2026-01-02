#!/bin/bash
[ "$EUID" -ne 0 ] && echo "Run with sudo" && exit 1

apt-get update -qq
apt-get install -y -qq ddclient cockpit curl git htop net-tools ufw wireguard neofetch nano unattended-upgrades acpi tlp miniupnpc cron

systemctl restart cockpit.socket 2>/dev/null

# Enable firewall access for Cockpit
if systemctl is-active --quiet ufw; then
    ufw allow 9090/tcp comment 'Cockpit Web Interface'
fi
