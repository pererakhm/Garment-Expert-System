% ============================================================================
% MAIN APPLICATION - Garment Quality Diagnosis Expert System
% ============================================================================
% Entry point for the expert system. Loads all modules and starts the
% HTTP server on port 8080.
%
% USAGE:
%   swipl app.pl
%
% Then open http://localhost:8080 in your browser.
% ============================================================================

:- use_module(knowledge_base).
:- use_module(rules).
:- use_module(inference).
:- use_module(explanation).
:- use_module(ui).

% ============================================================================
% AUTO-START: When this file is loaded, the server starts automatically.
% ============================================================================

:- initialization(main, main).

main :-
    Port = 3050,
    format('~n'),
    format('  =====================================================~n'),
    format('  GARMENT QUALITY DIAGNOSIS EXPERT SYSTEM~n'),
    format('  =====================================================~n'),
    format('~n'),
    format('  University Expert System Assignment~n'),
    format('  Domain: Garment Manufacturing & Apparel Quality Control~n'),
    format('~n'),
    format('  Knowledge Sources:~n'),
    format('    1. INFLIBNET - Apparel Quality Analysis~n'),
    format('    2. INFLIBNET - Quality Control~n'),
    format('    3. CITS / Bharat Skills - Sewing Technology~n'),
    format('    4. Choudhary et al. (2018) - Sewing Damage~n'),
    format('~n'),
    print_rule_count,
    format('~n'),
    format('  Starting HTTP server on port ~w...~n', [Port]),
    start_server(Port),
    format('~n'),
    format('  Open your browser and go to:~n'),
    format('    http://localhost:~w~n', [Port]),
    format('~n'),
    format('  Press Ctrl+C, then type "e" to exit.~n'),
    format('  =====================================================~n~n'),
    % Keep the server running
    thread_get_message(_).

print_rule_count :-
    all_rule_ids(IDs),
    length(IDs, Count),
    format('  Total Rules in Knowledge Base: ~w~n', [Count]).
