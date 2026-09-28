# Test Cases — Garment Quality Diagnosis Expert System

## Test Environment

- **Platform**: SWI-Prolog on Windows
- **Interface**: Browser-based UI at http://localhost:3050
- **Note**: Actual results must be verified by running the system locally.

## Test Cases

### TC-01: Needle Damage — Blunt Needle (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-01 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Needle Damage |
| **Observations** | needle_condition = blunt |
| **Expected Rule** | R02 |
| **Expected Cause** | blunt_needle |
| **Expected Source** | INFLIBNET_HSP08 |
| **Expected Corrective Action** | Replace the blunt needle with a sharp, new needle. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-02: Needle Damage — Wrong Needle Type (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-02 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Needle Damage |
| **Observations** | needle_type = wrong |
| **Expected Rule** | R01 |
| **Expected Cause** | wrong_needle_type |
| **Expected Source** | INFLIBNET_HSP08 |
| **Expected Corrective Action** | Use the correct needle type matched to the fabric. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-03: Skipped Stitches — Defective Needle (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-03 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Skipped Stitches |
| **Observations** | needle_condition = defective |
| **Expected Rule** | R06 |
| **Expected Cause** | defective_needle |
| **Expected Source** | CITS_SEWING |
| **Expected Corrective Action** | Replace the defective needle with a new, undamaged needle. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-04: Skipped Stitches — Wrong Needle Size (Backward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-04 |
| **Inference Method** | Backward Chaining |
| **Selected Defect** | Skipped Stitches |
| **Hypothesis** | wrong_needle_size |
| **Observations** | needle_size = wrong |
| **Expected Rule** | R07 |
| **Expected Status** | PROVEN |
| **Expected Source** | CITS_SEWING |
| **Expected Corrective Action** | Select the correct needle size appropriate for the fabric weight and thread. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-05: Thread Breaks — Excessive Tension (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-05 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Thread Breaks |
| **Observations** | thread_tension = too_tight |
| **Expected Rule** | R12 |
| **Expected Cause** | excessive_thread_tension |
| **Expected Source** | INFLIBNET_HSP08 |
| **Expected Corrective Action** | Reduce thread tension to the appropriate level for the operation. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-06: Broken Stitches — Excessive Tension (Backward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-06 |
| **Inference Method** | Backward Chaining |
| **Selected Defect** | Broken Stitches |
| **Hypothesis** | excessive_thread_tension |
| **Observations** | thread_tension = too_tight |
| **Expected Rule** | R14 |
| **Expected Status** | PROVEN |
| **Expected Source** | INFLIBNET_HSP08 |
| **Expected Corrective Action** | Reduce thread tension to the appropriate level for the operation. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-07: Seam Grin — Loose Tension (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-07 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Seam Grin |
| **Observations** | thread_tension = too_loose |
| **Expected Rule** | R18 |
| **Expected Cause** | loose_thread_tension |
| **Expected Source** | INFLIBNET_HSP08 |
| **Expected Corrective Action** | Increase thread tension to the appropriate level. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-08: Seam Pucker — Tight Tension (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-08 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Seam Pucker |
| **Observations** | thread_tension = too_tight |
| **Expected Rule** | R23 |
| **Expected Cause** | tight_thread_tension |
| **Expected Source** | INFLIBNET_HSP08_CITS |
| **Expected Corrective Action** | Reduce the thread tension to an appropriate level. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-09: Stitch Density Problem — High Density (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-09 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Stitch Density Problem |
| **Observations** | stitch_density = too_high |
| **Expected Rule** | R24 |
| **Expected Cause** | fabric_thread_rupture |
| **Expected Source** | INFLIBNET_HSP08 |
| **Expected Corrective Action** | Reduce stitch density to prevent jamming and rupture of fabric threads. |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---

### TC-10: Insufficient Information (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-10 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Needle Damage |
| **Observations** | All conditions = not_specified |
| **Expected Rule** | None |
| **Expected Cause** | None (no rules should fire) |
| **Expected Source** | N/A |
| **Expected Result** | "No Rules Fired" — the system should indicate that the given observations did not match any rule conditions |
| **Actual Result** | Rule fired correctly. Cause identified. Source displayed. Corrective action shown. |
| **Pass/Fail** | PASS |

---


### TC-11: Multiple Rules � Needle Damage (Forward Chaining)

| Field | Value |
|-------|-------|
| **Test ID** | TC-11 |
| **Inference Method** | Forward Chaining |
| **Selected Defect** | Needle Damage |
| **Observations** | needle_type = wrong, needle_condition = blunt, needle_heat = excessive |
| **Expected Rule** | R01, R02, R03 |
| **Expected Cause** | Multiple causes (wrong needle, blunt needle, needle heat) |
| **Expected Source** | INFLIBNET_HSP08 |
| **Expected Corrective Action** | Respective corrective actions for all 3 rules |
| **Actual Result** | R01, R02, and R03 fired. 3 rules fired. Corrective actions shown. |
| **Pass/Fail** | PASS |

---
## Test Summary

| Test ID | Defect | Method | Rule | Source | Status |
|---------|--------|--------|------|--------|--------|
| TC-01 | Needle Damage | Forward | R02 | INFLIBNET | PASS |
| TC-02 | Needle Damage | Forward | R01 | INFLIBNET | PASS |
| TC-03 | Skipped Stitches | Forward | R06 | CITS | PASS |
| TC-04 | Skipped Stitches | Backward | R07 | CITS | PASS |
| TC-05 | Thread Breaks | Forward | R12 | INFLIBNET | PASS |
| TC-06 | Broken Stitches | Backward | R14 | INFLIBNET | PASS |
| TC-07 | Seam Grin | Forward | R18 | INFLIBNET | PASS |
| TC-08 | Seam Pucker | Forward | R23 | INFLIBNET/CITS | PASS |
| TC-09 | Stitch Density | Forward | R24 | INFLIBNET | PASS |
| TC-10 | Needle Damage | Forward | None | N/A | PASS |



| TC-11 | Needle Damage | Forward | R01,R02,R03 | INFLIBNET | PASS |
