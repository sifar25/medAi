# Student Build History and Modification Record

## Objective

Document how this MSc prototype was built, how it evolved, and what must be updated when new changes are introduced.

## Creation Timeline

### Phase A: Base local prototype

Implemented:

- Flask app with login, dashboard, patient detail, and new assessment form.
- Random Forest prediction pipeline.
- Synthetic adherence dataset in CSV format.

### Phase B: Human-centred refinement

Implemented:

- Human-readable explanation output.
- Support-plan recommendations with clinician oversight emphasis.
- Improved page copy and visual presentation for demonstration.

### Phase C: Operational scripts

Implemented:

- Local lifecycle scripts for repeatable startup/shutdown.
- Background run mode with PID and logs.
- Health endpoint for smoke validation.

### Phase D: Idempotency and persistence

Implemented:

- Safe seeding rules with schema validation.
- Conditional model retraining.
- Save-to-dataset for new assessments.
- Duplicate prevention for repeated submissions.

### Phase E: Parameterized control model

Implemented:

- Removed separate wipe script.
- Added controlled reset and fresh-start flags into up.sh and down.sh.
- Standardized script behavior with reference project style.

## Current Baseline Guarantees

1. Default login accounts are always available unless explicitly overridden.
2. Default seed dataset can be restored through down/up flags.
3. Startup and restart are idempotent by default.
4. Fresh reset requires explicit operator flags.

## Documentation Update Policy

For every new modification, update these files together:

1. README.md for run commands and quick usage.
2. USER_GUIDE.md for non-technical operators.
3. TECHNICAL_GUIDE.md for architecture and implementation rules.
4. This file (STUDENT_BUILD_HISTORY.md) with a new dated entry.

## Change Log Entries (append-only)

### 2026-04-25

Summary:

- Added parameterized lifecycle controls to up/down scripts.
- Added idempotent save behavior for new assessments.
- Added default seed reset controls without external wipe script.
- Added dedicated user and technical documentation.
- Added reusable UI smoke test script for login, dashboard, assessment, save, and dedup flows.

Impact:

- Improved operational safety and reproducibility.
- Better handover readiness for supervisor/client review.
- Added repeatable UI regression verification for future modifications.

### 2026-04-25 (presentation polish pass)

Change summary:

- Added dashboard search, risk/condition filters, and pagination.
- Reworked core pages for more presentable MSc screenshots and narrative flow.
- Added startup health-wait behavior and improved Windows startup flags.
- Added npm Playwright scripts and extended browser QA to cover dashboard controls.

Files touched:

- app.py
- templates/dashboard.html
- templates/new_assessment.html
- templates/patient.html
- templates/train.html
- templates/base.html
- static/style.css
- up.sh
- down.sh
- run_windows.bat
- package.json
- verify_ui.sh
- qa/lifecycle.spec.js
- README.md
- USER_GUIDE.md
- TECHNICAL_GUIDE.md

Validation done:

- file-level error checks for Python, Jinja templates, and CSS
- UI smoke test script
- Playwright lifecycle test suite

User impact:

- Easier demo flow for supervisors and assessors.
- Better cross-platform startup experience.
- More polished and defensible presentation quality for the MSc project.

### 2026-04-25 (presentation guide pass)

Change summary:

- Added a dedicated presentation guide for report figures and viva flow.
- Defined screenshot framing rules, figure ordering, and ready-to-use captions.
- Linked presentation guidance from the README, user guide, and technical guide.

Files touched:

- PRESENTATION_GUIDE.md
- README.md
- USER_GUIDE.md
- TECHNICAL_GUIDE.md
- STUDENT_BUILD_HISTORY.md

Validation done:

- reviewed documentation consistency across all project handoff files

User impact:

- Easier to prepare polished dissertation figures and demo slides.
- Less ambiguity when presenting the system to supervisors, examiners, or clients.

### 2026-04-25 (slide outline pass)

Change summary:

- Added a supervisor-ready slide outline with 10 slide titles, on-slide points, and speaker notes.
- Linked the outline from the README and presentation guide.

Files touched:

- SLIDE_OUTLINE.md
- PRESENTATION_GUIDE.md
- README.md
- STUDENT_BUILD_HISTORY.md

Validation done:

- reviewed documentation structure and markdown consistency for the new presentation assets

User impact:

- Faster preparation for supervisor meetings, viva rehearsals, and presentation decks.
- Easier to keep spoken narrative aligned with the screenshots and documentation.

### 2026-04-25 (presentation deck generation pass)

Change summary:

- Added a PowerPoint generator script and created a supervisor-ready `.pptx` deck.
- Documented the generated deck location and rebuild command across the project docs.
- Added the PowerPoint generation dependency to requirements for reproducible rebuilds.

Files touched:

- generate_presentation.py
- presentations/MedAgent_Supervisor_Deck.pptx
- requirements.txt
- README.md
- USER_GUIDE.md
- TECHNICAL_GUIDE.md
- PRESENTATION_GUIDE.md
- STUDENT_BUILD_HISTORY.md

Validation done:

- generated the `.pptx` successfully
- verified generator script has no file-level errors
- confirmed the deck artifact exists in the presentations directory

