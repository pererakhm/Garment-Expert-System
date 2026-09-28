% ============================================================================
% KNOWLEDGE BASE - Garment Quality Diagnosis Expert System
% ============================================================================
% This module contains domain facts representing garment sewing defects
% and observable production conditions. All facts correspond to concepts
% documented in the knowledge sources listed in REFERENCES.md.
% ============================================================================

:- module(knowledge_base, [
    defect/2,
    condition/3,
    condition_values/2,
    defect_description/2,
    condition_description/2,
    relevant_condition/2
]).

% ============================================================================
% DEFECT FACTS
% Each defect has an internal ID and a human-readable name.
% These defects are explicitly discussed in the INFLIBNET apparel quality
% analysis source and/or the CITS Sewing Technology source.
% ============================================================================

defect(needle_damage,              'Needle Damage').
defect(skipped_stitches,           'Skipped Stitches').
defect(thread_breaks,              'Thread Breaks').
defect(broken_stitches,            'Broken Stitches').
defect(seam_grin,                  'Seam Grin').
defect(seam_pucker,                'Seam Pucker').
defect(improperly_formed_stitches, 'Improperly Formed Stitches').
defect(stitch_density_problem,     'Stitch Density Problem').

% ============================================================================
% DEFECT DESCRIPTIONS
% Short descriptions of each defect, based on the source material.
% ============================================================================

defect_description(needle_damage,
    'Damage to the fabric caused by the sewing needle during stitching, resulting in holes, cuts, or yarn distortion.').
defect_description(skipped_stitches,
    'Stitches that fail to form properly, leaving gaps in the seam where no stitch is present.').
defect_description(thread_breaks,
    'The sewing thread snaps during stitching, interrupting the seam and requiring re-threading.').
defect_description(broken_stitches,
    'Stitches that break after formation, often during wear or subsequent processing, weakening the seam.').
defect_description(seam_grin,
    'A defect where the seam opens under stress, exposing the stitch line and making the seam visible from the right side.').
defect_description(seam_pucker,
    'Unwanted gathering or wrinkling of fabric along the seam line after stitching.').
defect_description(improperly_formed_stitches,
    'Stitches that are not correctly interlocked or interlooped, resulting in poor seam appearance and reduced strength.').
defect_description(stitch_density_problem,
    'Stitch density (stitches per unit length) that is too high or too low for the fabric and seam requirements.').

% ============================================================================
% CONDITION FACTS
% Each condition represents an observable production parameter.
% condition(ConditionID, Value, HumanLabel)
% ============================================================================

% --- Needle Type ---
condition(needle_type, wrong,         'Wrong needle type for the fabric').
condition(needle_type, correct,       'Correct needle type for the fabric').
condition(needle_type, not_specified, 'Not specified').

% --- Needle Condition ---
condition(needle_condition, blunt,         'Blunt / worn needle').
condition(needle_condition, defective,     'Defective needle').
condition(needle_condition, good,          'Good condition').
condition(needle_condition, not_specified, 'Not specified').

% --- Needle Heat ---
condition(needle_heat, excessive,      'Excessive needle heat').
condition(needle_heat, normal,         'Normal needle temperature').
condition(needle_heat, not_specified,  'Not specified').

% --- Machine Feeding ---
condition(machine_feeding, difficult,      'Difficult machine feeding').
condition(machine_feeding, normal,         'Normal machine feeding').
condition(machine_feeding, not_specified,  'Not specified').

% --- Thread Suitability ---
condition(thread_suitability, unsuitable,     'Unsuitable thread for the operation').
condition(thread_suitability, suitable,       'Suitable thread').
condition(thread_suitability, not_specified,  'Not specified').

% --- Needle Size ---
condition(needle_size, wrong,         'Wrong needle size').
condition(needle_size, correct,       'Correct needle size').
condition(needle_size, not_specified, 'Not specified').

% --- Fabric Feed ---
condition(fabric_feed, poor,          'Poor fabric feed').
condition(fabric_feed, normal,        'Normal fabric feed').
condition(fabric_feed, not_specified, 'Not specified').

% --- Thread Thickness ---
condition(thread_thickness, too_thick,      'Thread too thick for needle eye').
condition(thread_thickness, too_thin,       'Thread too thin').
condition(thread_thickness, appropriate,    'Appropriate thread thickness').
condition(thread_thickness, not_specified,  'Not specified').

% --- Thread Tension ---
condition(thread_tension, too_tight,      'Thread tension too tight').
condition(thread_tension, too_loose,      'Thread tension too loose').
condition(thread_tension, bad,            'Bad / improper tension').
condition(thread_tension, normal,         'Normal thread tension').
condition(thread_tension, not_specified,  'Not specified').

% --- Stitch Type ---
condition(stitch_type, wrong,         'Wrong stitch type for the application').
condition(stitch_type, correct,       'Correct stitch type').
condition(stitch_type, not_specified, 'Not specified').

% --- Seam Joint ---
condition(seam_joint, badly_formed,   'Badly formed seam joint').
condition(seam_joint, well_formed,    'Well formed seam joint').
condition(seam_joint, not_specified,  'Not specified').

