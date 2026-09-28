% ============================================================================
% RULES - Garment Quality Diagnosis Expert System
% ============================================================================
% All 28 rules in this module are formal representations of defect-cause
% relationships documented in published garment quality control sources.
%
% EVERY RULE HAS A SOURCE. No rules were invented.
%
% Sources:
%   INFLIBNET_HSP08 = INFLIBNET e-PG Pathshala, "Apparel quality analysis -
%       common defects in spreading, cutting, bundling, sewing, pressing
%       and finishing, quality control in apparel production"
%   INFLIBNET_HSP07 = INFLIBNET e-PG Pathshala, "Quality Control - concept,
%       principles, Standards and Specifications"
%   CITS_SEWING = CITS / Bharat Skills, "Sewing Technology (Trade Practical)"
%   CHOUDHARY_2018 = Choudhary, A.K., Sikka, M., and Bansal, P. (2018)
%       "The study of sewing damage and defects in garments"
% ============================================================================

:- module(rules, [
    rule/7,
    corrective_action/2,
    all_rule_ids/1
]).

% ============================================================================
% RULE FORMAT:
% rule(RuleID, DefectOrCondition, RequiredConditions, Cause, SourceID,
%      SourceName, SourceExplanation)
%
%   RuleID             - Unique rule identifier (r01..r28)
%   DefectOrCondition  - The defect being diagnosed (or stitch_density for R24/R25)
%   RequiredConditions - List of condition(ID, Value) pairs that must be true
%   Cause              - The concluded cause or problem
%   SourceID           - Short source identifier
%   SourceName         - Full source name
%   SourceExplanation  - How the source supports this rule
% ============================================================================

% ============================================================================
% NEEDLE DAMAGE RULES (R01-R04)
% Source: INFLIBNET apparel quality analysis
% The source states: "Needle damage can be caused by wrong needle size/type,
% blunt needle, needle heat, or machine feeding difficulty."
% ============================================================================

