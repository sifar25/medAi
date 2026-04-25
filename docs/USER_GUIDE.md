# MedAgent User Guide

## Purpose

This guide is for students, supervisors, and demo users who need a short operational reference for running and demonstrating MedAgent.

## Default Login Accounts

Use any account below:

- clinician / medagent123
- supervisor / medagent456
- researcher / medagent789

Note: These are local demo credentials for prototype use only.

## Quick Start (macOS/Linux)

1. Open terminal in this project folder.
2. Start the app.

```bash
./up.sh
```

1. Open in browser.

```text
http://127.0.0.1:5000
```

If `./up.sh` reports a different port, use that URL instead. You can always confirm the current URL with:

```bash
./status.sh
```

1. Sign in with one of the default accounts.

The app waits until the local health check is ready before startup completes.

If another MedAgent instance is already running, `./up.sh` stops it first and then restarts cleanly.

If `5000` is already occupied by something else on the machine, `./up.sh` automatically moves to the next free port in the range `5000` to `5005`.

If you want to force a specific port instead:

```bash
APP_PORT=5001 ./up.sh
```

## Quick Start (Windows)

1. Open Command Prompt in this project folder.
2. Start the app.

```bat
run_windows.bat
```

1. For a clean demo reset, run:

```bat
run_windows.bat --fresh
```

1. Stop the app with `Ctrl+C`.

## Stop the App

```bash
./down.sh
```

## Fresh Start Options

Reset runtime and data to defaults:

```bash
./down.sh --fresh
./up.sh --fresh
```

Reset only dataset to default seeds:

```bash
./down.sh --reset-data
```

## Suggested Demo Flow

1. Show the login screen and explain that only synthetic demo accounts are used.
2. Open the dashboard and point out the risk overview cards, filter controls, and paginated patient list.
3. Open one patient detail page and explain the clinical summary, contributing factors, and human oversight note.
4. Run a new assessment and keep the save checkbox enabled to demonstrate persistence.
5. Re-submit the same assessment to show duplicate protection.

For figure order and captions, use PRESENTATION_GUIDE.md.

For a spoken supervisor or viva walkthrough, use DEMO_SCRIPT.md.

## Saving New Assessment Data

When creating a new assessment, keep "Save this assessment to the dataset" checked if you want it saved in patients.csv.

Behavior:

- If record is new, it is inserted and persisted.
- If same payload already exists, duplicate insertion is prevented.

This runtime dataset should not be treated as a source file for submission; it can be regenerated from the seed file.

## Helpful Commands

Show startup options:

```bash
./up.sh --help
```

Show shutdown options:

```bash
./down.sh --help
```

Check running status:

```bash
./status.sh
```

Run UI smoke tests:

```bash
./verify_ui.sh
```

Run browser lifecycle tests:

```bash
npm install
npm run test:e2e
```

Refresh screenshots and rebuild the presentation:

```bash
npm run build:presentation
```

For a final supervisor-ready refresh from a clean baseline:

```bash
./down.sh --fresh
./up.sh --fresh
./verify_ui.sh
npm run test:e2e
npm run build:presentation
```

View logs:

```bash
./logs.sh
```

## Troubleshooting

If app does not start:

1. Run ./up.sh again and review output.
2. Check logs with ./logs.sh.
3. Confirm health endpoint responds:

```text
http://127.0.0.1:5000/health
```

If data looks wrong or old:

1. Run ./down.sh --fresh.
2. Start again with ./up.sh --fresh.

On Windows, use `run_windows.bat --fresh`.

## Handover note

For student sharing, include the source files, documentation, seed dataset, QA scripts, and presentation assets. Exclude local virtual environments, node modules, logs, caches, PID files, and regenerated runtime data.

For a final zip-ready checklist, use SUBMISSION_CHECKLIST.md.

## Academic Use Notice

This prototype is for MSc demonstration and research prototyping only. It is not a certified medical device and must not be used for real clinical decision-making.
