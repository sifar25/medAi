#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${ROOT_DIR}/.medagent.log"

cd "${ROOT_DIR}"

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "No log file yet. Start the app with ./up.sh first."
  exit 1
fi

tail -f "${LOG_FILE}"
