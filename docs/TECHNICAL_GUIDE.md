# MedAgent Technical Guide

## Architecture Overview

MedAgent is a local Flask prototype composed of three core layers:

1. Web layer: Flask routes and templates in app.py and templates/.
2. Prediction layer: model training and inference in prediction_model.py.
3. Agent layer: explanation and support-plan generation in agent.py.

The web layer now includes:

- dashboard search, condition/risk filtering, and pagination
- richer result-page presentation blocks for explanation and support plan
- model training summary cards for presentation use

Runtime scripts provide deterministic local lifecycle control:

- up.sh
- down.sh
- status.sh
- logs.sh

Startup now validates that the chosen port is free before launching and rebuilds `.venv/` automatically if a copied project folder contains a relocated virtual environment from another machine or path.

Presentation assets are maintained separately in PRESENTATION_GUIDE.md, SLIDE_OUTLINE.md, DEMO_SCRIPT.md, scripts/, and presentations/.

## Data and Model Assets

- patients_seed.csv: immutable baseline synthetic dataset.
- patients.csv: runtime working dataset.
- medication_model.pkl: trained model artifact.
- presentations/MedAgent_Supervisor_Deck.pptx: generated supervisor presentation deck.
- presentations/screenshots/: generated UI screenshots used by the deck.

## Startup and Shutdown Contracts

up.sh behavior:

1. Creates venv if missing.
2. Installs dependencies unless --skip-install.
3. Seeds dataset.
4. Trains model when needed.
5. Starts Flask app in background and writes PID/log files.
6. Waits for the local health endpoint before declaring startup complete.

down.sh behavior:

1. Stops app process if running.
2. Optional runtime cleanup with --clean-runtime.
3. Optional dataset reset with --reset-data.
4. Full reset shortcut with --fresh.

## CLI Flags

up.sh:

- --reseed: force overwrite patients.csv from patients_seed.csv.
- --retrain: force model retrain.
- --fresh: reset runtime/data before startup.
- --skip-install: skip dependency install.
- --help: usage.

down.sh:

- --clean-runtime: remove model/log/pid/cache.
- --reset-data: restore patients.csv from seed.
- --fresh: clean-runtime + reset-data.
- --help: usage.

run_windows.bat:

- --reseed: force overwrite patients.csv from patients_seed.csv.
- --retrain: force model retraining.
- --fresh: remove runtime artifacts, reseed data, and retrain before launch.
- --skip-install: skip dependency install.
- --help: usage.

## Idempotency Rules

1. Seeding is safe by default and does not overwrite existing patients.csv unless explicitly forced.
2. Existing patients.csv schema is validated during seed step.
3. Model training is skipped if model is already newer than dataset unless --retrain is supplied.
4. New assessment saves are deduplicated by patient payload fields.
5. Restarting with default ./up.sh preserves user-added records.

## Login Configuration

Defaults are embedded in app.py:

- clinician / medagent123
- supervisor / medagent456
- researcher / medagent789

Override options:

1. Single account:

```bash
DEMO_USERNAME=custom DEMO_PASSWORD=secret ./up.sh
```

1. Multi-account:

```bash
DEMO_ACCOUNTS='u1:p1,u2:p2' ./up.sh
```

## Key File Responsibilities

- app.py: session auth, pages, save/dedup flow, health endpoint.
- templates/dashboard.html: hero dashboard, filters, pagination, and presentation notes.
- templates/patient.html: structured assessment presentation for screenshots and supervisor review.
- templates/new_assessment.html: scenario entry form with dataset persistence messaging.
- prediction_model.py: feature prep, label encoding, train/save/load/predict.
- agent.py: summary text and recommended action generation.
- seed_data.py: create/validate/reset dataset.
- scripts/capture_presentation_screenshots.js: capture presentation-grade UI screenshots with Playwright.
- scripts/build_presentation.js: resolve a usable Python interpreter and rebuild the presentation deck portably.
- scripts/generate_presentation.py: generate the PowerPoint deck from the current supervisor slide structure.
- templates/: login, dashboard, patient, training, assessment views.
- static/style.css: UI styling.

The screenshot capture workflow disables UI motion during export and waits for stable rendering so the generated presentation images are crisp and consistent.

## Verification Checklist

Quick command:

```bash
./verify_ui.sh
```

Browser QA:

```bash
npm run test:e2e
```

1. ./up.sh starts app and prints URL.
2. GET /health returns status ok.
3. Login succeeds with default account.
4. Dashboard filter controls and pagination render correctly.
5. New assessment with save enabled persists to patients.csv.
6. Resubmitting same payload does not duplicate entry.
7. ./down.sh stops process cleanly.

## Safe Modification Procedure

When modifying behavior:

1. Update implementation files.
2. Validate with up/down and health checks.
3. Update USER_GUIDE.md and TECHNICAL_GUIDE.md.
4. Update PRESENTATION_GUIDE.md if screen layout, terminology, or demo sequence changes.
5. Add change note in STUDENT_BUILD_HISTORY.md.
6. Ensure README pointers remain accurate.

If the presentation story changes, regenerate the deck after updating the outline or presentation guide:

```bash
npm run deck:presentation
```

Full screenshot-plus-deck rebuild:

```bash
npm run build:presentation
```

Verified clean-state validation and presentation refresh order:

```bash
./down.sh --fresh
./up.sh --fresh
./verify_ui.sh
npm run test:e2e
npm run build:presentation
```

For student sharing, the repository should be handed over without local runtime outputs such as `.venv/`, `node_modules/`, `patients.csv`, model artifacts, logs, or cache folders.
