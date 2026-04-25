#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./down.sh                            Stop app only
#   ./down.sh --clean-runtime            Stop app and remove runtime artifacts
#   ./down.sh --reset-data               Force reset patients.csv from patients_seed.csv
#   ./down.sh --fresh                    Stop app + clean runtime + reset data

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${ROOT_DIR}/.medagent.pid"
LOG_FILE="${ROOT_DIR}/.medagent.log"
MODEL_FILE="${ROOT_DIR}/medication_model.pkl"
DATA_FILE="${ROOT_DIR}/patients.csv"
SEED_SCRIPT="${ROOT_DIR}/seed_data.py"

pick_python() {
  for candidate in python3.11 python3.12 python3.10 python3 python; do
    if command -v "${candidate}" > /dev/null 2>&1; then
      echo "${candidate}"
      return
    fi
  done

  echo ""
}

CLEAN_RUNTIME=false
RESET_DATA=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean-runtime)
      CLEAN_RUNTIME=true
      shift
      ;;
    --reset-data)
      RESET_DATA=true
      shift
      ;;
    --fresh)
      CLEAN_RUNTIME=true
      RESET_DATA=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./down.sh [--clean-runtime] [--reset-data] [--fresh]"
      echo ""
      echo "Options:"
      echo "  --clean-runtime   Remove model/log/pid/cache after stopping"
      echo "  --reset-data      Recreate patients.csv from patients_seed.csv"
      echo "  --fresh           Equivalent to --clean-runtime --reset-data"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run ./down.sh --help for usage."
      exit 1
      ;;
  esac
done

cd "${ROOT_DIR}"

if [[ ! -f "${PID_FILE}" ]]; then
  echo "MedAgent is not running (no PID file found)."
else
  APP_PID="$(cat "${PID_FILE}")"
  if ps -p "${APP_PID}" > /dev/null 2>&1; then
    kill "${APP_PID}"
    for _ in {1..10}; do
      if ! ps -p "${APP_PID}" > /dev/null 2>&1; then
        break
      fi
      sleep 1
    done
    if ps -p "${APP_PID}" > /dev/null 2>&1; then
      kill -9 "${APP_PID}" >/dev/null 2>&1 || true
    fi
    echo "Stopped MedAgent (PID ${APP_PID})."
  else
    echo "Process ${APP_PID} is not running. Cleaning stale PID file."
  fi
fi

rm -f "${PID_FILE}"

if [[ "${CLEAN_RUNTIME}" == "true" ]]; then
  echo "Cleaning runtime artifacts..."
  rm -f "${MODEL_FILE}" "${LOG_FILE}"
  rm -rf "${ROOT_DIR}/__pycache__"
fi

if [[ "${RESET_DATA}" == "true" ]]; then
  echo "Resetting dataset to default seed..."
  if [[ -x "${ROOT_DIR}/.venv/bin/python" ]]; then
    "${ROOT_DIR}/.venv/bin/python" "${SEED_SCRIPT}" --force
  else
    PYTHON_BIN="$(pick_python)"
    if [[ -z "${PYTHON_BIN}" ]]; then
      echo "No compatible Python interpreter found to reset the dataset."
      exit 1
    fi
    "${PYTHON_BIN}" "${SEED_SCRIPT}" --force
  fi
  echo "Dataset reset complete (${DATA_FILE})."
fi
