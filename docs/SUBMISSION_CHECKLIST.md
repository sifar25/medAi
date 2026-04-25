# MedAgent Submission Checklist

## Purpose

Use this checklist before sending the project to a supervisor, assessor, or module submission portal.

## Include in the submission package

- source files: `app.py`, `agent.py`, `prediction_model.py`, `seed_data.py`
- templates and styles: `templates/`, `static/`
- lifecycle scripts: `up.sh`, `down.sh`, `status.sh`, `logs.sh`, `run_windows.bat`
- QA and validation files: `qa/`, `verify_ui.sh`, `package.json`, `package-lock.json`, `requirements.txt`
- seed dataset: `patients_seed.csv`
- presentation assets: `presentations/`, `scripts/`
- handoff documents: `README.md`, `docs/USER_GUIDE.md`, `docs/TECHNICAL_GUIDE.md`, `docs/PRESENTATION_GUIDE.md`, `docs/SLIDE_OUTLINE.md`, `docs/STUDENT_BUILD_HISTORY.md`, this checklist

## Exclude from the submission package

- `.venv/`
- `node_modules/`
- `__pycache__/`
- `.DS_Store`
- `.medagent.pid`
- `.medagent.log`
- `.medagent.err.log`
- `patients.csv`
- `medication_model.pkl`
- `test-results/`
- `playwright-report/`

## Before zipping the project

1. Stop the app if it is running.

```bash
./down.sh --clean-runtime
```

1. Remove any regenerated runtime dataset if present.

```bash
rm -f patients.csv
```

1. Confirm the shareable files are still present:

- `patients_seed.csv`
- `README.md`
- `docs/`
- `presentations/`
- `scripts/`

1. If needed, verify the project still works from a clean state:

```bash
./up.sh --skip-install
./status.sh
./down.sh --clean-runtime
rm -f patients.csv
```

If `./up.sh` selects a port other than `5000`, use the URL printed during startup or shown by `./status.sh`.

## Recommended zip contents

The zip file should contain:

- project source
- docs
- presentation deck and screenshots
- seed dataset
- package manifests and requirements

It should not contain machine-specific environments, local caches, or temporary outputs.

## Final academic reminder

- The project uses synthetic data only.
- The application is a prototype for academic demonstration.
- Present the system as clinician-supporting, not autonomous.
