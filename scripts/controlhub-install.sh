#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <control-hub-ip>"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${ROOT_DIR}/scripts/controlhub-connect.sh" "$1"

cd "${ROOT_DIR}"
./gradlew :TeamCode:installDebug
