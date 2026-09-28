# User Manual — Garment Quality Diagnosis Expert System

## 1. Overview

The Garment Quality Diagnosis Expert System is a browser-based application that diagnoses common garment sewing and quality defects. It uses 28 source-backed rules derived from published apparel quality-control references.

The system supports two inference methods:
- **Forward Chaining** (data-driven): Start with observations → find matching causes
- **Backward Chaining** (goal-driven): Start with a hypothesis → verify conditions

## 2. System Requirements

- **Operating System**: Windows 10/11
- **SWI-Prolog**: Version 8.0 or later
- **Web Browser**: Any modern browser (Chrome, Firefox, Edge)

## 3. Installation

### 3.1 Install SWI-Prolog

1. Go to https://www.swi-prolog.org/download/stable
2. Download the Windows 64-bit installer
3. Run the installer
4. During installation, ensure **"Add swipl to the system PATH"** is checked
5. Complete the installation
6. Restart any open terminal windows

### 3.2 Verify Installation

Open PowerShell or Command Prompt and type:

```
swipl --version
```

If you see a version number (e.g., `SWI-Prolog version 9.x.x`), the installation is successful.

## 4. Starting the System

### 4.1 Open Terminal

Open **PowerShell** or **Command Prompt**.

### 4.2 Clone and Navigate to Project Directory

First, clone the repository from GitHub:
```
git clone https://github.com/pererakhm/Garment-Expert-System.git
```

Then, navigate into the directory:
```
cd Garment-Expert-System
```

### 4.3 Start the Server

```
swipl app.pl
```

*(If you get an error saying 'swipl' is not recognized, run this instead:)*
```
& "C:\Program Files\swipl\bin\swipl.exe" app.pl
```

### 4.4 Open the Interface

Open your web browser and go to:

```
http://localhost:3050
```

## 5. Using the System

### 5.1 Forward Chaining (Recommended for beginners)

Forward chaining starts with your observations and automatically finds all matching causes.

**Steps:**

1. **Select Inference Method**: Click "Forward Chaining"
2. **Select Defect**: Choose the defect you have observed (e.g., "Needle Damage")
3. **Set Conditions**: The system will show only the relevant conditions for the selected defect. Set the conditions you have observed. Leave any unknown conditions as "Not specified".
4. **Run Diagnosis**: Click the "Run Diagnosis" button
5. **View Results**: The system will show:
   - All rules that fired
   - The possible cause for each rule
   - The source document for each rule
   - Corrective action (if documented in the source)
   - A full reasoning trace

### 5.2 Backward Chaining

Backward chaining starts with a hypothesis (suspected cause) and checks whether the observations support it.

**Steps:**

1. **Select Inference Method**: Click "Backward Chaining"
2. **Select Defect**: Choose the defect
3. **Select Hypothesis**: A dropdown will appear showing all possible causes for that defect, along with the rule ID and source. Select the cause you want to investigate.
4. **Set Conditions**: Set the conditions you have observed
5. **Run Diagnosis**: Click the "Run Diagnosis" button
6. **View Results**: The system will show:
   - Whether the hypothesis was **proven** or **not proven**
   - Which conditions were satisfied
   - Which conditions were missing
   - The source reference
   - The full backward chaining proof trace

### 5.3 Viewing All Rules

At the bottom of the page, click **"View All Rules & Sources"** to see a table of all 28 rules with their conditions, conclusions, and source references.

## 6. Understanding the Results

### 6.1 Result Components

Each diagnosis result shows:

| Component | Description |
|-----------|-------------|
| Rule ID | The unique identifier of the triggered rule (e.g., R02) |
| Possible Cause | The diagnosed cause from the knowledge base |
| Source Tag | The source document that documents this rule |
| Source Explanation | How the source supports this specific rule |
| Corrective Action | Remedy from the source, if documented |
| Reasoning Trace | Step-by-step explanation of the inference process |

### 6.2 Corrective Actions

- **Green box**: A source-backed corrective action is available
- **Yellow box**: "No source-backed corrective action was encoded for this rule" — the system does not invent corrective actions

### 6.3 Backward Chaining Status

- **PROVEN** (green): All required conditions are present in your observations
- **NOT PROVEN** (red): Some required conditions are missing from your observations

## 7. Example Diagnoses

### Example 1: Needle Damage (Forward Chaining)

1. Method: Forward Chaining
2. Defect: Needle Damage
3. Conditions: Needle Condition = Blunt
4. Result: Rule R02 fires → Cause = Blunt Needle
5. Source: INFLIBNET Apparel Quality Analysis
6. Corrective Action: Replace the blunt needle with a sharp, new needle

### Example 2: Seam Pucker (Backward Chaining)

1. Method: Backward Chaining
2. Defect: Seam Pucker
3. Hypothesis: tight_thread_tension
4. Conditions: Thread Tension = Too Tight
5. Result: Rule R23 → PROVEN
6. Source: INFLIBNET AND CITS Sewing Technology
7. Corrective Action: Reduce the thread tension

## 8. Stopping the System

**To stop the system:** Press `Ctrl+C` in the terminal running the server. If SWI-Prolog enters its interrupt prompt, follow the prompt to exit.

## 9. Troubleshooting

| Problem | Solution |
|---------|----------|
| `swipl` is not recognized | Reinstall SWI-Prolog with PATH option checked, restart terminal |
| Port 3050 already in use | Close any other application using port 3050, or modify the port in `app.pl` |
| Page does not load | Ensure the server is running and check the terminal for error messages |
| No rules fire | Check that you have set at least one condition beyond "Not specified" |
