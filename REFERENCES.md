# References — Garment Quality Diagnosis Expert System

## Primary Knowledge Sources

All 28 rules in the expert system are formal representations of defect-cause relationships documented in the following published sources.

---

### Source 1: INFLIBNET_HSP08

**Title**: Apparel Quality Analysis — Common Defects in Spreading, Cutting, Bundling, Sewing, Pressing and Finishing, Quality Control in Apparel Production

**Publisher**: INFLIBNET e-PG Pathshala (UGC e-content, Government of India)

**Module**: HSP08 — Textile Manufacturing and Testing

**URL**: https://ebooks.inflibnet.ac.in/hsp08/chapter/apparel-quality-analysis-common-defects-in-spreading-cutting-bundling-sewing-pressing-and-finishing-quality-control-in-apparel-production/

**Rules derived**: R01, R02, R03, R04, R09, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28

**Content used**: The source documents common sewing defects and their causes, including:
- Needle damage (wrong needle type/size, blunt needle, needle heat, feeding difficulty)
- Thread breaks (thread thickness, needle heat, excessive tension)
- Broken stitches (wrong stitch type, tight tension, bad seam joints, sharp feeds, excessive pressure)
- Seam grin (loose tension, large stitches, wrong stitch type)
- Seam pucker (incorrect handling, misaligned notches, tight tension)
- Stitch density problems (excessive or insufficient density)
- Improperly formed stitches (bad tension, incorrect timing, ill-fitting components)

---

### Source 2: INFLIBNET_HSP07

**Title**: Quality Control — Concept, Principles, Standards and Specifications, Quality Assurance, Care Symbols, Standard Symbols

**Publisher**: INFLIBNET e-PG Pathshala (UGC e-content, Government of India)

**Module**: HSP07 — Textile Manufacturing and Testing

**URL**: https://ebooks.inflibnet.ac.in/hsp07/chapter/quality-control-concept-principles-standards-and-specifications-quality-assurance-care-symbols-standard-symbols/

**Content used**: Supporting information on quality control concepts and sewing/seaming defect classification in garment manufacturing.

---

### Source 3: CITS_SEWING

**Title**: Sewing Technology (Trade Practical) — Volume 2

**Publisher**: CITS / Bharat Skills (Directorate General of Training, Government of India)

**URL**: https://bharatskills.gov.in/pdf/E_Books/CITS/431/English/Sewing%20technology%20(Trade%20Practical)%20-%20(Volume%20-%202).pdf

**Rules derived**: R05, R06, R07, R08, R23

**Content used**: The source identifies specific causes and remedies for:
- Skipped stitches (unsuitable thread, defective needle, wrong needle size, poor fabric feed)
- Seam puckering (excessive thread tension — recommends reducing tension)

---

### Source 4: CHOUDHARY_2018

**Title**: The Study of Sewing Damage and Defects in Garments

**Authors**: Choudhary, A.K., Sikka, M., and Bansal, P.

**Journal**: Research Journal of Textile and Apparel

**Year**: 2018

**DOI**: https://doi.org/10.1108/RJTA-08-2017-0041

**Publisher**: Emerald Publishing

**Content used**: Supporting peer-reviewed literature identifying fabric, sewing thread, needle, and machine parameters as factors affecting sewing defects. Used as supporting academic reference for the general framework of sewing defect analysis.

---

## Source-Rule Mapping

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
| R24 | Excessive stitch density → fabric thread rupture | INFLIBNET_HSP08 |
| R25 | Low stitch density → grinning/weak seam | INFLIBNET_HSP08 |
| R26 | Bad tension → improperly formed stitches | INFLIBNET_HSP08 |
| R27 | Incorrect timing → improperly formed stitches | INFLIBNET_HSP08 |
| R28 | Ill-fitting components → improperly formed stitches | INFLIBNET_HSP08 |

---

## Academic Integrity Statement

- No domain expert was consulted. Expert consultation was not mandatory per the assignment guidelines.
- No factory data was claimed or fabricated.
- No expert interview was conducted or claimed.
- All rules are formal representations of documented defect-cause relationships from the published sources listed above.
- Knowledge was acquired exclusively from the listed published apparel quality-control and sewing-technology sources.
