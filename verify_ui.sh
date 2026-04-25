#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

COOKIE_JAR="/tmp/medai_cookie.txt"
HEALTH_JSON="/tmp/medai_health.json"
LOGIN_HTML="/tmp/medai_login.html"
BAD_LOGIN_HTML="/tmp/medai_bad_login.html"
DASHBOARD_HTML="/tmp/medai_dashboard.html"
PATIENT_HTML="/tmp/medai_patient.html"
NEW_FORM_HTML="/tmp/medai_new_assessment.html"
SUBMIT1_HTML="/tmp/medai_submit1.html"
SUBMIT2_HTML="/tmp/medai_submit2.html"

rm -f "${COOKIE_JAR}" "${HEALTH_JSON}" "${LOGIN_HTML}" "${BAD_LOGIN_HTML}" \
  "${DASHBOARD_HTML}" "${PATIENT_HTML}" "${NEW_FORM_HTML}" "${SUBMIT1_HTML}" "${SUBMIT2_HTML}"

./down.sh >/tmp/medai_down_prep.log 2>&1 || true
./up.sh --skip-install >/tmp/medai_up.log 2>&1

# Wait briefly for app readiness
for i in {1..20}; do
  if curl -sf http://127.0.0.1:5000/health >"${HEALTH_JSON}"; then
    break
  fi
  sleep 1
done

curl -sf http://127.0.0.1:5000/login >"${LOGIN_HTML}"

# Invalid login should stay on login page with an error message
curl -s -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  -d "username=baduser" -d "password=badpass" \
  http://127.0.0.1:5000/login >"${BAD_LOGIN_HTML}"

# Valid login: post credentials, then request dashboard with session cookie
curl -s -i -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  -d "username=clinician" -d "password=medagent123" \
  http://127.0.0.1:5000/login >/tmp/medai_login_response.txt
curl -s -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  http://127.0.0.1:5000/ >"${DASHBOARD_HTML}"

curl -s -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  http://127.0.0.1:5000/patient/P001 >"${PATIENT_HTML}"

curl -s -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  http://127.0.0.1:5000/new-assessment >"${NEW_FORM_HTML}"

before_lines=$(wc -l < patients.csv)
name="UI Test User $(date +%s)"

curl -s -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  --data-urlencode "name=${name}" \
  --data-urlencode "age=46" \
  --data-urlencode "condition=Diabetes" \
  --data-urlencode "medication_count=3" \
  --data-urlencode "missed_doses_last_7_days=2" \
  --data-urlencode "missed_doses_last_30_days=6" \
  --data-urlencode "side_effects=Mild nausea" \
  --data-urlencode "previous_adherence_rate=0.73" \
  --data-urlencode "appointment_attendance=Good" \
  --data-urlencode "save_to_dataset=yes" \
  http://127.0.0.1:5000/new-assessment >"${SUBMIT1_HTML}"

mid_lines=$(wc -l < patients.csv)

curl -s -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  --data-urlencode "name=${name}" \
  --data-urlencode "age=46" \
  --data-urlencode "condition=Diabetes" \
  --data-urlencode "medication_count=3" \
  --data-urlencode "missed_doses_last_7_days=2" \
  --data-urlencode "missed_doses_last_30_days=6" \
  --data-urlencode "side_effects=Mild nausea" \
  --data-urlencode "previous_adherence_rate=0.73" \
  --data-urlencode "appointment_attendance=Good" \
  --data-urlencode "save_to_dataset=yes" \
  http://127.0.0.1:5000/new-assessment >"${SUBMIT2_HTML}"

after_lines=$(wc -l < patients.csv)

# Assertions
grep -q '"status":"ok"' "${HEALTH_JSON}"
grep -qi 'welcome back' "${LOGIN_HTML}"
grep -qi 'incorrect' "${BAD_LOGIN_HTML}"
grep -qi 'patient list' "${DASHBOARD_HTML}"
grep -qi 'apply filters' "${DASHBOARD_HTML}"
grep -qi 'predicted non-adherence risk' "${PATIENT_HTML}"
grep -qi 'run a new patient assessment' "${NEW_FORM_HTML}"
grep -qi 'saved:' "${SUBMIT1_HTML}"
grep -qi 'already exists:' "${SUBMIT2_HTML}"

if [[ "${mid_lines}" -ne $((before_lines + 1)) ]]; then
  echo "FAIL_LINE_GROWTH before=${before_lines} mid=${mid_lines}"
  ./down.sh >/tmp/medai_down.log 2>&1 || true
  exit 2
fi

if [[ "${after_lines}" -ne "${mid_lines}" ]]; then
  echo "FAIL_DEDUP mid=${mid_lines} after=${after_lines}"
  ./down.sh >/tmp/medai_down.log 2>&1 || true
  exit 3
fi

echo "UI_TESTS_OK before=${before_lines} mid=${mid_lines} after=${after_lines}"
./down.sh >/tmp/medai_down.log 2>&1
