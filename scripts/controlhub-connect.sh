#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <control-hub-ip>"
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found on PATH"
  exit 1
fi

CONTROL_HUB_IP="$1"
ADB_TARGET="${CONTROL_HUB_IP}:5555"

echo "Connecting to ${ADB_TARGET}..."
adb connect "${ADB_TARGET}"
adb wait-for-device
adb devices
