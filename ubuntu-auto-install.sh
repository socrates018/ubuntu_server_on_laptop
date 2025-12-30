#!/bin/bash
set -euo pipefail

# Auto-install Docker if missing
if ! command -v docker &> /dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq docker.io > /dev/null
fi

CONTAINER="ubuntu-autoinstaller-22.04"
IMAGE="jetfuls/ubuntu-autoinstaller:1.0-ubuntu22.04"
PORT=8080

# Start container if not running
if ! sudo docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
        sudo docker start "$CONTAINER" > /dev/null
    else
        sudo docker run -d -p "${PORT}:8080" --name "$CONTAINER" "$IMAGE" > /dev/null
    fi
fi

echo "http://localhost:${PORT}"
