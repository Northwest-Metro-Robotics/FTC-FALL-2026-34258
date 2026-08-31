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

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTROL_HUB_IP="$1"
ADB_TARGET="${CONTROL_HUB_IP}:5555"
APP_ID="com.qualcomm.ftcrobotcontroller"
LAUNCH_ACTIVITY="org.firstinspires.ftc.robotcontroller.internal.PermissionValidatorWrapper"
DEBUG_PORT="5005"

"${ROOT_DIR}/scripts/controlhub-connect.sh" "${CONTROL_HUB_IP}"

echo "Stopping ${APP_ID}..."
adb -s "${ADB_TARGET}" shell am force-stop "${APP_ID}" >/dev/null 2>&1 || true

echo "Starting ${APP_ID} in debug mode..."
adb -s "${ADB_TARGET}" shell am start -D -n "${APP_ID}/${LAUNCH_ACTIVITY}" >/dev/null

echo "Waiting for app process..."
APP_PID=""
for _ in {1..20}; do
  APP_PID="$(adb -s "${ADB_TARGET}" shell pidof "${APP_ID}" | tr -d '\r' || true)"
  if [[ -n "${APP_PID}" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "${APP_PID}" ]]; then
  echo "Unable to find PID for ${APP_ID}"
  exit 1
fi

echo "Forwarding localhost:${DEBUG_PORT} to jdwp:${APP_PID}..."
adb -s "${ADB_TARGET}" forward --remove "tcp:${DEBUG_PORT}" >/dev/null 2>&1 || true
adb -s "${ADB_TARGET}" forward "tcp:${DEBUG_PORT}" "jdwp:${APP_PID}"

echo "Debugger ready on localhost:${DEBUG_PORT}"
