import os
from pathlib import Path
from math import ceil

import pandas as pd
from flask import Flask, redirect, render_template, request, session, url_for

from agent import analyse_patient
from prediction_model import train_and_save_model

app = Flask(__name__)
app.secret_key = os.getenv("APP_SECRET_KEY", "local-demo-secret-key")

BASE_DIR = Path(__file__).resolve().parent
PATIENTS_FILE = BASE_DIR / "patients.csv"
DATA_COLUMNS = [
    "patient_id",
    "name",
    "age",
    "condition",
    "medication_count",
    "missed_doses_last_7_days",
    "missed_doses_last_30_days",
    "side_effects",
    "previous_adherence_rate",
    "appointment_attendance",
    "risk_label",
]
CONDITIONS = ["Diabetes", "Hypertension", "Asthma", "Heart Disease", "Depression", "Arthritis"]
SIDE_EFFECT_OPTIONS = ["None", "Mild nausea", "Fatigue", "Dizziness", "Weight gain", "Insomnia", "Mild pain"]
ATTENDANCE_OPTIONS = ["Excellent", "Good", "Fair", "Poor"]

# Local prototype login details.
# For an MSc demo, this is intentionally simple and local only.
DEFAULT_DEMO_ACCOUNTS = [
    ("clinician", "medagent123"),
    ("supervisor", "medagent456"),
    ("researcher", "medagent789"),
]


def _parse_demo_accounts():
    # Format: username1:password1,username2:password2
    raw_accounts = os.getenv("DEMO_ACCOUNTS", "").strip()
    if raw_accounts:
        parsed = []
        for chunk in raw_accounts.split(","):
            item = chunk.strip()
            if not item or ":" not in item:
                continue
            username, password = item.split(":", 1)
            username = username.strip()
            password = password.strip()
            if username and password:
                parsed.append((username, password))
        if parsed:
            return parsed

    # Backward-compatible single-account override.
    single_user = os.getenv("DEMO_USERNAME", "").strip()
    single_pass = os.getenv("DEMO_PASSWORD", "").strip()
    if single_user and single_pass:
        return [(single_user, single_pass)] + DEFAULT_DEMO_ACCOUNTS[1:]

    return DEFAULT_DEMO_ACCOUNTS


DEMO_ACCOUNTS = _parse_demo_accounts()
DEMO_ACCOUNT_MAP = {username: password for username, password in DEMO_ACCOUNTS}


def load_patients():
    data = pd.read_csv(PATIENTS_FILE)
    return data.to_dict(orient="records")


def load_patient_dataframe():
    return pd.read_csv(PATIENTS_FILE)


def _next_patient_id(existing_ids):
    max_num = 0
    for pid in existing_ids:
        text = str(pid)
        if text.startswith("P") and text[1:].isdigit():
            max_num = max(max_num, int(text[1:]))
    return f"P{max_num + 1:03d}"


def save_patient_if_new(patient, risk_label):
    if not PATIENTS_FILE.exists():
        pd.DataFrame(columns=DATA_COLUMNS).to_csv(PATIENTS_FILE, index=False)

    data = pd.read_csv(PATIENTS_FILE)

    # Deduplicate by key patient features so repeated submissions do not create clones.
    key = {
        "name": str(patient.get("name", "")).strip(),
        "age": int(patient.get("age", 0)),
        "condition": str(patient.get("condition", "")).strip(),
        "medication_count": int(patient.get("medication_count", 0)),
        "missed_doses_last_7_days": int(patient.get("missed_doses_last_7_days", 0)),
        "missed_doses_last_30_days": int(patient.get("missed_doses_last_30_days", 0)),
        "side_effects": str(patient.get("side_effects", "None")).strip(),
        "previous_adherence_rate": float(patient.get("previous_adherence_rate", 0.0)),
        "appointment_attendance": str(patient.get("appointment_attendance", "")).strip(),
    }

    if not data.empty:
        mask = (
            (data["name"].astype(str).str.strip() == key["name"])
            & (data["age"].astype(int) == key["age"])
            & (data["condition"].astype(str).str.strip() == key["condition"])
            & (data["medication_count"].astype(int) == key["medication_count"])
            & (data["missed_doses_last_7_days"].astype(int) == key["missed_doses_last_7_days"])
            & (data["missed_doses_last_30_days"].astype(int) == key["missed_doses_last_30_days"])
            & (data["side_effects"].astype(str).str.strip() == key["side_effects"])
            & (data["previous_adherence_rate"].astype(float).round(4) == round(key["previous_adherence_rate"], 4))
            & (data["appointment_attendance"].astype(str).str.strip() == key["appointment_attendance"])
        )
        if mask.any():
            existing = data[mask].iloc[0]
            return str(existing["patient_id"]), False

    patient_id = _next_patient_id(data["patient_id"].tolist() if "patient_id" in data.columns else [])
    row = {
        "patient_id": patient_id,
        "name": key["name"],
        "age": key["age"],
        "condition": key["condition"],
        "medication_count": key["medication_count"],
        "missed_doses_last_7_days": key["missed_doses_last_7_days"],
        "missed_doses_last_30_days": key["missed_doses_last_30_days"],
        "side_effects": key["side_effects"],
        "previous_adherence_rate": key["previous_adherence_rate"],
        "appointment_attendance": key["appointment_attendance"],
        "risk_label": risk_label,
    }

    updated = pd.concat([data, pd.DataFrame([row])], ignore_index=True)
    updated.to_csv(PATIENTS_FILE, index=False)
    return patient_id, True


