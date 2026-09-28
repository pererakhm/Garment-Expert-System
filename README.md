# Garment Quality Diagnosis Expert System

A university expert system for diagnosing common garment sewing and quality defects. The system uses **28 source-backed rules** derived from published apparel quality-control and sewing-technology references.

## Key Features

- **28 source-backed rules** â€” Every rule is traceable to a published source
- **Forward chaining** â€” Data-driven inference from observations to conclusions
- **Backward chaining** â€” Goal-driven inference from hypothesis to verification
- **Explanation facility** â€” Full reasoning trace with rule IDs and source references
- **Browser-based UI** â€” Professional web interface at `http://localhost:3050`
- **Source transparency** â€” Every triggered rule displays its source document and URL

## Knowledge Sources

| Source ID | Source Document | URL |
|-----------|----------------|-----|
| INFLIBNET_HSP08 | Apparel Quality Analysis — Common Defects in Sewing | [Link](https://ebooks.inflibnet.ac.in/hsp08/chapter/apparel-quality-analysis-common-defects-in-spreading-cutting-bundling-sewing-pressing-and-finishing-quality-control-in-apparel-production/) |
| CITS_SEWING | CITS / Bharat Skills — Sewing Technology | [Link](https://bharatskills.gov.in/pdf/E_Books/CITS/431/English/Sewing%20technology%20(Trade%20Practical)%20-%20(Volume%20-%202).pdf) |

## Prerequisites

- **SWI-Prolog** (version 8.0 or later)
  - Download from: https://www.swi-prolog.org/download/stable

## How to Run (Windows)

### Step 1: Install SWI-Prolog

1. Download SWI-Prolog from https://www.swi-prolog.org/download/stable
2. Run the installer
3. **Important**: During installation, check the option to **add SWI-Prolog to the system PATH**
4. Restart your terminal after installation

### Step 2: Verify Installation

Open PowerShell and run:

```powershell
swipl --version
```

You should see the SWI-Prolog version number.

### Step 3: Navigate to Project Folder

```powershell
cd "D:\ExpertSystem\garment-expert-system"
```

### Step 4: Run the Application

```powershell
swipl app.pl
```

*(If you get an error saying 'swipl' is not recognized, run this instead:)*
```powershell
& "C:\Program Files\swipl\bin\swipl.exe" app.pl
```

You should see:

```
  =====================================================
  GARMENT QUALITY DIAGNOSIS EXPERT SYSTEM
  =====================================================

  Total Rules in Knowledge Base: 28

  Starting HTTP server on port 3050...

  Open your browser and go to:
    http://localhost:3050
  =====================================================
```

### Step 5: Open the Application

Open your web browser and go to:

```
http://localhost:3050
```

### Step 6: Test Forward Chaining

1. Select **Forward Chaining** as the inference method
2. Select a defect (e.g., "Needle Damage")
3. Set a condition (e.g., Needle Condition = "Blunt / worn needle")
4. Click **Run Diagnosis**
5. View the result showing Rule R02, the source (INFLIBNET), and the reasoning trace

### Step 7: Test Backward Chaining

1. Select **Backward Chaining** as the inference method
2. Select a defect (e.g., "Skipped Stitches")
3. Select a hypothesis (e.g., "defective_needle (R06, CITS_SEWING)")
4. Set the condition Needle Condition = "Defective needle"
5. Click **Run Diagnosis**
6. View the proof result showing the hypothesis is confirmed

### Step 8: Stop the Application

**To stop the system:** Press `Ctrl+C` in the terminal running the server. If SWI-Prolog enters its interrupt prompt, follow the prompt to exit.

## Project Structure

`	ext
garment-expert-system/
¦
+-- app.pl              # Main application entry point
+-- knowledge_base.pl   # Domain facts (defects, conditions, values)
+-- rules.pl            # 28 source-backed diagnostic rules
+-- inference.pl        # Forward and backward chaining engines
+-- explanation.pl      # Explanation facility with source references
+-- ui.pl               # HTTP server and browser-based interface
+-- runway.png          # Custom background image for the UI
¦
+-- README.md           # This file
+-- USER_MANUAL.md      # Detailed user manual
+-- TEST_CASES.md       # 11 test cases with actual testing results
+-- REPORT.md           # Full project report
+-- REFERENCES.md       # All source references
`

## Note on Corrective Actions
**Corrective actions are displayed only where a source explicitly documents a remedy. The system does not generate or infer corrective actions from the diagnostic rule itself.**

For rules without documented remedies, the system displays: *"No source-backed corrective action was encoded for this rule."*

