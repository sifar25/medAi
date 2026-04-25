import os
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

DATA_FILE = "patients.csv"
MODEL_FILE = "medication_model.pkl"

FEATURE_COLUMNS = [
    "age",
    "condition",
    "medication_count",
    "missed_doses_last_7_days",
    "missed_doses_last_30_days",
    "side_effects",
    "previous_adherence_rate",
    "appointment_attendance",
]

CATEGORICAL_COLUMNS = ["condition", "side_effects", "appointment_attendance"]


def load_and_prepare_data(file_path=DATA_FILE):
    data = pd.read_csv(file_path)
    X = data[FEATURE_COLUMNS].copy()
    y = data["risk_label"].copy()

    encoders = {}
    for column in CATEGORICAL_COLUMNS:
        encoder = LabelEncoder()
        X[column] = encoder.fit_transform(X[column].astype(str))
        encoders[column] = encoder

    target_encoder = LabelEncoder()
    y_encoded = target_encoder.fit_transform(y)
    encoders["risk_label"] = target_encoder

    return X, y_encoded, encoders


def train_and_save_model():
    X, y, encoders = load_and_prepare_data()

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=120,
        random_state=42,
        class_weight="balanced",
        max_depth=8,
        min_samples_split=3,
        min_samples_leaf=1,
    )
    model.fit(X_train, y_train)

    accuracy = model.score(X_test, y_test)
    joblib.dump({"model": model, "encoders": encoders}, MODEL_FILE)

    return accuracy


def load_model():
    if not os.path.exists(MODEL_FILE):
        train_and_save_model()
    model_data = joblib.load(MODEL_FILE)
    return model_data["model"], model_data["encoders"]


def _safe_encode(encoder, value):
    value = str(value)
    if value in encoder.classes_:
        return encoder.transform([value])[0]
    return 0


def predict_patient_risk(patient):
    model, encoders = load_model()

    values = []
    for column in FEATURE_COLUMNS:
        value = patient.get(column, 0)
        if column in CATEGORICAL_COLUMNS:
            value = _safe_encode(encoders[column], value)
        values.append(value)

    prediction = model.predict(np.array(values).reshape(1, -1))[0]
    probabilities = model.predict_proba(np.array(values).reshape(1, -1))[0]

    risk = encoders["risk_label"].inverse_transform([prediction])[0]
    confidence = float(max(probabilities))

    return risk, confidence