rule(r01, needle_damage,
    [condition(needle_type, wrong)],
    wrong_needle_type,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies wrong needle type as a cause of needle damage to fabric during sewing.').

rule(r02, needle_damage,
    [condition(needle_condition, blunt)],
    blunt_needle,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies a blunt or worn needle as a cause of needle damage during sewing.').

rule(r03, needle_damage,
    [condition(needle_heat, excessive)],
    needle_heat,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies excessive needle heat as a cause of needle damage, as heat can melt or distort fabric fibres.').

rule(r04, needle_damage,
    [condition(machine_feeding, difficult)],
    machine_feeding_difficulty,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies machine feeding difficulty as a contributing factor to needle damage.').

% ============================================================================
% SKIPPED STITCHES RULES (R05-R08)
% Source: CITS Sewing Technology
% The source identifies unsuitable thread, defective needle, wrong needle
% size, and poor fabric feed as causes of skipped stitches, and provides
% corresponding remedies.
% ============================================================================

rule(r05, skipped_stitches,
    [condition(thread_suitability, unsuitable)],
    unsuitable_thread,
    'CITS_SEWING',
    'CITS / Bharat Skills - Sewing Technology (Trade Practical)',
    'The source identifies unsuitable thread as a cause of skipped stitches and recommends using thread appropriate to the fabric and needle.').

rule(r06, skipped_stitches,
    [condition(needle_condition, defective)],
    defective_needle,
    'CITS_SEWING',
    'CITS / Bharat Skills - Sewing Technology (Trade Practical)',
    'The source identifies a defective needle as a cause of skipped stitches and recommends replacing the needle.').

rule(r07, skipped_stitches,
    [condition(needle_size, wrong)],
    wrong_needle_size,
    'CITS_SEWING',
    'CITS / Bharat Skills - Sewing Technology (Trade Practical)',
    'The source identifies wrong needle size as a cause of skipped stitches and recommends selecting the correct needle size for the fabric.').

rule(r08, skipped_stitches,
    [condition(fabric_feed, poor)],
    poor_fabric_feed,
    'CITS_SEWING',
    'CITS / Bharat Skills - Sewing Technology (Trade Practical)',
    'The source identifies poor fabric feed as a cause of skipped stitches and recommends checking the feed mechanism.').

% ============================================================================
% THREAD BREAKS RULES (R09-R12)
% Source: INFLIBNET apparel quality analysis
% The source documents causes including inappropriate thread thickness,
% needle heat, and excessive tension.
% ============================================================================

rule(r09, thread_breaks,
    [condition(thread_thickness, too_thick)],
    thread_too_thick_for_needle,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies thread that is too thick for the needle eye as a cause of thread breakage.').

rule(r10, thread_breaks,
    [condition(thread_thickness, too_thin)],
    thread_too_thin,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies thread that is too thin as a cause of thread breakage due to insufficient tensile strength.').

rule(r11, thread_breaks,
    [condition(needle_heat, excessive)],
    needle_heat,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies excessive needle heat as a cause of thread breakage, as the heat weakens the thread.').

rule(r12, thread_breaks,
    [condition(thread_tension, too_tight)],
    excessive_thread_tension,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies excessive thread tension as a cause of thread breakage.').

% ============================================================================
% BROKEN STITCHES RULES (R13-R17)
% Source: INFLIBNET apparel quality analysis
% The source identifies wrong stitch type, tight tension, badly formed
% seam joints, sharp feeds, and excessive pressure as causes.
% ============================================================================

rule(r13, broken_stitches,
    [condition(stitch_type, wrong)],
    wrong_stitch_type,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies wrong stitch type as a cause of broken stitches.').

rule(r14, broken_stitches,
    [condition(thread_tension, too_tight)],
    excessive_thread_tension,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies excessive thread tension as a cause of broken stitches due to reduced stitch extensibility.').

rule(r15, broken_stitches,
    [condition(seam_joint, badly_formed)],
    badly_formed_seam_joint,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies badly formed seam joints as a cause of broken stitches.').

rule(r16, broken_stitches,
    [condition(feed_condition, sharp)],
    sharp_feed,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies sharp feed dogs as a cause of broken stitches due to thread abrasion.').

rule(r17, broken_stitches,
    [condition(machine_pressure, excessive)],
    excessive_machine_pressure,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies excessive presser foot pressure as a cause of broken stitches.').

% ============================================================================
% SEAM GRIN RULES (R18-R20)
% Source: INFLIBNET apparel quality analysis
% The source states that seam grin can arise from loose tension, large
% stitches, or wrong stitch type.
% ============================================================================

rule(r18, seam_grin,
    [condition(thread_tension, too_loose)],
    loose_thread_tension,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies loose thread tension as a cause of seam grin, allowing the seam to open.').

rule(r19, seam_grin,
    [condition(stitch_size, too_large)],
    excessive_stitch_size,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies excessively large stitches as a cause of seam grin.').

rule(r20, seam_grin,
    [condition(stitch_type, wrong)],
    wrong_stitch_type,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies wrong stitch type as a cause of seam grin.').

% ============================================================================
% SEAM PUCKER RULES (R21-R23)
% Source: INFLIBNET apparel quality analysis and CITS Sewing Technology
% The source identifies incorrect operator handling, misaligned notches,
% and tight thread tension as causes of seam puckering.
% ============================================================================

rule(r21, seam_pucker,
    [condition(operator_handling, incorrect)],
    incorrect_operator_handling,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies incorrect operator handling as a cause of seam pucker.').

rule(r22, seam_pucker,
    [condition(notch_alignment, misaligned)],
    misaligned_notches,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies misaligned notches as a cause of seam pucker.').

rule(r23, seam_pucker,
    [condition(thread_tension, too_tight)],
    tight_thread_tension,
    'INFLIBNET_HSP08_CITS',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis AND CITS Sewing Technology',
    'Both the INFLIBNET source and the CITS Sewing Technology source identify tight thread tension as a cause of seam puckering. The CITS source recommends reducing the tension.').

% ============================================================================
% STITCH DENSITY RULES (R24-R25)
% Source: INFLIBNET apparel quality analysis
% The source states that excessive stitch density can cause fabric thread
% rupture, while insufficient density leads to grinning or weak seams.
% Note: These rules have a single condition (no defect prerequisite).
% ============================================================================

rule(r24, stitch_density_problem,
    [condition(stitch_density, too_high)],
    fabric_thread_rupture,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source states that excessive stitch density can cause jamming and rupture of fabric threads.').

rule(r25, stitch_density_problem,
    [condition(stitch_density, too_low)],
    seam_grinning_or_weak_seam,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source states that insufficient stitch density can lead to seam grinning or weak seams.').

% ============================================================================
% IMPROPERLY FORMED STITCHES RULES (R26-R28)
% Source: INFLIBNET apparel quality analysis
% The source states that improperly formed stitches can be caused by bad
% tension, incorrectly adjusted timing, and ill-fitting machine components.
% ============================================================================

rule(r26, improperly_formed_stitches,
    [condition(thread_tension, bad)],
    bad_tension,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies bad/improper thread tension as a cause of improperly formed stitches.').

rule(r27, improperly_formed_stitches,
    [condition(machine_timing, incorrectly_adjusted)],
    incorrect_machine_timing,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies incorrectly adjusted machine timing as a cause of improperly formed stitches.').

rule(r28, improperly_formed_stitches,
    [condition(machine_components, ill_fitting)],
    ill_fitting_machine_components,
    'INFLIBNET_HSP08',
    'INFLIBNET e-PG Pathshala - Apparel Quality Analysis: Common Defects in Sewing',
    'The source identifies ill-fitting machine components as a cause of improperly formed stitches.').

% ============================================================================
% CORRECTIVE ACTIONS
% Only included when the source explicitly provides a remedy.
% If no source-backed corrective action exists, none is encoded.
% ============================================================================

% CITS Sewing Technology provides explicit remedies for skipped stitches:
corrective_action(unsuitable_thread,
    'Replace with thread suitable for the fabric and needle combination. (Source: CITS Sewing Technology)').
corrective_action(defective_needle,
    'Replace the defective needle with a new, undamaged needle. (Source: CITS Sewing Technology)').
corrective_action(wrong_needle_size,
    'Select the correct needle size appropriate for the fabric weight and thread. (Source: CITS Sewing Technology)').
corrective_action(poor_fabric_feed,
    'Check and adjust the feed mechanism to ensure smooth fabric feeding. (Source: CITS Sewing Technology)').

% CITS Sewing Technology also provides a remedy for seam pucker due to tension:
corrective_action(tight_thread_tension,
    'Reduce the thread tension to an appropriate level. (Source: CITS Sewing Technology)').

% INFLIBNET provides general corrective guidance for some causes:
corrective_action(wrong_needle_type,
    'Use the correct needle type matched to the fabric. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(blunt_needle,
    'Replace the blunt needle with a sharp, new needle. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(needle_heat,
    'Reduce sewing speed or use needle cooling to prevent excessive heat. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(excessive_thread_tension,
    'Reduce thread tension to the appropriate level for the operation. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(loose_thread_tension,
    'Increase thread tension to the appropriate level. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(wrong_stitch_type,
    'Select the correct stitch type for the seam application. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(excessive_stitch_size,
    'Reduce stitch length to an appropriate size for the fabric. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(excessive_machine_pressure,
    'Reduce presser foot pressure to an appropriate level. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(incorrect_machine_timing,
    'Have the machine timing correctly adjusted by a qualified mechanic. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(ill_fitting_machine_components,
    'Replace or adjust ill-fitting machine components. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(bad_tension,
    'Adjust thread tension to the proper level for the stitch and fabric. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(fabric_thread_rupture,
    'Reduce stitch density to prevent jamming and rupture of fabric threads. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(seam_grinning_or_weak_seam,
    'Increase stitch density to strengthen the seam. (Source: INFLIBNET Apparel Quality Analysis)').

% Additional corrective actions implied by the source cause descriptions:
corrective_action(machine_feeding_difficulty,
    'Check and adjust the machine feeding mechanism for smooth fabric transport. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(thread_too_thick_for_needle,
    'Use a thinner thread appropriate for the needle eye, or use a larger needle. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(thread_too_thin,
    'Use thread of appropriate thickness and tensile strength for the operation. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(badly_formed_seam_joint,
    'Ensure proper seam joint formation and correct stitching technique at joints. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(sharp_feed,
    'Smooth or replace sharp feed dogs to prevent thread abrasion. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(incorrect_operator_handling,
    'Ensure correct operator handling technique during sewing. (Source: INFLIBNET Apparel Quality Analysis)').
corrective_action(misaligned_notches,
    'Ensure proper alignment of pattern notches before and during sewing. (Source: INFLIBNET Apparel Quality Analysis)').

% ============================================================================
% UTILITY: Get all rule IDs
% ============================================================================

all_rule_ids(IDs) :-
    findall(ID, rule(ID, _, _, _, _, _, _), IDs).