def _to_int(value, default=0, minimum=None, maximum=None):
    try:
        parsed = int(value)
    except (TypeError, ValueError):
        parsed = default

    if minimum is not None:
        parsed = max(minimum, parsed)
    if maximum is not None:
        parsed = min(maximum, parsed)
    return parsed


def _to_float(value, default=0.0, minimum=None, maximum=None):
    try:
        parsed = float(value)
    except (TypeError, ValueError):
        parsed = default

    if minimum is not None:
        parsed = max(minimum, parsed)
    if maximum is not None:
        parsed = min(maximum, parsed)
    return parsed


def is_logged_in():
    return session.get("logged_in") is True


def _dashboard_query_state():
    search = request.args.get("search", "").strip()
    risk_filter = request.args.get("risk", "All").strip() or "All"
    condition_filter = request.args.get("condition", "All").strip() or "All"
    page = _to_int(request.args.get("page"), default=1, minimum=1)
    per_page = _to_int(request.args.get("per_page"), default=8, minimum=4, maximum=20)
    return {
        "search": search,
        "risk": risk_filter,
        "condition": condition_filter,
        "page": page,
        "per_page": per_page,
    }


def _build_query_args(**overrides):
    state = _dashboard_query_state()
    state.update(overrides)
    cleaned = {}
    for key, value in state.items():
        if key == "page" and value == 1:
            continue
        if key == "per_page" and value == 8:
            continue
        if isinstance(value, str) and (value == "" or value == "All"):
            continue
        cleaned[key] = value
    return cleaned


def _filter_patients(patients, state):
    filtered = patients
    if state["search"]:
        needle = state["search"].lower()
        filtered = [
            p for p in filtered
            if needle in str(p.get("name", "")).lower()
            or needle in str(p.get("patient_id", "")).lower()
            or needle in str(p.get("condition", "")).lower()
        ]
    if state["risk"] != "All":
        filtered = [p for p in filtered if p.get("risk_label") == state["risk"]]
    if state["condition"] != "All":
        filtered = [p for p in filtered if p.get("condition") == state["condition"]]
    return filtered


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None

    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "").strip()

        if DEMO_ACCOUNT_MAP.get(username) == password:
            session["logged_in"] = True
            session["username"] = username
            return redirect(url_for("home"))

        error = "The username or password entered is incorrect."

    return render_template(
        "login.html",
        error=error,
        demo_accounts=DEMO_ACCOUNTS,
    )


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/")
def home():
    if not is_logged_in():
        return redirect(url_for("login"))

    patients = load_patients()
    state = _dashboard_query_state()
    filtered = _filter_patients(patients, state)

    total = len(patients)
    high = len([p for p in patients if p["risk_label"] == "High"])
    medium = len([p for p in patients if p["risk_label"] == "Medium"])
    low = len([p for p in patients if p["risk_label"] == "Low"])
    total_filtered = len(filtered)

    avg_adherence = 0
    if patients:
        avg_adherence = round(sum(float(p.get("previous_adherence_rate", 0)) for p in patients) / total * 100)

    clinician_review_count = len([p for p in patients if p["risk_label"] == "High"])

    total_pages = max(1, ceil(total_filtered / state["per_page"]))
    current_page = min(state["page"], total_pages)
    start_index = (current_page - 1) * state["per_page"]
    end_index = start_index + state["per_page"]
    paginated = filtered[start_index:end_index]

    page_links = []
    for page_number in range(1, total_pages + 1):
        page_links.append(
            {
                "number": page_number,
                "is_current": page_number == current_page,
                "url": url_for("home", **_build_query_args(page=page_number)),
            }
        )

    featured_message = (
        "This prototype keeps the clinician in control: the model highlights risk patterns, then the support agent translates them into practical follow-up actions."
    )

    return render_template(
        "dashboard.html",
        patients=paginated,
        total=total,
        high=high,
        medium=medium,
        low=low,
        total_filtered=total_filtered,
        avg_adherence=avg_adherence,
        clinician_review_count=clinician_review_count,
        username=session.get("username"),
        conditions=CONDITIONS,
        risk_options=["All", "High", "Medium", "Low"],
        filters=state,
        page_links=page_links,
        total_pages=total_pages,
        current_page=current_page,
        showing_from=(start_index + 1) if total_filtered else 0,
        showing_to=min(end_index, total_filtered),
        clear_filters_url=url_for("home"),
        featured_message=featured_message,
    )


