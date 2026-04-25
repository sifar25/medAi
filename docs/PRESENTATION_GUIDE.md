# MedAgent Presentation Guide

## Purpose

This guide provides the final presentation order for screenshots, report figures, and viva demonstrations.

Use it together with DEMO_SCRIPT.md and SLIDE_OUTLINE.md so the spoken flow, slide order, and screenshots stay aligned.

To rebuild the deck after editing the outline or presentation content:

```bash
npm run deck:presentation
```

To refresh both the screenshots and the deck together:

```bash
npm run build:presentation
```

## Presentation setup

1. Reset to a known state with `./down.sh --fresh` and `./up.sh --fresh`.
2. Use the default `clinician / medagent123` login unless a custom demo account is required.
3. Capture screenshots at desktop width and 100% zoom.

Verified refresh sequence:

```bash
./down.sh --fresh
./up.sh --fresh
./verify_ui.sh
npm run test:e2e
npm run build:presentation
```

The presentation capture workflow exports pages after motion has settled so the screenshots remain sharp when placed on slides.

## Recommended screenshot sequence

### Figure 1. Startup-ready local environment

Suggested caption:

MedAgent local startup flow showing deterministic setup, seed restoration, model preparation, and health-checked launch.

### Figure 2. Login page

Suggested caption:

Login screen for the MedAgent clinician demo workspace using local synthetic accounts only.

### Figure 3. Dashboard overview

Suggested caption:

Dashboard overview combining case volume, triage counts, and a clinician-facing summary of adherence risk across the synthetic dataset.

### Figure 4. Filtered dashboard state

Suggested caption:

Filtered dashboard view showing targeted case review by search, risk level, condition, and paginated navigation.

### Figure 5. Patient assessment result

Suggested caption:

Patient-level assessment result showing model-estimated adherence risk, explanatory factors, and a clinician-readable summary.

### Figure 6. Support plan section

Suggested caption:

Human-centred support recommendations generated from the assessed adherence context, with clinician oversight retained for high-risk cases.

### Figure 7. New assessment form

Suggested caption:

New assessment workflow for testing a fresh patient scenario and optionally persisting the scenario into the working dataset.

### Figure 8. New assessment result with persistence note

Suggested caption:

Assessment output after manual scenario entry, including persistence feedback and duplicate-protection behaviour.

### Figure 9. Model retraining page

Suggested caption:

Model retraining summary showing local refresh of the prediction model against the synthetic adherence dataset.

### Figure 10. Status or verification evidence

Suggested caption:

Operational verification output confirming that the MedAgent prototype starts correctly and passes local validation checks.

## Recommended report ordering

Use this order in the dissertation or project report:

1. startup-ready local environment
2. login page
3. dashboard overview
4. filtered dashboard state
5. patient assessment result
6. support plan section
7. new assessment form
8. new assessment result with persistence note
9. model retraining page
10. status or verification evidence

## Presentation reminders

- Keep the narrative clinician-supporting rather than autonomous.
- Do not mix screenshots from different runtime states.
- Do not present confidence values as clinical certainty.
