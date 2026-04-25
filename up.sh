#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./up.sh                    Start app (safe defaults)
#   ./up.sh --reseed           Force reseed patients.csv from patients_seed.csv
#   ./up.sh --retrain          Force model retraining
#   ./up.sh --fresh            Stop app and reset runtime/data before startup
#   ./up.sh --skip-install     Skip pip install

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${ROOT_DIR}/.venv"
PID_FILE="${ROOT_DIR}/.medagent.pid"
PORT_FILE="${ROOT_DIR}/.medagent.port"
LOG_FILE="${ROOT_DIR}/.medagent.log"
HOST="${APP_HOST:-127.0.0.1}"
PORT="${APP_PORT:-5000}"
DEMO_USERNAME="${DEMO_USERNAME:-clinician}"
DEMO_PASSWORD="${DEMO_PASSWORD:-medagent123}"
DEMO_ACCOUNTS="${DEMO_ACCOUNTS:-}"
MODEL_FILE="${ROOT_DIR}/medication_model.pkl"
DATA_FILE="${ROOT_DIR}/patients.csv"
AUTO_PORT_SELECTED=false

port_conflict_details() {
  if command -v lsof > /dev/null 2>&1; then
    lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN 2>/dev/null | tail -n +2 || true
  fi
}

port_is_available() {
  if ! command -v lsof > /dev/null 2>&1; then
    return 0
  fi

  if lsof -nP -iTCP:"$1" -sTCP:LISTEN > /dev/null 2>&1; then
    return 1
  fi

  return 0
}

medagent_cwd_for_pid() {
  if ! command -v lsof > /dev/null 2>&1; then
    return 1
  fi

  lsof -a -p "$1" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -n 1
}

list_medagent_pids() {
  if ! command -v pgrep > /dev/null 2>&1; then
    return 0
  fi

  local pid
  while read -r pid; do
    [[ -z "${pid}" ]] && continue
    [[ "${pid}" == "$$" ]] && continue
    local cwd
    cwd="$(medagent_cwd_for_pid "${pid}" || true)"
    if [[ -n "${cwd}" ]] && [[ "$(basename "${cwd}")" == "$(basename "${ROOT_DIR}")" ]]; then
      echo "${pid}"
    fi
  done < <(pgrep -f '[Pp]ython app\.py' || true)
}

stop_medagent_process() {
  local pid="$1"
  kill "${pid}" >/dev/null 2>&1 || true
  for _ in {1..10}; do
    if ! ps -p "${pid}" > /dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  kill -9 "${pid}" >/dev/null 2>&1 || true
}

cleanup_existing_medagent_instances() {
  local found=false
  local pid
  while read -r pid; do
    [[ -z "${pid}" ]] && continue
    if [[ "${found}" == false ]]; then
      echo "Stopping existing MedAgent instance(s) before startup..."
      found=true
    fi
    stop_medagent_process "${pid}"
    echo "Stopped MedAgent process ${pid}."
  done < <(list_medagent_pids)

  rm -f "${PID_FILE}" "${PORT_FILE}"
}

select_startup_port() {
  if [[ -n "${APP_PORT:-}" ]]; then
    if ! port_is_available "${PORT}"; then
      echo "Port ${PORT} is already in use."
      echo "Current listener(s):"
      port_conflict_details
      exit 1
    fi
    return
  fi

  local candidate
  for candidate in 5000 5001 5002 5003 5004 5005; do
    if port_is_available "${candidate}"; then
      PORT="${candidate}"
      if [[ "${PORT}" != "5000" ]]; then
        AUTO_PORT_SELECTED=true
      fi
      return
    fi
  done

  echo "No free MedAgent startup port found in the range 5000-5005."
  exit 1
}

wait_for_health() {
  if ! command -v curl > /dev/null 2>&1; then
    echo "curl not found; skipping automatic health check."
    return 0
  fi

  local health_url="http://${HOST}:${PORT}/health"
  for attempt in {1..30}; do
    if curl -sf "${health_url}" > /dev/null; then
      echo "Health check passed: ${health_url}"
      return 0
    fi
    sleep 1
  done

  echo "Health check failed after startup: ${health_url}"
  echo "Recent logs:"
  tail -n 20 "${LOG_FILE}" || true
  return 1
}

RESEED=false
FORCE_RETRAIN=false
SKIP_INSTALL=false
FRESH_START=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reseed)
      RESEED=true
      shift
      ;;
    --retrain)
      FORCE_RETRAIN=true
      shift
      ;;
    --fresh)
      FRESH_START=true
      RESEED=true
      FORCE_RETRAIN=true
      shift
      ;;
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./up.sh [--reseed] [--retrain] [--fresh] [--skip-install]"
      echo ""
      echo "Options:"
      echo "  --reseed        Force recreate patients.csv from patients_seed.csv"
      echo "  --retrain       Force model retraining"
      echo "  --fresh         Stop app and reset runtime/data, then start fresh"
      echo "  --skip-install  Skip dependency installation"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run ./up.sh --help for usage."
      exit 1
      ;;
  esac
