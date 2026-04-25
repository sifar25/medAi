from datetime import datetime
from prediction_model import predict_patient_risk


def explain_result(patient, risk, confidence):
    name = patient.get("name", "This patient")
    missed_week = int(patient.get("missed_doses_last_7_days", 0))
    missed_month = int(patient.get("missed_doses_last_30_days", 0))
    adherence = float(patient.get("previous_adherence_rate", 0))
    side_effects = patient.get("side_effects", "None")
    condition = patient.get("condition", "their condition")

    reasons = []
    if missed_week >= 3:
        reasons.append(f"{name} missed {missed_week} doses in the past 7 days.")
    elif missed_week > 0:
        reasons.append(f"{name} missed {missed_week} dose(s) in the past 7 days.")
    else:
        reasons.append(f"{name} reported no missed doses in the past 7 days.")

    reasons.append(f"Previous adherence pattern: {adherence:.0%}.")
    reasons.append(f"Missed doses in the past 30 days: {missed_month}.")

    if side_effects and side_effects != "None":
        reasons.append(f"Reported side effects: {side_effects}.")

    if risk == "High":
        summary = "Current pattern suggests a high chance of non-adherence, so early clinician follow-up is recommended."
    elif risk == "Medium":
        summary = "Current pattern suggests moderate risk, so regular check-ins and reminder support may help."
    else:
        summary = "Current pattern suggests low risk, so routine follow-up can continue."

    return {
        "summary": summary,
        "reasons": reasons,
        "confidence_text": f"{confidence:.0%}",
        "condition_context": f"This assessment focuses on adherence for {condition}."
    }


def recommend_actions(patient, risk):
    actions = []
    missed_week = int(patient.get("missed_doses_last_7_days", 0))
    adherence = float(patient.get("previous_adherence_rate", 0))
    medication_count = int(patient.get("medication_count", 1))
    side_effects = patient.get("side_effects", "None")

    if risk == "High":
        actions.extend([
            "Escalate for clinician review.",
            "Arrange a follow-up call within 24 hours.",
            "Explore practical barriers such as side effects, cost, routine, or forgetfulness.",
            "Agree a simple, realistic reminder plan with the patient."
        ])
    elif risk == "Medium":
        actions.extend([
            "Send supportive medication reminders.",
            "Schedule a weekly check-in.",
            "Review the patient routine and identify barriers."
        ])
    else:
        actions.extend([
            "Continue routine monitoring.",
            "Send gentle adherence encouragement.",
            "Review again at the next planned check-in."
        ])

    if missed_week >= 3:
        actions.append(f"Discuss the {missed_week} missed doses recorded this week.")
    if adherence < 0.70:
        actions.append("Explore why adherence has dropped below 70%.")
    if medication_count > 3:
        actions.append("Consider a pill organiser or simplified medication schedule.")
    if side_effects and side_effects != "None":
        actions.append(f"Ask a clinician to review the reported side effect: {side_effects}.")

    return actions


def analyse_patient(patient):
    risk, confidence = predict_patient_risk(patient)
    return {
        "patient": patient,
        "risk": risk,
        "confidence": confidence,
        "explanation": explain_result(patient, risk, confidence),
        "actions": recommend_actions(patient, risk),
        "requires_clinician_review": risk == "High",
        "created_at": datetime.now().strftime("%d %b %Y, %H:%M")
    }
