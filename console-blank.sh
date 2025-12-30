#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

# Set console blanking to 30 seconds in GRUB
# This uses the kernel's native power saving which wakes on keypress
if grep -q "consoleblank=" /etc/default/grub; then
    sed -i 's/consoleblank=[0-9]*/consoleblank=30/' /etc/default/grub
else
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=30 /' /etc/default/grub
fi

update-grub > /dev/null 2>&1

# Immediate blank (wakes on keypress)
# We redirect to /dev/tty1 because this script is likely run via SSH
# and we want to affect the physical console.
setterm --blank 1 --powersave on --powerdown 1 > /dev/tty1 2>/dev/null || true
setterm --blank force > /dev/tty1 2>/dev/null || true