done

pick_python() {
  if [[ -n "${PYTHON_BIN:-}" ]] && command -v "${PYTHON_BIN}" > /dev/null 2>&1; then
    echo "${PYTHON_BIN}"
    return
  fi

  for candidate in python3.11 python3.12 python3.10 python3 python; do
    if command -v "${candidate}" > /dev/null 2>&1; then
      echo "${candidate}"
      return
    fi
  done

  echo ""
}

venv_needs_rebuild() {
  if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
    return 0
  fi

  if [[ -f "${VENV_DIR}/pyvenv.cfg" ]] && ! grep -Fq "${VENV_DIR}" "${VENV_DIR}/pyvenv.cfg"; then
    return 0
  fi

  if [[ -f "${VENV_DIR}/bin/pip" ]]; then
    local pip_shebang
    pip_shebang="$(head -n 1 "${VENV_DIR}/bin/pip" 2>/dev/null || true)"
    if [[ "${pip_shebang}" == '#!'* ]] && [[ "${pip_shebang}" != "#!${VENV_DIR}/bin/"* ]]; then
      return 0
    fi
  fi

  return 1
}

PYTHON_BIN="$(pick_python)"

if [[ -z "${PYTHON_BIN}" ]]; then
  echo "No compatible Python interpreter found. Install Python 3.10+ and retry."
  exit 1
fi

cd "${ROOT_DIR}"

if [[ "${FRESH_START}" == "true" ]]; then
  echo "Preparing fresh startup state..."
  "${ROOT_DIR}/down.sh" --clean-runtime --reset-data >/dev/null 2>&1 || true
fi

cleanup_existing_medagent_instances
select_startup_port

if [[ ! -d "${VENV_DIR}" ]]; then
  echo "Creating virtual environment..."
  "${PYTHON_BIN}" -m venv "${VENV_DIR}"
elif venv_needs_rebuild; then
  echo "Recreating virtual environment because the existing .venv was copied from another location..."
  rm -rf "${VENV_DIR}"
  "${PYTHON_BIN}" -m venv "${VENV_DIR}"
fi

if [[ -x "${VENV_DIR}/bin/python" ]]; then
  VENV_MINOR="$("${VENV_DIR}/bin/python" -c 'import sys; print(sys.version_info.minor)')"
  if [[ "${VENV_MINOR}" -ge 13 ]] && command -v python3.11 > /dev/null 2>&1; then
    echo "Recreating venv with python3.11 for dependency compatibility..."
    rm -rf "${VENV_DIR}"
    python3.11 -m venv "${VENV_DIR}"
  fi
fi

# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"

echo "Installing dependencies..."
if [[ "${SKIP_INSTALL}" == "true" ]]; then
  echo "Dependency installation skipped (--skip-install)."
else
  pip install -r requirements.txt
fi

echo "Seeding dataset..."
if [[ "${RESEED}" == "true" ]]; then
  "${VENV_DIR}/bin/python" seed_data.py --force
else
  "${VENV_DIR}/bin/python" seed_data.py
fi

if [[ "${FORCE_RETRAIN}" == "true" ]] || [[ ! -f "${MODEL_FILE}" ]] || [[ "${DATA_FILE}" -nt "${MODEL_FILE}" ]]; then
  echo "Training model..."
  "${VENV_DIR}/bin/python" prediction_model.py
else
  echo "Training skipped: model is up to date with current dataset."
fi

echo "Starting MedAgent app..."
nohup env APP_HOST="${HOST}" APP_PORT="${PORT}" FLASK_DEBUG=0 \
  DEMO_ACCOUNTS="${DEMO_ACCOUNTS}" \
  DEMO_USERNAME="${DEMO_USERNAME}" DEMO_PASSWORD="${DEMO_PASSWORD}" \
  "${VENV_DIR}/bin/python" app.py > "${LOG_FILE}" 2>&1 &

APP_PID="$!"
echo "${APP_PID}" > "${PID_FILE}"
echo "${PORT}" > "${PORT_FILE}"

if ! wait_for_health; then
  rm -f "${PID_FILE}" "${PORT_FILE}"
  if ps -p "${APP_PID}" > /dev/null 2>&1; then
    kill "${APP_PID}" >/dev/null 2>&1 || true
  fi
  exit 1
fi

echo "Started MedAgent (PID ${APP_PID})"
echo "Open: http://${HOST}:${PORT}"
if [[ "${AUTO_PORT_SELECTED}" == true ]]; then
  echo "Port 5000 was unavailable, so MedAgent selected port ${PORT}."
fi
if [[ -n "${DEMO_ACCOUNTS}" ]]; then
  echo "Credentials loaded from DEMO_ACCOUNTS env."
else
  echo "Credentials:"
  echo "  clinician / medagent123"
  echo "  supervisor / medagent456"
  echo "  researcher / medagent789"
fi
echo "Logs: ${LOG_FILE}"