% --- Feed Condition ---
condition(feed_condition, sharp,         'Sharp feed dog / feed mechanism').
condition(feed_condition, normal,        'Normal feed condition').
condition(feed_condition, not_specified, 'Not specified').

% --- Machine Pressure ---
condition(machine_pressure, excessive,      'Excessive presser foot pressure').
condition(machine_pressure, normal,         'Normal pressure').
condition(machine_pressure, not_specified,  'Not specified').

% --- Stitch Size ---
condition(stitch_size, too_large,      'Stitch length too large').
condition(stitch_size, appropriate,    'Appropriate stitch size').
condition(stitch_size, not_specified,  'Not specified').

% --- Operator Handling ---
condition(operator_handling, incorrect,      'Incorrect operator handling').
condition(operator_handling, correct,        'Correct operator handling').
condition(operator_handling, not_specified,  'Not specified').

% --- Notch Alignment ---
condition(notch_alignment, misaligned,     'Misaligned notches').
condition(notch_alignment, aligned,        'Properly aligned notches').
condition(notch_alignment, not_specified,  'Not specified').

% --- Stitch Density ---
condition(stitch_density, too_high,       'Stitch density too high').
condition(stitch_density, too_low,        'Stitch density too low').
condition(stitch_density, appropriate,    'Appropriate stitch density').
condition(stitch_density, not_specified,  'Not specified').

% --- Machine Timing ---
condition(machine_timing, incorrectly_adjusted, 'Incorrectly adjusted machine timing').
condition(machine_timing, correct,              'Correct machine timing').
condition(machine_timing, not_specified,         'Not specified').

% --- Machine Components ---
condition(machine_components, ill_fitting,    'Ill-fitting machine components').
condition(machine_components, well_fitting,   'Well-fitting machine components').
condition(machine_components, not_specified,  'Not specified').

% ============================================================================
% CONDITION VALUES - list of valid values for each condition
% ============================================================================

condition_values(ConditionID, Values) :-
    findall(V, condition(ConditionID, V, _), Values).

% ============================================================================
% CONDITION DESCRIPTIONS
% ============================================================================

condition_description(needle_type,        'The type of sewing needle used relative to the fabric being sewn.').
condition_description(needle_condition,   'The physical condition of the sewing needle.').
condition_description(needle_heat,        'Whether the needle is generating excessive heat during operation.').
condition_description(machine_feeding,    'Whether the machine is feeding fabric smoothly.').
condition_description(thread_suitability, 'Whether the thread is suitable for the sewing operation.').
condition_description(needle_size,        'Whether the needle size is appropriate for the fabric and thread.').
condition_description(fabric_feed,        'The quality of fabric feeding through the machine.').
condition_description(thread_thickness,   'The thickness of the sewing thread relative to the needle.').
condition_description(thread_tension,     'The tension applied to the sewing thread.').
condition_description(stitch_type,        'Whether the correct stitch type is being used for the application.').
condition_description(seam_joint,         'The formation quality of the seam joint.').
condition_description(feed_condition,     'The condition of the feed dog or feed mechanism.').
condition_description(machine_pressure,   'The pressure applied by the presser foot.').
condition_description(stitch_size,        'The length/size of the stitches being formed.').
condition_description(operator_handling,  'The skill and technique of the sewing machine operator.').
condition_description(notch_alignment,    'Whether pattern notches are properly aligned during sewing.').
condition_description(stitch_density,     'The number of stitches per unit length of seam.').
condition_description(machine_timing,     'The timing adjustment of the sewing machine mechanism.').
condition_description(machine_components, 'Whether the machine components fit properly.').

% ============================================================================
% RELEVANT CONDITIONS PER DEFECT
% Maps each defect to the conditions that are meaningful for diagnosing it.
% This prevents the UI from forcing irrelevant inputs.
% ============================================================================

relevant_condition(needle_damage, needle_type).
relevant_condition(needle_damage, needle_condition).
relevant_condition(needle_damage, needle_heat).
relevant_condition(needle_damage, machine_feeding).

relevant_condition(skipped_stitches, thread_suitability).
relevant_condition(skipped_stitches, needle_condition).
relevant_condition(skipped_stitches, needle_size).
relevant_condition(skipped_stitches, fabric_feed).

relevant_condition(thread_breaks, thread_thickness).
relevant_condition(thread_breaks, needle_heat).
relevant_condition(thread_breaks, thread_tension).

relevant_condition(broken_stitches, stitch_type).
relevant_condition(broken_stitches, thread_tension).
relevant_condition(broken_stitches, seam_joint).
relevant_condition(broken_stitches, feed_condition).
relevant_condition(broken_stitches, machine_pressure).

relevant_condition(seam_grin, thread_tension).
relevant_condition(seam_grin, stitch_size).
relevant_condition(seam_grin, stitch_type).

relevant_condition(seam_pucker, operator_handling).
relevant_condition(seam_pucker, notch_alignment).
relevant_condition(seam_pucker, thread_tension).

relevant_condition(improperly_formed_stitches, thread_tension).
relevant_condition(improperly_formed_stitches, machine_timing).
relevant_condition(improperly_formed_stitches, machine_components).

relevant_condition(stitch_density_problem, stitch_density).
