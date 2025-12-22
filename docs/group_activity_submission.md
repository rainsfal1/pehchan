# Group Activity Submission  
**Date:** 8th Dec 2025  
**Project:** Accessible Medication Assistant for Pakistan  
**Formatting note:** Structure aligns to Times New Roman, size 12, line spacing 1 (approx. 2 pages, title page excluded).

## 1) Real-world Problem (Pakistan)
Visually impaired and low-vision caregivers struggle to safely identify and use medications. Packaging varies, barcodes are often missing or damaged, instructions may be unclear, and reliable connectivity is not guaranteed. This leads to anxiety, dosing mistakes, and dependence on others.

## 2) Background, Motivation, Users
- **Background:** Medication misidentification and misuse are common when visual access is limited. Local pharmacies provide inconsistent guidance; barcodes and labels are not standardized.  
- **Motivation:** Reduce risk and anxiety, increase independence, and support inclusive access to safe medication use.  
- **Primary users:** Visually impaired and low-vision adults/caregivers in Pakistan.  
- **Secondary stakeholders:** Pharmacists/clinicians who can seed or verify trusted medication data.

## 3) Objectives, Scope, Features, Constraints
- **Objectives:**  
  - Enable safe, independent medication identification and guidance.  
  - Provide multimodal feedback (audio, haptics, high-contrast UI) that works offline.  
  - Offer small curated local data (20–50 Pakistani medicines) with allergy alerts.
- **Scope (MVP):**  
  - Offline medication lookup from a bundled local database.  
  - Camera-based identification via barcode + OCR + optional packaging detector.  
  - Audio/semantic guidance for usage, warnings, allergy matches, and expiry cues.  
  - Customizable contrast/colors and TTS speed; demo mode with seeded sample meds.
- **Constraints:**  
  - Offline-first; mid-range Android hardware targets.  
  - Limited training data for local packaging; barcodes may be absent.  
  - Minimal user text entry; privacy-first (no cloud sync by default).

## 4) Intelligence Approach
- **Kind of intelligence:** Predictive and adaptive.  
- **Predictive:** Fuse barcode, OCR, and a lightweight on-device packaging detector (TFLite) to pick the most likely medicine when codes are missing.  
- **Adaptive:** Adjust prompt verbosity, language, and TTS speed to user preferences and past interaction patterns (e.g., shorten instructions after repeated successful use).  
- **Optional emotional tone:** Gentle confirmations on success and neutral prompts on failure to reduce user stress.

## 5) Extent of Intelligence
- **On-device models:**  
  - Barcode/OCR fusion with fallback fuzzy name matching.  
  - Small packaging classifier/detector trained on a limited set of common Pakistani meds.  
- **Adaptation boundaries:**  
  - Remembers user preferences (language, TTS speed, contrast).  
  - Context-aware prompting (brief vs. detailed guidance).  
- **Out of scope:** Deep personal profiling or cloud-based personalization; no large-scale user modeling to avoid privacy risk.

## 6) Accessibility, Inclusivity, HCI Validation
- **Accessibility:** Large touch targets; high-contrast themes; screen reader–friendly semantics; haptic feedback on scan success; clear audio cues; adjustable TTS speed; offline operation.  
- **Inclusivity:** English localization with room for Urdu transliterations; works in low-connectivity contexts; streamlined flows with minimal text entry.  
- **HCI principles:** Consistency (uniform navigation/feedback), error prevention (vibration/audio confirmations, clear states), visibility of system status (live scan feedback), flexibility (custom colors, TTS speed), user control (easy home/back, mute).

## 7) Ethical and Privacy Concerns
- **Data privacy:** Offline by default; no automatic cloud upload. If cloud updates are added, they require explicit consent and minimal telemetry.  
- **Bias/coverage:** Small model and dataset may miss unrepresented brands; mitigate by showing confidence and providing manual confirmation paths.  
- **Safety:** The app is assistive, not prescriptive. Include clear disclaimers and encourage consulting pharmacists/doctors for ambiguities.

## 8) Evolution as It Learns
- **Model updates:** Periodic optional on-device updates to the small packaging detector as more local images are collected with consent.  
- **Preference learning:** Refine prompt length, TTS speed, and contrast based on observed choices.  
- **DB growth:** Expand curated medication set and allergen synonyms; improve fallback matching with local language variants.  
- **Feedback loop:** Lightweight “Was this correct?” prompts (opt-in) to improve confidence thresholds without storing personal identifiers.

## Architecture (High Level)
- **Presentation layer (Flutter):**  
  - Navigation: GoRouter; accessibility semantics for all interactive elements.  
  - Multimodal UI: TTS, haptics (vibration), high-contrast themes, large buttons.  
  - Camera pipeline: ML Kit barcode + text recognition; optional TFLite packaging detector.  
  - Settings: language/TTS speed, color/contrast, screen-reader toggle, demo mode.
- **Data layer (offline-first):**  
  - Local SQLite DB seeded with curated Pakistani meds (name, barcode, ingredients, usage, warnings, expiry cues, manufacturer).  
  - Local CSVs for barcode/ingredient lookup as backup or for import.  
  - Optional controlled updater for DB/model (manual trigger, user-consented).
- **ML layer (on-device):**  
  - ML Kit (OCR/barcode).  
  - Lightweight TFLite packaging classifier/detector (fallback when barcode missing).  
  - Fusion logic to resolve ID and drive guidance.
- **Feedback services:**  
  - TTS (English default, optional Urdu transliterations), audio cues, vibration cues.

## Tech Stack
- **Framework:** Flutter (Dart), offline-first.  
- **Mobile services:** Camera, vibration, TTS.  
- **ML:** Google ML Kit (barcode/OCR), TFLite (packaging detector).  
- **Data:** SQLite (meds, ingredients, warnings, allergens), CSV import.  
- **Routing/State:** GoRouter, Provider/ChangeNotifier for app state.  
- **Assets:** Local images for packaging cues and semantic labels; localized strings (English, optional Urdu transliterations).

## Data Plan (Curated and Ethical)
- **Seed set (20–50 meds):** Common Pakistani OTC/regular meds with barcodes (where available), images, ingredients, indications, warnings, child precautions.  
- **Packaging images:** Self-captured photos of selected SKUs (front/back/angles) to train/evaluate the small detector; avoid personal data in captures.  
- **Allergen list:** English ingredient names plus common aliases for fuzzy matching.  
- **No PHI:** The app does not collect patient identifiers; all inference is on-device.

## Evaluation and Success Criteria
- **Functional:** Correctly surfaces a matching med for the curated set (barcode or fallback) and reads out core info.  
- **Accessibility:** TalkBack/VoiceOver-friendly; haptic/audio confirmations; readable contrast and sizing on mid-range devices.  
- **ML:** For the packaging detector, measure top-1 accuracy/precision on held-out local photos; show confidence and allow manual confirm.  
- **Usability:** Short task-time for “identify and hear warnings,” low error rate, positive SUS-like feedback in a small user study.

## Risks and Mitigations
- **Low barcode coverage:** Mitigate with OCR + packaging detector fallback and fuzzy text matching.  
- **Small training set:** Start with a narrow SKU set; retrain as more images are collected (consented).  
- **Device constraints:** Use lightweight models (TFLite, small input sizes) and limit background work.  
- **Safety:** Keep medical disclaimers visible/audible; prompt users to verify with pharmacists for uncertain cases.
