#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${ROOT_DIR}/.medagent.pid"
HOST="${APP_HOST:-127.0.0.1}"
PORT="${APP_PORT:-5000}"

cd "${ROOT_DIR}"

if [[ -f "${PID_FILE}" ]]; then
  APP_PID="$(cat "${PID_FILE}")"
  if ps -p "${APP_PID}" > /dev/null 2>&1; then
    echo "MedAgent is running (PID ${APP_PID})"
    echo "URL: http://${HOST}:${PORT}"
    exit 0
  fi
  echo "MedAgent is not running (stale PID file found)."
  exit 1
fi

echo "MedAgent is not running."
exit 1
