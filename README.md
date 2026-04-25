# MedAgent Local Humanised Prototype

## Overview

MedAgent is an MSc prototype for predictive and proactive medication adherence support in chronic illness care. It combines a local Flask web application, a simple machine-learning risk model, and human-readable support recommendations for demonstration and academic evaluation.

## Included in this submission

- Local web application for login, dashboard review, patient assessment, and model retraining.
- Synthetic dataset and repeatable seed/reset workflow.
- Presentation-ready interface with search, filtering, pagination, and printable screenshots.
- Documentation for operation, technical structure, and presentation use.
- PowerPoint deck and screenshot assets for viva or supervisor review.

## Core documents

- User Guide: docs/USER_GUIDE.md
- Technical Guide: docs/TECHNICAL_GUIDE.md
- Presentation Guide: docs/PRESENTATION_GUIDE.md
- Slide Outline: docs/SLIDE_OUTLINE.md
- Viva Demo Script: docs/DEMO_SCRIPT.md
- Submission Checklist: docs/SUBMISSION_CHECKLIST.md
- Presentation Deck: presentations/MedAgent_Supervisor_Deck.pptx
- Student Build History: docs/STUDENT_BUILD_HISTORY.md

## Quick start

Default local login accounts:

- clinician / medagent123
- supervisor / medagent456
- researcher / medagent789

Start on macOS or Linux:

```bash
./up.sh
```

Open:

```text
http://127.0.0.1:5000
```

If port `5000` is already in use on your machine, start on another port:

```bash
APP_PORT=5001 ./up.sh
```

Stop:

```bash
./down.sh
```

Start on Windows:

```bat
run_windows.bat
```

Clean reset:

```bash
./down.sh --fresh
./up.sh --fresh
```

## Validation

Smoke validation:

```bash
./verify_ui.sh
```

Browser end-to-end tests:

```bash
npm install
npm run test:e2e
```

Presentation rebuild:

```bash
npm run build:presentation
```

Clean presentation refresh from a reset baseline:

```bash
./down.sh --fresh
./up.sh --fresh
./verify_ui.sh
npm run test:e2e
npm run build:presentation
```

## Shareable handover notes

- Share source files, docs, the seed dataset, QA scripts, and presentation assets.
- Do not share local runtime outputs such as `.venv/`, `node_modules/`, `patients.csv`, logs, cache folders, PID files, or generated model artifacts.
- `patients.csv` is runtime output and will be regenerated from `patients_seed.csv` when needed.

## Academic note

This prototype uses synthetic data only. It is intended for academic demonstration and research prototyping, not for real clinical decision-making.