@app.get("/health")
def health():
    return {"status": "ok"}, 200


@app.route("/patient/<patient_id>")
def patient_detail(patient_id):
    if not is_logged_in():
        return redirect(url_for("login"))

    patients = load_patients()
    patient = next((p for p in patients if p["patient_id"] == patient_id), None)
    if patient is None:
        return "Patient not found", 404
    result = analyse_patient(patient)
    result["condition_context"] = result["explanation"].get("condition_context")
    result["risk_note"] = {
        "High": "High-risk cases should trigger same-day attention or a planned clinician callback.",
        "Medium": "Medium-risk cases benefit from coaching, reminders, and barrier review.",
        "Low": "Low-risk cases can remain in routine monitoring unless context changes.",
    }.get(result["risk"], "")
    result["back_url"] = request.args.get("back") or url_for("home")
    return render_template("patient.html", result=result)


@app.route("/new-assessment", methods=["GET", "POST"])
def new_assessment():
    if not is_logged_in():
        return redirect(url_for("login"))

    if request.method == "POST":
        save_to_dataset = request.form.get("save_to_dataset") == "yes"
        patient = {
            "patient_id": "NEW",
            "name": request.form.get("name", "New Patient"),
            "age": _to_int(request.form.get("age"), default=50, minimum=0, maximum=120),
            "condition": request.form.get("condition"),
            "medication_count": _to_int(
                request.form.get("medication_count"), default=1, minimum=1, maximum=20
            ),
            "missed_doses_last_7_days": _to_int(
                request.form.get("missed_doses_last_7_days"), default=0, minimum=0, maximum=21
            ),
            "missed_doses_last_30_days": _to_int(
                request.form.get("missed_doses_last_30_days"), default=0, minimum=0, maximum=90
            ),
            "side_effects": request.form.get("side_effects", "None"),
            "previous_adherence_rate": _to_float(
                request.form.get("previous_adherence_rate"), default=0.9, minimum=0.0, maximum=1.0
            ),
            "appointment_attendance": request.form.get("appointment_attendance", "Good")
        }
        result = analyse_patient(patient)
        result["condition_context"] = result["explanation"].get("condition_context")
        result["risk_note"] = {
            "High": "This result suggests rapid follow-up and clinician review should be prioritised.",
            "Medium": "This result suggests supportive follow-up and practical adherence coaching.",
            "Low": "This result suggests routine follow-up is reasonable at this stage.",
        }.get(result["risk"], "")
        result["back_url"] = url_for("home")
        if save_to_dataset:
            patient_id, inserted = save_patient_if_new(patient, result["risk"])
            result["patient"]["patient_id"] = patient_id
            result["saved_to_dataset"] = inserted
            result["already_exists"] = not inserted
        else:
            result["saved_to_dataset"] = False
            result["already_exists"] = False
        return render_template("patient.html", result=result)

    return render_template(
        "new_assessment.html",
        conditions=CONDITIONS,
        side_effect_options=SIDE_EFFECT_OPTIONS,
        attendance_options=ATTENDANCE_OPTIONS,
    )


@app.route("/train")
def train():
    if not is_logged_in():
        return redirect(url_for("login"))

    accuracy = train_and_save_model()
    dataset = load_patient_dataframe()
    return render_template(
        "train.html",
        accuracy=accuracy,
        total_records=len(dataset),
        last_condition_count=len(dataset["condition"].unique()) if not dataset.empty else 0,
    )


if __name__ == "__main__":
    train_and_save_model()
    app.run(
        debug=os.getenv("FLASK_DEBUG", "0") == "1",
        host=os.getenv("APP_HOST", "127.0.0.1"),
        port=int(os.getenv("APP_PORT", "5000")),
    )
