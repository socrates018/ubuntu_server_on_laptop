#!/bin/bash

# Check if TLP is installed
if ! command -v tlp &> /dev/null
then
    echo "TLP could not be found. Please install it first."
    exit 1
fi

# Show battery status using tlp
echo "Battery status:"
sudo tlp-stat -b | grep -E "Battery|Charge"

