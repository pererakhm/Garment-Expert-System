% ============================================================================
% INFERENCE ENGINE - Garment Quality Diagnosis Expert System
% ============================================================================
% Implements both Forward Chaining and Backward Chaining inference methods.
% Each method produces a structured result including the reasoning trace.
% ============================================================================

:- module(inference, [
    forward_chain/3,
    backward_chain/4,
    format_cause/2
]).

:- use_module(rules).
:- use_module(knowledge_base).

% ============================================================================
% FORWARD CHAINING
% ============================================================================
% Algorithm:
%   1. Start with the set of user-provided observations (facts).
%   2. Scan ALL rules in the knowledge base.
%   3. For each rule, check if ALL conditions in the rule's antecedent
%      are satisfied by the user observations.
%   4. If satisfied, the rule fires: record the rule and its conclusion.
%   5. Collect all fired rules and their conclusions.
%   6. Return the complete set of results with reasoning traces.
%
% forward_chain(+Observations, +SelectedDefect, -Results)
%   Observations = list of observation(ConditionID, Value)
%   SelectedDefect = the defect atom selected by the user
%   Results = list of result(RuleID, Cause, SourceID, SourceName,
%                            SourceExplanation, MatchedConditions)
% ============================================================================

forward_chain(Observations, SelectedDefect, Results) :-
    findall(
        result(RuleID, Cause, SourceID, SourceName, SourceExplanation, MatchedConditions),
        (
            rule(RuleID, DefectOrCondition, RequiredConditions, Cause,
                 SourceID, SourceName, SourceExplanation),
            % The rule must match the selected defect
            DefectOrCondition = SelectedDefect,
            % ALL required conditions must be satisfied by observations
            check_all_conditions(RequiredConditions, Observations, MatchedConditions)
        ),
        Results
    ).

% check_all_conditions(+RequiredConditions, +Observations, -MatchedConditions)
% Verifies that every required condition in the rule is present in the
% user's observations. Returns the list of matched conditions for the trace.

check_all_conditions([], _, []).
check_all_conditions([condition(CondID, ReqVal) | Rest], Observations,
                     [matched(CondID, ReqVal, Label) | MatchedRest]) :-
    member(observation(CondID, ReqVal), Observations),
    (condition(CondID, ReqVal, Label) -> true ; Label = ReqVal),
    check_all_conditions(Rest, Observations, MatchedRest).

% ============================================================================
% BACKWARD CHAINING
% ============================================================================
% Algorithm:
%   1. Start with a hypothesis (a possible cause to investigate).
%   2. Find all rules whose conclusion matches the hypothesis.
%   3. For each matching rule, check whether all its required conditions
%      are present in the user observations.
%   4. If all conditions are satisfied, the hypothesis is confirmed.
%   5. If some conditions are not present, record what is missing.
%   6. Return proof results for each matching rule.
%
% backward_chain(+Hypothesis, +Observations, +SelectedDefect, -ProofResults)
%   Hypothesis = the cause atom to try to prove
%   Observations = list of observation(ConditionID, Value)
%   SelectedDefect = the defect atom selected by the user
%   ProofResults = list of proof results
% ============================================================================

backward_chain(Hypothesis, Observations, SelectedDefect, ProofResults) :-
    findall(
        proof(RuleID, Hypothesis, Status, SourceID, SourceName,
              SourceExplanation, SatisfiedConds, MissingConds),
        (
            % Find rules that conclude this hypothesis for the selected defect
            rule(RuleID, DefectOrCondition, RequiredConditions, Hypothesis,
                 SourceID, SourceName, SourceExplanation),
            DefectOrCondition = SelectedDefect,
            % Check each condition
            partition_conditions(RequiredConditions, Observations,
                                SatisfiedConds, MissingConds),
            % Determine proof status
            (MissingConds = [] -> Status = proven ; Status = not_proven)
        ),
        ProofResults
    ).

% partition_conditions(+RequiredConditions, +Observations,
%                      -Satisfied, -Missing)
% Separates required conditions into those satisfied by observations
% and those that are missing.

partition_conditions([], _, [], []).
partition_conditions([condition(CondID, ReqVal) | Rest], Observations,
                     [satisfied(CondID, ReqVal, Label) | SatRest], MissRest) :-
    member(observation(CondID, ReqVal), Observations),
    !,
    (condition(CondID, ReqVal, Label) -> true ; Label = ReqVal),
    partition_conditions(Rest, Observations, SatRest, MissRest).
partition_conditions([condition(CondID, ReqVal) | Rest], Observations,
                     SatRest, [missing(CondID, ReqVal, Label) | MissRest]) :-
    (condition(CondID, ReqVal, Label) -> true ; Label = ReqVal),
    partition_conditions(Rest, Observations, SatRest, MissRest).

% ============================================================================
% UTILITY: Format a cause atom into a human-readable string
% ============================================================================

format_cause(Cause, Formatted) :-
    atom_string(Cause, S),
    split_string(S, "_", "", Parts),
    atomics_to_text_with_spaces(Parts, Formatted).

atomics_to_text_with_spaces([], "").
atomics_to_text_with_spaces([H], Out) :-
    string_upper_first(H, Out).
atomics_to_text_with_spaces([H|T], Out) :-
    T \= [],
    string_upper_first(H, HUp),
    atomics_to_text_with_spaces(T, TOut),
    string_concat(HUp, " ", Tmp),
    string_concat(Tmp, TOut, Out).

string_upper_first(S, Out) :-
    string_chars(S, [First|Rest]),
    upcase_atom(First, Upper),
    atom_chars(Upper, [UC]),
    string_chars(Out, [UC|Rest]).
