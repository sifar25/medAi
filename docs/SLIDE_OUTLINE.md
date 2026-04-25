# MedAgent Supervisor Slide Outline

## Purpose

This outline is a ready-to-present slide structure for supervisor meetings, viva preparation, and MSc project updates.

Use it together with PRESENTATION_GUIDE.md and DEMO_SCRIPT.md so the spoken narrative, screenshots, and captions stay aligned.

## Slide 1. Project title and problem framing

Suggested title:

MedAgent: Human-Centred AI Support for Medication Adherence in Chronic Illness

On-slide points:

- MSc prototype focused on early identification of medication non-adherence risk
- Built for chronic illness follow-up using synthetic local data
- Designed as a clinician-support tool, not an autonomous decision-maker

Speaker notes:

Open by defining the problem clearly: patients with chronic conditions often struggle with ongoing medication adherence, and clinicians need an earlier, more structured way to spot support needs. State that this prototype explores how predictive analytics and human-readable support recommendations can improve visibility without removing clinician judgment.

Suggested visual:

- title slide with project name and one clean dashboard image or brand screen

## Slide 2. Motivation and research aim

Suggested title:

Why This Problem Matters

On-slide points:

- missed medication can worsen long-term outcomes
- non-adherence is influenced by behaviour, routine, side effects, and follow-up barriers
- research goal: combine prediction with practical, human-readable action support

Speaker notes:

Explain that the project is not only about predicting a label. The research aim is to make the output usable in practice by turning risk signals into readable summaries and realistic follow-up suggestions. That is the human-centred part of the system.

Suggested visual:

- simple problem statement slide with minimal text and one supporting screenshot or diagram placeholder

## Slide 3. System overview

Suggested title:

Prototype Architecture Overview

On-slide points:

- Flask web interface for login, dashboard, assessments, and training
- Random Forest model for adherence-risk prediction
- agent layer for explanation and support-plan generation
- CSV-backed synthetic dataset for local reproducible operation

Speaker notes:

Walk through the system from input to output: the user opens the local web interface, enters or selects a patient context, the model estimates non-adherence risk, and the agent layer transforms that result into a readable explanation and action plan. Emphasise that the architecture is intentionally simple and reproducible for MSc demonstration purposes.

Suggested visual:

- simple three-layer architecture diagram or labelled screenshot montage

## Slide 4. Dashboard and case overview

Suggested title:

Clinician-Facing Dashboard

On-slide points:

- summary cards show overall case distribution
- search, filtering, and pagination support structured review
- dashboard acts as the triage entry point into the system

Speaker notes:

Use the dashboard to show how the interface moved beyond a raw prototype table. Explain that the dashboard now supports population-level review, letting the user scan overall risk distribution, focus on selected conditions or risk bands, and navigate cases more cleanly.

Suggested visual:

- Figure 3 from PRESENTATION_GUIDE.md

## Slide 5. Targeted exploration and usability improvements

Suggested title:

Usability Improvements for Review Workflows

On-slide points:

- filtered dashboard state demonstrates search and segmentation
- pagination improves readability for larger record sets
- screen polish supports clearer demonstration and assessment

Speaker notes:

This slide is where you justify the final polish work. Explain that filters and pagination are not decorative changes; they make the workflow more realistic and presentable. Mention that the interface was refined to support a proper MSc demonstration rather than a rough technical mock-up.

Suggested visual:

- Figure 4 from PRESENTATION_GUIDE.md

## Slide 6. Patient-level explanation and support output

Suggested title:

From Risk Prediction to Human-Readable Guidance

On-slide points:

- risk level and confidence shown clearly
- explanatory factors summarise why a patient is concerning
- support plan translates analytics into follow-up actions
- high-risk cases explicitly retain clinician oversight

Speaker notes:

Show that the system does two jobs: prediction and interpretation. Explain that the system does not stop at a risk label. It adds explanation, contributing factors, and recommended support actions so the output is easier to discuss with supervisors, clinicians, or evaluators.

Suggested visual:

- Figures 5 and 6 from PRESENTATION_GUIDE.md

## Slide 7. Interactive assessment workflow

Suggested title:

Running a New Assessment Live

On-slide points:

- new patient scenarios can be entered through the form
- optional persistence allows demo data to be retained
- duplicate protection prevents accidental repeated insertion

Speaker notes:

Use this slide to explain how a live demo works. A user can enter a new patient scenario, generate a result, and optionally save it into the working dataset. Re-submitting the same payload will not create a duplicate row, which supports safe and repeatable demonstrations.

Suggested visual:

- Figures 7 and 8 from PRESENTATION_GUIDE.md

## Slide 8. Reliability and operational design

Suggested title:

Reproducibility, Idempotency, and Local Execution

On-slide points:

- health-checked startup and controlled shutdown scripts
- seed reset and fresh-start flags for deterministic demos
- restart-safe behaviour preserves user-added records unless explicitly reset
- Windows, macOS, and Ubuntu guidance documented

Speaker notes:

This is the slide to defend engineering quality. Explain that the project is not just a model in a notebook. It includes repeatable startup and shutdown flows, data reset controls, and validation scripts so the system can be run consistently for marking, supervision, or demonstration.

Suggested visual:

- Figure 1 or Figure 10 from PRESENTATION_GUIDE.md

## Slide 9. Validation and evidence

Suggested title:

What Was Tested

On-slide points:

- smoke validation covers login, dashboard, assessment, save, and dedupe
- Playwright browser tests cover lifecycle and UI flow
- current build passed both shell and browser validation

Speaker notes:

Keep this grounded and factual. State that the prototype was validated through executable tests, not only manual clicking. Mention the smoke suite and the Playwright suite, and note that they now cover the updated dashboard controls as well as the core patient flow.

Suggested visual:

- terminal output showing passing validation

## Slide 10. Contribution, limitations, and next steps

Suggested title:

Contribution and Next Development Steps

On-slide points:

- contribution: combines predictive triage with human-readable support recommendations
- limitation: synthetic data and prototype-level local deployment only
- next steps: stronger analytics, richer reporting, and broader clinical validation

Speaker notes:

Close with a balanced summary. State the contribution confidently, but also note the current boundaries: synthetic data, local deployment, and prototype-level scope. That makes the evaluation more credible. End by describing how the project could evolve into stronger reporting, better datasets, and wider validation.

Suggested visual:

- clean closing slide with 3 concise columns: contribution, limitation, next step

## Delivery tips

- Keep slides visually light; speak the detail rather than filling the slide with paragraphs.
- Prefer one screenshot or one idea per slide.
- When discussing confidence scores, describe them as model confidence within the prototype, not as clinical certainty.
- Repeat the phrase clinician-supporting at least once in the talk to reinforce scope.
- If time is short, present Slides 1, 3, 4, 6, 8, and 10 only.
