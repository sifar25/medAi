# MedAgent Viva Demo Script

## Purpose

Use this as a short spoken script for supervisor review, viva rehearsal, or a live MSc project demonstration.

Target duration: 2 to 4 minutes.

## Before starting

Run the clean demo sequence:

```bash
./down.sh --fresh
./up.sh --fresh
```

Open:

```text
http://127.0.0.1:5000
```

Login:

- clinician / medagent123

## Short opening

Suggested wording:

MedAgent is a local MSc prototype for predicting medication non-adherence risk in patients with chronic illness. The aim is not to replace clinical judgment, but to help clinicians identify which patients may need follow-up support sooner and to present that risk in a more readable, human-centred way.

## Step 1. Show the dashboard

What to show:

- summary cards
- patient list
- search, filters, and pagination

Suggested wording:

This is the main dashboard. It gives a quick overview of the synthetic dataset and highlights how many patients may need urgent review, routine support, or no immediate escalation. The dashboard is designed as the triage entry point, so the clinician can search, filter, and move through cases in a structured way.

## Step 2. Show filtered review workflow

What to do:

- search for `P001` or filter to `High` risk

Suggested wording:

This view shows the usability improvements made for the final project. Instead of a static table, the system supports targeted review by condition and risk level. That makes the demo more realistic and supports a clearer clinical review workflow.

## Step 3. Open a patient assessment

What to show:

- predicted non-adherence risk
- contributing factors
- recommended support plan

Suggested wording:

At patient level, the system does more than produce a label. It explains why the patient is concerning and turns the prediction into a readable support plan. High-risk results still keep the clinician in control, so the tool is clinician-supporting rather than autonomous.

## Step 4. Run a new assessment

What to do:

- click `Run new assessment`
- enter a fresh patient scenario
- submit with save enabled

Suggested wording:

The project also supports live assessment of a new patient scenario. A user can enter a case, generate a risk result, and optionally persist it into the working dataset. This makes the system suitable for a live demonstration rather than only a fixed screenshot walkthrough.

## Step 5. Mention persistence and duplicate protection

Suggested wording:

If the same assessment is submitted again, the system prevents duplicate insertion. That was added to keep the demo repeatable and safe during multiple supervisor or viva runs.

## Step 6. Mention reliability and reproducibility

Suggested wording:

The prototype was also structured with repeatable startup and shutdown scripts, health checks, and both smoke and browser end-to-end validation. That means it can be reset to a known baseline and demonstrated consistently across runs.

## Closing statement

Suggested wording:

The main contribution of this project is combining a simple predictive model with human-readable support guidance in a form that is easy to demonstrate and discuss. Its current limitations are that it uses synthetic data and runs as a local prototype, but it provides a defensible foundation for further clinical workflow and analytics work.

## If time is very short

Use this 60-second version:

1. This is a clinician-supporting prototype for identifying medication non-adherence risk in chronic illness care.
2. The dashboard helps prioritise cases through filtering, search, and review workflow support.
3. The patient page combines a prediction, explanation, and recommended support actions.
4. The system can run new assessments live and persist them safely without accidental duplication.
5. The project is reproducible through scripted startup, reset, and validation.
