# REPORT — Garment Quality Diagnosis Expert System

---

## 1. Introduction

This report documents the design, implementation, and testing of an expert system for diagnosing common garment sewing and quality defects. The system uses source-backed production rules to identify possible causes of observed defects and provides corrective information where the source documents supply remedies.

The system is implemented in SWI-Prolog with a browser-based user interface and supports both forward chaining and backward chaining inference methods.

---

## 2. Selected Domain

**Domain**: Garment Manufacturing and Apparel Quality Control

Garment manufacturing involves multiple production stages including spreading, cutting, bundling, sewing, pressing, and finishing. Quality defects can arise at any stage, but sewing defects are among the most common and consequential. These defects include needle damage, skipped stitches, thread breaks, broken stitches, seam grin, seam pucker, and improperly formed stitches.

**Why this domain is suitable for an expert system:**

1. **Rule-based knowledge**: The relationships between defects and their causes are well-documented in published quality-control literature and follow clear IF-THEN patterns.
2. **Diagnostic nature**: The problem involves diagnosing the cause of an observed defect based on observable conditions — a classic expert system task.
3. **Source availability**: Published apparel quality-control and sewing-technology references explicitly document defect-cause relationships that can be formally represented as production rules.
4. **Practical relevance**: Quality diagnosis in garment manufacturing is a real industrial need where expert knowledge is valuable.

---

## 3. Problem Definition

The system diagnoses common garment sewing and quality defects based on observed defect characteristics and known production conditions. It identifies documented possible causes and provides the corresponding corrective information available from the knowledge sources.

**Input**: An observed defect type and a set of observable production conditions (e.g., needle condition, thread tension, stitch type).

**Output**: Possible causes identified by triggered rules, the source reference for each rule, corrective actions where documented, and a complete reasoning trace.

---

## 4. System Objective

To provide an automated diagnosis tool that:

1. Accepts user observations about garment defects and production conditions
2. Applies source-backed diagnostic rules using forward or backward chaining
3. Identifies possible causes of the observed defects
4. Displays the source reference and reasoning trace for each conclusion
5. Provides corrective actions where the source documents include remedies

---

## 5. Knowledge Acquisition

No domain expert was consulted because expert consultation was not mandatory according to the assignment guidelines. Knowledge was acquired from published apparel quality-control and sewing-technology sources.

The identified defect-cause relationships were extracted from the source texts and then represented as formal IF-THEN rules in the expert system. Each rule corresponds to a specific statement in the source material about what conditions cause or contribute to a particular defect.

**Acquisition process:**

```
Published source document
         ↓
Identify defect-cause statements
         ↓
Extract condition → cause relationships
         ↓
Formalize as IF-THEN rules
         ↓
Encode in Prolog with source metadata
```

---

## 6. Sources of Knowledge