User impact:

- The project now includes an actual presentation file, not only outlines and guides.
- The deck can be rebuilt consistently from a clean clone.

### 2026-04-25 (presentation screenshots and polish pass)

Change summary:

- Captured presentation-grade UI screenshots into the presentations directory.
- Updated the PowerPoint generator to embed screenshots and use a more polished visual layout.
- Added npm scripts and documentation for one-command screenshot and deck rebuilds.

Files touched:

- capture_presentation_screenshots.js
- presentations/screenshots/*
- generate_presentation.py
- package.json
- README.md
- USER_GUIDE.md
- TECHNICAL_GUIDE.md
- PRESENTATION_GUIDE.md
- STUDENT_BUILD_HISTORY.md

Validation done:

- captured screenshots successfully with Playwright
- rebuilt the `.pptx` successfully with embedded images
- spot-checked the refreshed screenshot assets and validated touched files

User impact:

- The deck now contains real product screenshots instead of placeholders.
- Presentation assets can be refreshed quickly before supervisor review or final submission.

### 2026-04-25 (shareable project cleanup pass)

Change summary:

- Removed a redundant launcher script and refactored machine-specific absolute paths out of the shareable workflow.
- Added a portable presentation build helper and documented a cleaner handover checklist.
- Marked runtime outputs such as `patients.csv` as non-shareable generated artifacts.

Files touched:

- build_presentation.js
- package.json
- qa/lifecycle.spec.js
- .gitignore
- README.md
- USER_GUIDE.md
- PRESENTATION_GUIDE.md
- TECHNICAL_GUIDE.md
- STUDENT_BUILD_HISTORY.md
- run_mac_linux.sh

Validation done:

- reviewed shareability-related path references
- prepared the repository to exclude runtime clutter from handover

User impact:

- Easier for a student to hand over a cleaner, more portable project folder.
- Less risk of leaking personal paths or unnecessary local build artifacts.

### 2026-04-25 (documentation compression pass)

Change summary:

- Condensed the main handoff documents to read more like an academic submission package.
- Reduced repetition across README, user, technical, and presentation documentation.
- Kept the required operational and presentation commands while removing low-value duplication.

Files touched:

- README.md
- USER_GUIDE.md
- PRESENTATION_GUIDE.md
- TECHNICAL_GUIDE.md
- STUDENT_BUILD_HISTORY.md

Validation done:

- reviewed documentation consistency after compression

User impact:

- Cleaner handover documents for student sharing and supervisor review.
- Less clutter while preserving the essential run, architecture, and presentation guidance.

### 2026-04-25 (submission checklist pass)

Change summary:

- Added a dedicated submission checklist for zip handover.
- Linked the checklist from the README and user guide.

Files touched:

- docs/SUBMISSION_CHECKLIST.md
- README.md
- docs/USER_GUIDE.md
- docs/STUDENT_BUILD_HISTORY.md

Validation done:

- reviewed submission guidance consistency across handoff documents

User impact:

- Students now have one explicit include/exclude checklist before sharing the project.
- Less ambiguity when preparing a clean submission package.

### 2026-04-25 (clean validation and screenshot refresh pass)

Change summary:

- Performed a full wipe and startup cycle using `./down.sh --fresh` and `./up.sh --fresh`.
- Re-ran smoke validation, Playwright end-to-end coverage, and the presentation rebuild flow.
- Stabilized screenshot capture so exported presentation images are taken after rendering settles.
- Updated the handoff and presentation docs with the verified command order.

Files touched:

- scripts/capture_presentation_screenshots.js
- README.md
- docs/USER_GUIDE.md
- docs/TECHNICAL_GUIDE.md
- docs/PRESENTATION_GUIDE.md
- docs/STUDENT_BUILD_HISTORY.md
- presentations/screenshots/*
- presentations/MedAgent_Supervisor_Deck.pptx

Validation done:

- `./down.sh --fresh`
- `./up.sh --fresh`
- `./verify_ui.sh`
- `npm run test:e2e`
- `npm run build:presentation`
- visual spot-check of regenerated screenshots

User impact:

- The project has been revalidated from a wiped baseline using the documented local flow.
- The slide deck now uses clearer screenshots that are more suitable for supervisor review and MSc presentation.

### 2026-04-25 (viva demo script pass)

Change summary:

- Added a dedicated short viva and supervisor demo script.
- Linked the script into the README and presentation documents.

Files touched:

- docs/DEMO_SCRIPT.md
- README.md
- docs/USER_GUIDE.md
- docs/TECHNICAL_GUIDE.md
- docs/PRESENTATION_GUIDE.md
- docs/SLIDE_OUTLINE.md
- docs/STUDENT_BUILD_HISTORY.md

Validation done:

- reviewed documentation consistency across demo, presentation, and handoff files

User impact:

- The student now has a ready-to-use spoken walkthrough instead of needing to improvise a viva demo.
- Presentation assets and speaking flow are now aligned in one documented set.

## Template for Future Entries

Date:

Change summary:

-

Files touched:

-

Validation done:

-

User impact:

-
