% ============================================================================
% EXPLANATION FACILITY - Garment Quality Diagnosis Expert System
% ============================================================================
% Generates structured explanations for diagnosis results including
% observed facts, triggered rules, source references, and conclusions.
% ============================================================================

:- module(explanation, [
    explain_forward_results/4,
    explain_backward_results/5,
    get_source_url/2
]).

:- use_module(rules).
:- use_module(knowledge_base).

% ============================================================================
% SOURCE URLS
% Maps source IDs to their actual URLs.
% These are real, verifiable URLs.
% ============================================================================

get_source_url('INFLIBNET_HSP08',
    'https://ebooks.inflibnet.ac.in/hsp08/chapter/apparel-quality-analysis-common-defects-in-spreading-cutting-bundling-sewing-pressing-and-finishing-quality-control-in-apparel-production/').
get_source_url('INFLIBNET_HSP07',
    'https://ebooks.inflibnet.ac.in/hsp07/chapter/quality-control-concept-principles-standards-and-specifications-quality-assurance-care-symbols-standard-symbols/').
get_source_url('CITS_SEWING',
    'https://bharatskills.gov.in/pdf/E_Books/CITS/431/English/Sewing%20technology%20(Trade%20Practical)%20-%20(Volume%20-%202).pdf').
get_source_url('INFLIBNET_HSP08_CITS',
    'https://ebooks.inflibnet.ac.in/hsp08/chapter/apparel-quality-analysis-common-defects-in-spreading-cutting-bundling-sewing-pressing-and-finishing-quality-control-in-apparel-production/').
get_source_url('CHOUDHARY_2018',
    'https://doi.org/10.1108/RJTA-08-2017-0041').

% ============================================================================
% EXPLAIN FORWARD CHAINING RESULTS
% Produces a JSON-friendly explanation structure for the UI.
%
% explain_forward_results(+SelectedDefect, +Observations, +Results, -Explanation)
% ============================================================================

explain_forward_results(SelectedDefect, Observations, Results, Explanation) :-
    defect(SelectedDefect, DefectName),
    format_observations(Observations, FormattedObs),
    format_forward_results(Results, FormattedResults),
    length(Results, NumResults),
    Explanation = explanation{
        method: "Forward Chaining",
        method_description: "The system started with user-provided observations and scanned all rules to find those whose conditions are fully satisfied by the observations. All matching rules were fired and their conclusions recorded.",
        defect: DefectName,
        defect_id: SelectedDefect,
        observations: FormattedObs,
        num_rules_fired: NumResults,
        results: FormattedResults
    }.

% ============================================================================
% EXPLAIN BACKWARD CHAINING RESULTS
% ============================================================================

explain_backward_results(Hypothesis, SelectedDefect, Observations, ProofResults, Explanation) :-
    defect(SelectedDefect, DefectName),
    format_observations(Observations, FormattedObs),
    format_backward_results(ProofResults, FormattedProofs),
    length(ProofResults, NumAttempts),
    Explanation = explanation{
        method: "Backward Chaining",
        method_description: "The system started with a hypothesis (possible cause) and searched for rules that conclude that cause for the selected defect. For each rule found, it checked whether the required conditions are present in the user observations.",
        defect: DefectName,
        defect_id: SelectedDefect,
        hypothesis: Hypothesis,
        observations: FormattedObs,
        num_proof_attempts: NumAttempts,
        proof_results: FormattedProofs
    }.

% ============================================================================
% FORMAT OBSERVATIONS
% ============================================================================

format_observations([], []).
format_observations([observation(CondID, Value) | Rest],
                    [obs{condition: CondID, value: Value, label: Label} | FRest]) :-
    (condition(CondID, Value, Label) -> true ; atom_string(Value, Label)),
    format_observations(Rest, FRest).

% ============================================================================
% FORMAT FORWARD RESULTS
% ============================================================================

format_forward_results([], []).
format_forward_results([result(RuleID, Cause, SourceID, SourceName,
                               SourceExplanation, MatchedConditions) | Rest],
                       [Formatted | FRest]) :-
    upcase_atom(RuleID, RuleIDUpper),
    atom_string(Cause, CauseStr),
    (corrective_action(Cause, Action) ->
        CorrectiveAction = Action
    ;
        CorrectiveAction = "No source-backed corrective action was encoded for this rule."
    ),
    (get_source_url(SourceID, URL) -> SourceURL = URL ; SourceURL = ""),
    format_matched(MatchedConditions, FormattedMatched),
    Formatted = forward_result{
        rule_id: RuleIDUpper,
        cause: CauseStr,
        source_id: SourceID,
        source_name: SourceName,
        source_url: SourceURL,
        source_explanation: SourceExplanation,
        corrective_action: CorrectiveAction,
        matched_conditions: FormattedMatched
    },
    format_forward_results(Rest, FRest).

format_matched([], []).
format_matched([matched(CondID, Value, Label) | Rest],
               [mc{condition: CondID, value: Value, label: Label} | FRest]) :-
    format_matched(Rest, FRest).

% ============================================================================
% FORMAT BACKWARD RESULTS
% ============================================================================

format_backward_results([], []).
format_backward_results([proof(RuleID, Hypothesis, Status, SourceID, SourceName,
                               SourceExplanation, SatisfiedConds, MissingConds) | Rest],
                        [Formatted | FRest]) :-
    upcase_atom(RuleID, RuleIDUpper),
    atom_string(Hypothesis, HypStr),
    atom_string(Status, StatusStr),
    (corrective_action(Hypothesis, Action) ->
        CorrectiveAction = Action
    ;
        CorrectiveAction = "No source-backed corrective action was encoded for this rule."
    ),
    (get_source_url(SourceID, URL) -> SourceURL = URL ; SourceURL = ""),
    format_satisfied(SatisfiedConds, FormattedSat),
    format_missing(MissingConds, FormattedMiss),
    Formatted = backward_result{
        rule_id: RuleIDUpper,
        hypothesis: HypStr,
        status: StatusStr,
        source_id: SourceID,
        source_name: SourceName,
        source_url: SourceURL,
        source_explanation: SourceExplanation,
        corrective_action: CorrectiveAction,
        satisfied_conditions: FormattedSat,
        missing_conditions: FormattedMiss
    },
    format_backward_results(Rest, FRest).

format_satisfied([], []).
format_satisfied([satisfied(CondID, Value, Label) | Rest],
                 [sc{condition: CondID, value: Value, label: Label} | FRest]) :-
    format_satisfied(Rest, FRest).

format_missing([], []).
format_missing([missing(CondID, Value, Label) | Rest],
               [mc{condition: CondID, value: Value, label: Label} | FRest]) :-
    format_missing(Rest, FRest).