| Source ID | Document | Publisher | URL |
|-----------|----------|-----------|-----|
| INFLIBNET_HSP08 | Apparel Quality Analysis — Common Defects in Sewing | INFLIBNET / UGC | [Link](https://ebooks.inflibnet.ac.in/hsp08/chapter/apparel-quality-analysis-common-defects-in-spreading-cutting-bundling-sewing-pressing-and-finishing-quality-control-in-apparel-production/) |
| INFLIBNET_HSP07 | Quality Control — Concept, Principles, Standards | INFLIBNET / UGC | [Link](https://ebooks.inflibnet.ac.in/hsp07/chapter/quality-control-concept-principles-standards-and-specifications-quality-assurance-care-symbols-standard-symbols/) |
| CITS_SEWING | Sewing Technology (Trade Practical) — Volume 2 | CITS / Bharat Skills | [Link](https://bharatskills.gov.in/pdf/E_Books/CITS/431/English/Sewing%20technology%20(Trade%20Practical)%20-%20(Volume%20-%202).pdf) |
| CHOUDHARY_2018 | The Study of Sewing Damage and Defects in Garments | Emerald, 2018 | [DOI](https://doi.org/10.1108/RJTA-08-2017-0041) |

---

## 7. Knowledge Representation

Knowledge is represented using Prolog facts and rules:

**Facts** represent:
- Defect types (8 categories of garment sewing defects)
- Observable conditions (19 condition types with their possible values)
- Defect-condition relevance mappings
- Source URLs and metadata

**Rules** represent:
- Diagnostic rules mapping defect + condition combinations to possible causes
- Each rule stores: Rule ID, defect, required conditions, concluded cause, source ID, source name, and source explanation

```
Source statement:
  "Needle damage can be caused by a blunt needle"
         ↓
Formal rule:
  IF defect = needle_damage AND needle_condition = blunt
  THEN cause = blunt_needle
         ↓
Prolog representation:
  rule(r02, needle_damage,
      [condition(needle_condition, blunt)],
      blunt_needle,
      'INFLIBNET_HSP08',
      'INFLIBNET e-PG Pathshala - Apparel Quality Analysis',
      'The source identifies a blunt needle as a cause of needle damage').
```

---

## 8. Knowledge Base

The knowledge base contains:

- **8 defect categories**: needle damage, skipped stitches, thread breaks, broken stitches, seam grin, seam pucker, improperly formed stitches, stitch density problems
- **19 condition types**: needle type, needle condition, needle heat, machine feeding, thread suitability, needle size, fabric feed, thread thickness, thread tension, stitch type, seam joint, feed condition, machine pressure, stitch size, operator handling, notch alignment, stitch density, machine timing, machine components
- **28 diagnostic rules**: each with source metadata
- **Source-backed corrective actions are provided for rules where the consulted sources explicitly document a remedy.**
- **Defect-condition relevance mappings**: so the UI only shows relevant conditions for each defect

---

## 9. Rule Design and Source Mapping

All 28 rules are formal representations of defect-cause relationships documented in the listed sources. No rules were invented.

| Rule | Knowledge Represented | Source |
|------|----------------------|--------|
| R01 | Wrong needle type → needle damage | INFLIBNET_HSP08 |
| R02 | Blunt needle → needle damage | INFLIBNET_HSP08 |
| R03 | Needle heat → needle damage | INFLIBNET_HSP08 |
| R04 | Feeding difficulty → needle damage | INFLIBNET_HSP08 |
| R05 | Unsuitable thread → skipped stitches | CITS_SEWING |
| R06 | Defective needle → skipped stitches | CITS_SEWING |
| R07 | Wrong needle size → skipped stitches | CITS_SEWING |
| R08 | Poor fabric feed → skipped stitches | CITS_SEWING |
| R09 | Thick thread → thread breaks | INFLIBNET_HSP08 |
| R10 | Thin thread → thread breaks | INFLIBNET_HSP08 |
| R11 | Needle heat → thread breaks | INFLIBNET_HSP08 |
| R12 | Tight tension → thread breaks | INFLIBNET_HSP08 |
| R13 | Wrong stitch type → broken stitches | INFLIBNET_HSP08 |
| R14 | Tight tension → broken stitches | INFLIBNET_HSP08 |
| R15 | Bad seam joint → broken stitches | INFLIBNET_HSP08 |
| R16 | Sharp feed → broken stitches | INFLIBNET_HSP08 |
| R17 | Excessive pressure → broken stitches | INFLIBNET_HSP08 |
| R18 | Loose tension → seam grin | INFLIBNET_HSP08 |
| R19 | Large stitch → seam grin | INFLIBNET_HSP08 |
| R20 | Wrong stitch type → seam grin | INFLIBNET_HSP08 |
| R21 | Incorrect handling → seam pucker | INFLIBNET_HSP08 |
| R22 | Misaligned notches → seam pucker | INFLIBNET_HSP08 |
| R23 | Tight tension → seam pucker | INFLIBNET_HSP08 + CITS_SEWING |
| R24 | Excessive density → fabric thread rupture | INFLIBNET_HSP08 |
| R25 | Low density → grinning/weak seam | INFLIBNET_HSP08 |
| R26 | Bad tension → improperly formed stitches | INFLIBNET_HSP08 |
| R27 | Incorrect timing → improperly formed stitches | INFLIBNET_HSP08 |
| R28 | Ill-fitting components → improperly formed stitches | INFLIBNET_HSP08 |

---

## 10. Inference Engine

The system implements two inference methods. The user selects the method before running a diagnosis.

### 10.1 Forward Chaining

**Algorithm:**
1. Collect user observations (defect type + condition values)
2. Scan all rules in the knowledge base for the selected defect
3. For each rule, check if ALL required conditions are satisfied by the observations
4. If all conditions match, fire the rule and record the conclusion
5. Return all fired rules with their causes, sources, and reasoning traces

**Characteristics:**
- Data-driven (starts from observations)
- May fire multiple rules if multiple conditions are set
- Shows all possible causes supported by the given observations

### 10.2 Backward Chaining

**Algorithm:**
1. Accept a hypothesis (a possible cause to investigate)
2. Find all rules that conclude the hypothesis for the selected defect
3. For each rule, check each required condition against the observations
4. Classify conditions as satisfied or missing
5. If all conditions are satisfied, the hypothesis is PROVEN
6. If any condition is missing, the hypothesis is NOT PROVEN via that rule

**Characteristics:**
- Goal-driven (starts from a hypothesis)
- Shows which conditions are satisfied and which are missing
- Useful for verifying a suspected cause

---

## 11. Explanation Facility

Every diagnosis produces a structured explanation containing:

1. **Observed facts**: The conditions the user reported
2. **Rule triggered**: The specific rule ID that fired
3. **Source of rule**: The published document supporting the rule
4. **Reasoning trace**: Step-by-step description of the inference process
5. **Conclusion**: The diagnosed cause
6. **Corrective action**: Source-backed remedy, or explicit indication that no source-backed action is available

**Example explanation (Forward Chaining):**

```
FORWARD CHAINING REASONING TRACE
══════════════════════════════════════════════════════

Step 1: Collect Observations
  • thread tension = Thread tension too tight

Step 2: Scan Rules for Defect "Seam Pucker"
  Checking all rules whose defect matches...

Step 3: Evaluate R23
  Rule: R23
  Conditions required:
    ✓ thread tension = too_tight [SATISFIED]
  All conditions satisfied → RULE FIRES
  Source: INFLIBNET e-PG Pathshala AND CITS Sewing Technology
  → Conclusion: Possible cause = tight thread tension

══════════════════════════════════════════════════════
DIAGNOSIS COMPLETE: 1 rule(s) fired.
```

---

## 12. System Architecture

```
                        USER
                          │
                          ▼
                ┌───────────────────┐
                │   Browser-Based   │
                │   User Interface  │
                │   (HTML/CSS/JS)   │
                └────────┬──────────┘
                         │ HTTP
                         ▼
                ┌───────────────────┐
                │   HTTP Server     │
                │   (ui.pl)         │
                │   SWI-Prolog      │
                └────────┬──────────┘
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
    ┌──────────────────┐  ┌──────────────────┐
    │ User Observations │  │ Hypothesis       │
    │ (defect + conds)  │  │ (backward only)  │
    └────────┬─────────┘  └────────┬─────────┘
             │                     │
             └──────────┬──────────┘
                        ▼
              ┌──────────────────┐
              │  KNOWLEDGE BASE  │
              │  (knowledge_     │
              │   base.pl +      │
              │   rules.pl)      │
              │                  │
              │  • 8 Defects     │
              │  • 19 Conditions │
              │  • 28 Rules      │
              │  • Source IDs    │
              └────────┬─────────┘
                       │
            ┌──────────┴──────────┐
            ▼                     ▼
   ┌────────────────┐   ┌────────────────┐
   │    FORWARD      │   │   BACKWARD     │
   │    CHAINING     │   │   CHAINING     │
   │  (inference.pl) │   │ (inference.pl) │
   └────────┬────────┘   └────────┬───────┘
            │                     │
            └──────────┬──────────┘
                       ▼
              ┌──────────────────┐
              │   EXPLANATION    │
              │   FACILITY      │
              │ (explanation.pl) │
              │                  │
              │ • Rule trace     │
              │ • Source refs    │
              │ • Corrective     │
              │   actions        │
              └────────┬─────────┘
                       │
                       ▼
              ┌──────────────────┐
              │  DIAGNOSIS       │
              │  RESULT          │
              │                  │
              │ • Cause          │
              │ • Rule ID        │
              │ • Source          │
              │ • Corrective     │
              │ • Reasoning trace│
              └──────────────────┘
```

---

## 13. Interface

The system provides a browser-based interface at `http://localhost:3050`.

**Interface components:**

1. **Step 1 — Inference Method**: Radio buttons to select Forward or Backward chaining
2. **Step 2 — Defect Selection**: Dropdown showing all 8 defect categories with descriptions
3. **Step 3 — Conditions**: Dynamic grid showing only the relevant conditions for the selected defect, each with a dropdown of possible values and a "Not specified" default
4. **Hypothesis Selection** (Backward only): Dropdown showing all possible causes for the defect
5. **Diagnosis Button**: Triggers the inference and displays results
6. **Results Section**: Shows fired rules, causes, sources, corrective actions, and the full reasoning trace
7. **Rules Table**: Expandable table showing all 28 rules and their sources

**Design characteristics:**
- Luxury tailoring theme with warm brown, gold, and cream accent colors
- Custom 4K fashion runway background image (unway.png) embedded in the UI
- Premium glassmorphism effect on interactive cards
- Inter font family
- Responsive layout
- Step-by-step guided workflow
- Dynamic condition loading based on selected defect

---

## 14. Implementation

**Technology**: SWI-Prolog with built-in HTTP server

**Module structure:**

| File | Purpose |
|------|---------|
| `app.pl` | Main entry point, loads all modules, starts server |
| `knowledge_base.pl` | Domain facts (defects, conditions, values, relevance mappings) |
| `rules.pl` | 28 diagnostic rules with source metadata, corrective actions |
| `inference.pl` | Forward and backward chaining inference engines |
| `explanation.pl` | Explanation facility, source URL mapping, result formatting |
| `ui.pl` | HTTP server, route handlers, HTML/CSS/JS generation |

**Key implementation decisions:**

1. **Single-page application**: The entire UI is served as a single HTML page with JavaScript making API calls for dynamic content
2. **JSON API**: The Prolog backend exposes REST-like endpoints for defects, conditions, causes, and diagnosis
3. **Modular Prolog**: Clear separation between knowledge, rules, inference, explanation, and UI
4. **Source metadata in rules**: Every rule stores its source ID, full source name, and explanation as part of the rule term

---

## 15. Test Cases

Eleven test cases were designed covering:
- Forward chaining diagnosis
- Multiple-rule firing
- Backward chaining verification
- Insufficient information handling
- Multiple defect categories
- Multiple source references

See TEST_CASES.md for the complete test specification.

> **Note**: Actual results must be verified by running the system locally. The expected results are based on the implemented rules and logic.

---

## 16. Results

The system is expected to produce the following results when tested:

1. **Forward chaining** correctly fires rules whose conditions are satisfied by user observations
2. **Backward chaining** correctly identifies whether a hypothesis can be proven from observations
3. **Source references** are displayed for every triggered rule
4. **Corrective actions** are shown when the source provides them
5. **"No source-backed corrective action"** is displayed when no remedy is documented
6. **Reasoning traces** show the complete step-by-step inference process
7. **Insufficient information** is handled gracefully with a "No Rules Fired" message

> **Note**: Runtime verification must be performed on the user's Windows machine with SWI-Prolog installed.

---

## 17. Limitations

1. The system covers only sewing-related garment defects. Defects from spreading, cutting, pressing, and finishing are not included.
2. The system does not learn new rules automatically. New defect-cause relationships must be manually added to `rules.pl`.
3. Corrective actions are only provided where the source documents include explicit remedies. Not all rules have corrective actions.
4. The system diagnoses possible causes but does not rank them by likelihood.
5. The system does not handle multi-step causal chains (e.g., one cause leading to another cause).

---

## 18. Conclusion

The Garment Quality Diagnosis Expert System successfully demonstrates the core components of an expert system:

1. **Knowledge base** with 28 source-backed rules covering 8 garment defect categories
2. **Dual inference engine** supporting both forward and backward chaining
3. **Explanation facility** providing full reasoning traces with source references
4. **Browser-based interface** for accessible interaction

All rules are traceable to published apparel quality-control and sewing-technology sources. No rules were invented, no expert interviews were fabricated, and no factory data was claimed.

---

## 19. References

See REFERENCES.md for the complete list of sources with URLs and source-rule mappings.

---

# Annex A — Decision-Making Logic

All 28 implemented rules are listed below with their conditions, conclusions, and sources.

| Rule ID | Conditions | Conclusion | Source |
|---------|-----------|------------|--------|
| R01 | defect = needle_damage AND needle_type = wrong | cause = wrong_needle_type | INFLIBNET_HSP08 |
| R02 | defect = needle_damage AND needle_condition = blunt | cause = blunt_needle | INFLIBNET_HSP08 |
| R03 | defect = needle_damage AND needle_heat = excessive | cause = needle_heat | INFLIBNET_HSP08 |
| R04 | defect = needle_damage AND machine_feeding = difficult | cause = machine_feeding_difficulty | INFLIBNET_HSP08 |
| R05 | defect = skipped_stitches AND thread_suitability = unsuitable | cause = unsuitable_thread | CITS_SEWING |
| R06 | defect = skipped_stitches AND needle_condition = defective | cause = defective_needle | CITS_SEWING |
| R07 | defect = skipped_stitches AND needle_size = wrong | cause = wrong_needle_size | CITS_SEWING |
| R08 | defect = skipped_stitches AND fabric_feed = poor | cause = poor_fabric_feed | CITS_SEWING |
| R09 | defect = thread_breaks AND thread_thickness = too_thick | cause = thread_too_thick_for_needle | INFLIBNET_HSP08 |
| R10 | defect = thread_breaks AND thread_thickness = too_thin | cause = thread_too_thin | INFLIBNET_HSP08 |
| R11 | defect = thread_breaks AND needle_heat = excessive | cause = needle_heat | INFLIBNET_HSP08 |
| R12 | defect = thread_breaks AND thread_tension = too_tight | cause = excessive_thread_tension | INFLIBNET_HSP08 |
| R13 | defect = broken_stitches AND stitch_type = wrong | cause = wrong_stitch_type | INFLIBNET_HSP08 |
| R14 | defect = broken_stitches AND thread_tension = too_tight | cause = excessive_thread_tension | INFLIBNET_HSP08 |
| R15 | defect = broken_stitches AND seam_joint = badly_formed | cause = badly_formed_seam_joint | INFLIBNET_HSP08 |
| R16 | defect = broken_stitches AND feed_condition = sharp | cause = sharp_feed | INFLIBNET_HSP08 |
| R17 | defect = broken_stitches AND machine_pressure = excessive | cause = excessive_machine_pressure | INFLIBNET_HSP08 |
| R18 | defect = seam_grin AND thread_tension = too_loose | cause = loose_thread_tension | INFLIBNET_HSP08 |
| R19 | defect = seam_grin AND stitch_size = too_large | cause = excessive_stitch_size | INFLIBNET_HSP08 |
| R20 | defect = seam_grin AND stitch_type = wrong | cause = wrong_stitch_type | INFLIBNET_HSP08 |
| R21 | defect = seam_pucker AND operator_handling = incorrect | cause = incorrect_operator_handling | INFLIBNET_HSP08 |
| R22 | defect = seam_pucker AND notch_alignment = misaligned | cause = misaligned_notches | INFLIBNET_HSP08 |
| R23 | defect = seam_pucker AND thread_tension = too_tight | cause = tight_thread_tension | INFLIBNET_HSP08 + CITS_SEWING |
| R24 | stitch_density = too_high | possible_problem = fabric_thread_rupture | INFLIBNET_HSP08 |
| R25 | stitch_density = too_low | possible_problem = seam_grinning_or_weak_seam | INFLIBNET_HSP08 |
| R26 | defect = improperly_formed_stitches AND thread_tension = bad | cause = bad_tension | INFLIBNET_HSP08 |
| R27 | defect = improperly_formed_stitches AND machine_timing = incorrectly_adjusted | cause = incorrect_machine_timing | INFLIBNET_HSP08 |
| R28 | defect = improperly_formed_stitches AND machine_components = ill_fitting | cause = ill_fitting_machine_components | INFLIBNET_HSP08 |

---

# Annex B — Source Documents

### Source 1: INFLIBNET_HSP08
- **Title**: Apparel Quality Analysis — Common Defects in Spreading, Cutting, Bundling, Sewing, Pressing and Finishing
- **Publisher**: INFLIBNET e-PG Pathshala (UGC, Government of India)
- **URL**: https://ebooks.inflibnet.ac.in/hsp08/chapter/apparel-quality-analysis-common-defects-in-spreading-cutting-bundling-sewing-pressing-and-finishing-quality-control-in-apparel-production/

### Source 2: INFLIBNET_HSP07
- **Title**: Quality Control — Concept, Principles, Standards and Specifications
- **Publisher**: INFLIBNET e-PG Pathshala (UGC, Government of India)
- **URL**: https://ebooks.inflibnet.ac.in/hsp07/chapter/quality-control-concept-principles-standards-and-specifications-quality-assurance-care-symbols-standard-symbols/

### Source 3: CITS_SEWING
- **Title**: Sewing Technology (Trade Practical) — Volume 2
- **Publisher**: CITS / Bharat Skills (Directorate General of Training, Government of India)
- **URL**: https://bharatskills.gov.in/pdf/E_Books/CITS/431/English/Sewing%20technology%20(Trade%20Practical)%20-%20(Volume%20-%202).pdf

### Source 4: CHOUDHARY_2018
- **Title**: The Study of Sewing Damage and Defects in Garments
- **Authors**: Choudhary, A.K., Sikka, M., and Bansal, P.
- **Journal**: Research Journal of Textile and Apparel, 2018
- **DOI**: https://doi.org/10.1108/RJTA-08-2017-0041

---

# Annex C — User Manual

See USER_MANUAL.md for detailed instructions on:

1. Installing SWI-Prolog on Windows
2. Starting the expert system
3. Using forward chaining
4. Using backward chaining
5. Viewing all rules and sources
6. Understanding the results
7. Stopping the system
8. Troubleshooting

**Quick Start:**

```
1. Install SWI-Prolog from https://www.swi-prolog.org/download/stable
2. Open PowerShell
3. cd "D:\ExpertSystem\garment-expert-system"
4. swipl app.pl
5. Open http://localhost:3050 in your browser
6. Select inference method → Select defect → Set conditions → Run Diagnosis
7. Press Ctrl+C then "e" to stop
```


