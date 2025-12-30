#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

# Set console blanking to 60 seconds in GRUB
# This uses the kernel's native power saving which wakes on keypress
if ! grep -q "consoleblank=60" /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=60 /' /etc/default/grub
    update-grub > /dev/null 2>&1
    echo "Reboot required to apply blanking settings."
fi

# Immediate blank (wakes on keypress)
setterm --blank 1 --powersave on --powerdown 1
