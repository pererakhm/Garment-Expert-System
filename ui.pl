% ============================================================================
% USER INTERFACE - Garment Quality Diagnosis Expert System
% ============================================================================
% HTTP-based web interface using SWI-Prolog's built-in HTTP server.
% Provides a professional browser-based UI for interacting with the
% expert system.
% ============================================================================

:- module(ui, [
    start_server/1,
    stop_server/0
]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(json)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_files)).

:- use_module(knowledge_base).
:- use_module(rules).
:- use_module(inference).
:- use_module(explanation).

% ============================================================================
% HTTP ROUTE HANDLERS
% ============================================================================

:- http_handler(root(.),        handle_home,      []).
:- http_handler(root(diagnose), handle_diagnose,  []).
:- http_handler(root(api/defects),    handle_api_defects,    []).
:- http_handler(root(api/conditions), handle_api_conditions, []).
:- http_handler(root(api/causes),     handle_api_causes,     []).
:- http_handler(root(api/rules),      handle_api_rules,      []).
:- http_handler(root('bg.png'),       serve_bg_image,        []).

% ============================================================================
% SERVER START/STOP
% ============================================================================

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('~n========================================~n'),
    format('  Garment Quality Diagnosis Expert System~n'),
    format('  Server running at http://localhost:~w~n', [Port]),
    format('  Press Ctrl+C to stop~n'),
    format('========================================~n~n').

stop_server :-
    http_stop_server(3050, []).

% ============================================================================
% HOME PAGE HANDLER
% ============================================================================

handle_home(_Request) :-
    format('Content-type: text/html; charset=utf-8~n~n'),
    generate_html_page.

% Serve the background image
serve_bg_image(Request) :-
    http_reply_file('d:/ExpertSystem/garment-expert-system/runway.png', [mime_type(image/png), unsafe(true)], Request).

% ============================================================================
% DIAGNOSE HANDLER (POST)
% ============================================================================

handle_diagnose(Request) :-
    http_read_json_dict(Request, Input),
    process_diagnosis(Input, ResponseDict),
    reply_json_dict(ResponseDict).

process_diagnosis(Input, Response) :-
    atom_string(Method, Input.method),
    atom_string(SelectedDefect, Input.defect),
    extract_observations(Input.observations, Observations),
    (Method = forward ->
        run_forward(SelectedDefect, Observations, Response)
    ; Method = backward ->
        atom_string(Hypothesis, Input.hypothesis),
        run_backward(Hypothesis, SelectedDefect, Observations, Response)
    ;
        Response = error{message: "Invalid inference method. Use 'forward' or 'backward'."}
    ).

run_forward(SelectedDefect, Observations, Response) :-
    forward_chain(Observations, SelectedDefect, Results),
    explain_forward_results(SelectedDefect, Observations, Results, Explanation),
    Response = Explanation.

run_backward(Hypothesis, SelectedDefect, Observations, Response) :-
    backward_chain(Hypothesis, Observations, SelectedDefect, ProofResults),
    explain_backward_results(Hypothesis, SelectedDefect, Observations, ProofResults, Explanation),
    Response = Explanation.

extract_observations(ObsList, Observations) :-
    is_list(ObsList),
    !,
    maplist(convert_observation, ObsList, Observations).
extract_observations(_, []).

convert_observation(Obs, observation(CondID, Value)) :-
    atom_string(CondID, Obs.condition),
    atom_string(Value, Obs.value).

% ============================================================================
% API: GET DEFECTS
% ============================================================================

handle_api_defects(_Request) :-
    findall(
        defect_info{id: ID, name: Name, description: Desc},
        (defect(ID, Name), defect_description(ID, Desc)),
        Defects
    ),
    reply_json_dict(defects{defects: Defects}).

% ============================================================================
% API: GET CONDITIONS FOR A DEFECT
% ============================================================================

handle_api_conditions(Request) :-
    http_parameters(Request, [defect(DefectStr, [])]),
    atom_string(DefectAtom, DefectStr),
    findall(
        cond_info{
            id: CondID,
            description: CondDesc,
            values: FormattedValues
        },
        (
            relevant_condition(DefectAtom, CondID),
            condition_description(CondID, CondDesc),
            findall(
                val_info{value: V, label: L},
                condition(CondID, V, L),
                FormattedValues
            )
        ),
        Conditions
    ),
    reply_json_dict(conditions{conditions: Conditions}).

% ============================================================================
% API: GET POSSIBLE CAUSES FOR A DEFECT (for backward chaining)
% ============================================================================

handle_api_causes(Request) :-
    http_parameters(Request, [defect(DefectStr, [])]),
    atom_string(DefectAtom, DefectStr),
    findall(
        cause_info{cause: Cause, rule_id: RuleIDUpper, source: SourceID},
        (
            rule(RuleID, DefectAtom, _, Cause, SourceID, _, _),
            upcase_atom(RuleID, RuleIDUpper)
        ),
        Causes
    ),
    sort(cause, @<, Causes, UniqueCauses),
    reply_json_dict(causes{causes: UniqueCauses}).

% ============================================================================
% API: GET ALL RULES
% ============================================================================

handle_api_rules(_Request) :-
    findall(
        rule_info{
            rule_id: RuleIDUpper,
            defect: DefectName,
            conditions: CondStrs,
            cause: Cause,
            source_id: SourceID,
            source_name: SourceName,
            source_explanation: SourceExplanation,
            source_url: SourceURL
        },
        (
            rule(RuleID, DefectOrCond, RequiredConditions, Cause,
                 SourceID, SourceName, SourceExplanation),
            upcase_atom(RuleID, RuleIDUpper),
            (defect(DefectOrCond, DefectName) -> true ; atom_string(DefectOrCond, DefectName)),
            maplist(format_condition_str, RequiredConditions, CondStrs),
            (get_source_url(SourceID, URL) -> SourceURL = URL ; SourceURL = "")
        ),
        Rules
    ),
    length(Rules, Total),
    reply_json_dict(rules{rules: Rules, total: Total}).

format_condition_str(condition(CondID, Value), Str) :-
    atom_string(CondID, CStr),
    atom_string(Value, VStr),
    string_concat(CStr, " = ", Tmp),
    string_concat(Tmp, VStr, Str).

% ============================================================================
% HTML PAGE GENERATION
% ============================================================================

generate_html_page :-
    write('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Garment Quality Diagnosis Expert System - Diagnoses common garment sewing defects using source-backed rules and dual inference methods.">
    <title>Garment Quality Diagnosis Expert System</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --bg-card: rgba(28, 20, 12, 0.75);
            --bg-card-hover: rgba(35, 25, 15, 0.85);
            --bg-input: rgba(255, 235, 200, 0.1);
            --border-color: rgba(210, 170, 110, 0.25);
            --border-active: #d4a056;
            --text-primary: #fef3e2;
            --text-secondary: #e8d5b8;
            --text-muted: #b8a080;
            --accent-primary: #d4a056;
            --accent-secondary: #e8b86d;
            --accent-glow: rgba(212, 160, 86, 0.3);
            --success: #6ee7a0;
            --success-bg: rgba(110, 231, 160, 0.12);
            --warning: #fbbf24;
            --warning-bg: rgba(251, 191, 36, 0.12);
            --error: #fca5a5;
            --error-bg: rgba(252, 165, 165, 0.12);
            --info: #93c5fd;
            --info-bg: rgba(147, 197, 253, 0.12);
            --source-tag: #e8b86d;
            --source-tag-bg: rgba(232, 184, 109, 0.15);
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 20px;
            --shadow-md: 0 8px 24px rgba(0, 0, 0, 0.3);
            --shadow-lg: 0 16px 48px rgba(0, 0, 0, 0.4);
            --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            --font-sans: "Inter", -apple-system, sans-serif;
        }

        body {
            font-family: var(--font-sans);
            background: #0d0907;
            color: var(--text-primary);
            line-height: 1.6;
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
            position: relative;
        }

        body::before {
            content: "";
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background-image: url("/bg.png"); /* Serves the local custom runway image */
            background-size: cover;
            background-position: center;
            opacity: 0.15;
            z-index: -1;
            pointer-events: none;
        }

        .app-container {
            position: relative;
            z-index: 1;
            max-width: 1100px;
            margin: 0 auto;
            padding: 24px 20px 60px;
        }

        /* HEADER */
        .header {
            text-align: center;
            padding: 60px 20px 50px;
            margin-bottom: 36px;
        }

        .header-icon {
            width: 72px; height: 72px;
            background: linear-gradient(135deg, var(--accent-primary), #c07830);
            border-radius: 22px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #1a0f00;
            margin-bottom: 24px;
            box-shadow: 0 12px 32px var(--accent-glow);
            transform: rotate(-3deg);
        }

        .header-icon svg {
            stroke: #1a0f00;
        }

        .header h1 {
            font-family: var(--font-sans);
            font-size: 44px;
            font-weight: 800;
            letter-spacing: -1px;
            color: #ffffff;
            margin-bottom: 14px;
            text-shadow: 0 2px 20px rgba(0,0,0,0.3);
        }

        .header p {
            color: var(--text-secondary);
            font-size: 17px;
            max-width: 600px;
            margin: 0 auto;
            line-height: 1.7;
            font-weight: 400;
            text-shadow: 0 1px 8px rgba(0,0,0,0.2);
        }

        /* CARDS */
        .card {
            background: var(--bg-card);
            backdrop-filter: blur(24px) saturate(140%);
            -webkit-backdrop-filter: blur(24px) saturate(140%);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: var(--shadow-lg);
            transition: background var(--transition);
        }

        .card:hover {
            background: var(--bg-card-hover);
        }

        .card-title {
            font-family: var(--font-sans);
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 6px;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .card-title .step-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 30px; height: 30px;
            background: linear-gradient(135deg, var(--accent-primary), #c07830);
            color: #1a0f00;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 800;
            flex-shrink: 0;
        }

        .card-subtitle {
            color: var(--text-muted);
            font-size: 14px;
            margin-bottom: 24px;
            margin-left: 42px;
        }

        /* FORM ELEMENTS */
        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        select, input[type="text"] {
            width: 100%;
            padding: 14px 16px;
            background: var(--bg-input);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            color: var(--text-primary);
            font-family: var(--font-sans);
            font-size: 15px;
            font-weight: 500;
            transition: all var(--transition);
            appearance: none;
            -webkit-appearance: none;
            cursor: pointer;
        }

        select {
            background-image: url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'12\' height=\'12\' viewBox=\'0 0 12 12\'%3E%3Cpath d=\'M2 4l4 4 4-4\' stroke=\'%2394a3b8\' stroke-width=\'2\' fill=\'none\' stroke-linecap=\'round\'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 16px center;
            padding-right: 40px;
        }

        select:focus, input[type="text"]:focus {
            outline: none;
            background: rgba(255, 255, 255, 0.12);
            border-color: var(--accent-primary);
            box-shadow: 0 0 0 3px var(--accent-glow);
        }

        select option {
            background: #1e1610;
            color: #fef3e2;
            padding: 10px;
        }

        /* RADIO BUTTONS */
        .radio-group {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }

        .radio-option {
            flex: 1;
            min-width: 200px;
        }

        .radio-option input[type="radio"] {
            display: none;
        }

        .radio-option label {
            display: block;
            padding: 20px;
            background: var(--bg-input);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all var(--transition);
            text-align: center;
        }

        .radio-option label:hover {
            background: rgba(255, 255, 255, 0.12);
            border-color: rgba(255, 255, 255, 0.2);
        }

        .radio-option label .radio-title {
            font-family: var(--font-sans);
            font-size: 16px;
            font-weight: 700;
            display: block;
            margin-bottom: 4px;
            color: var(--text-primary);
        }

        .radio-option label .radio-desc {
            font-size: 13px;
            color: var(--text-muted);
        }

        .radio-option input[type="radio"]:checked + label {
            border-color: var(--accent-primary);
            background: rgba(212, 160, 86, 0.12);
            box-shadow: 0 0 20px rgba(212, 160, 86, 0.15);
            transform: translateY(-2px);
        }

        .radio-option input[type="radio"]:checked + label .radio-title {
            color: var(--accent-primary);
        }

        /* CONDITIONS GRID */
        .conditions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 14px;
        }

        .condition-item {
            background: rgba(255, 255, 255, 0.05);
            padding: 16px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            transition: all var(--transition);
        }

        .condition-item:hover {
            border-color: var(--accent-primary);
            background: rgba(255, 255, 255, 0.08);
        }

        .condition-item .cond-label {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .condition-item select {
            background: var(--bg-input);
        }

        /* HYPOTHESIS SELECT */
        #hypothesis-section {
            display: none;
            margin-top: 24px;
            padding: 24px;
            background: var(--info-bg);
            border: 1px solid rgba(96,165,250,0.2);
            border-radius: var(--radius-md);
        }

        /* BUTTONS */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 14px 28px;
            border: none;
            border-radius: var(--radius-md);
            font-family: var(--font-sans);
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-primary), #c07830);
            color: #1a0f00;
            font-weight: 700;
            box-shadow: 0 6px 20px var(--accent-glow);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px var(--accent-glow);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        .btn-primary:disabled {
            opacity: 0.4;
            cursor: not-allowed;
            transform: none;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.08);
            color: var(--text-primary);
            border: 1px solid var(--border-color);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.15);
        }

        .btn-group {
            display: flex;
            gap: 16px;
            justify-content: center;
            margin-top: 32px;
        }

        /* LOADING */
        .spinner {
            display: inline-block;
            width: 18px; height: 18px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        /* RESULTS */
        #results-section {
            display: none;
        }

        .result-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .result-header .result-icon {
            width: 56px; height: 56px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
        }

        .result-header .result-icon.success { background: var(--success-bg); color: var(--success); }
        .result-header .result-icon.warning { background: var(--warning-bg); color: var(--warning); }

        .result-header .result-title {
            font-size: 20px;
            font-weight: 800;
            color: var(--text-primary);
        }

        .result-header .result-subtitle {
            font-size: 14px;
            color: var(--text-secondary);
            margin-top: 4px;
        }

        .result-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 24px;
            margin-bottom: 24px;
            position: relative;
            overflow: hidden;
        }

        .result-card::before {
            content: "";
            position: absolute;
            top: 0; left: 0; bottom: 0; width: 4px;
            background: linear-gradient(to bottom, var(--accent-primary), #c07830);
        }

        .result-card .rule-badge {
            display: inline-block;
            padding: 3px 10px;
            background: var(--accent-glow);
            color: var(--accent-secondary);
            border-radius: var(--radius-sm);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.5px;
            margin-right: 8px;
        }

        .result-card .cause-text {
            font-size: 16px;
            font-weight: 600;
            margin: 10px 0;
        }

        .result-card .source-tag {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            background: var(--source-tag-bg);
            color: var(--source-tag);
            border-radius: var(--radius-sm);
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.3px;
            text-decoration: none;
            transition: background var(--transition);
        }

        .result-card .source-tag:hover {
            background: rgba(167, 139, 250, 0.2);
        }

        .result-detail {
            margin-top: 12px;
            padding-top: 12px;
            border-top: 1px solid var(--border-color);
        }

        .result-detail .detail-label {
            font-size: 11px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }

        .result-detail .detail-value {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
        }

        .corrective-action {
            margin-top: 12px;
            padding: 12px 14px;
            background: var(--success-bg);
            border: 1px solid rgba(16, 185, 129, 0.2);
            border-radius: var(--radius-sm);
        }

        .corrective-action .detail-label { color: var(--success); }
        .corrective-action .detail-value { color: var(--text-primary); }

        .no-corrective {
            background: var(--warning-bg);
            border-color: rgba(245,158,11,0.2);
        }
        .no-corrective .detail-label { color: var(--warning); }

        .proof-status {
            display: inline-block;
            padding: 3px 10px;
            border-radius: var(--radius-sm);
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .proof-status.proven {
            background: var(--success-bg);
            color: var(--success);
        }

        .proof-status.not_proven {
            background: var(--error-bg);
            color: var(--error);
        }

        .matched-conditions {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 8px;
        }

        .matched-cond-tag {
            padding: 3px 8px;
            background: rgba(99,102,241,0.1);
            border: 1px solid rgba(99,102,241,0.2);
            border-radius: var(--radius-sm);
            font-size: 11px;
            color: var(--accent-secondary);
        }

        .missing-cond-tag {
            padding: 3px 8px;
            background: var(--error-bg);
            border: 1px solid rgba(239,68,68,0.2);
            border-radius: var(--radius-sm);
            font-size: 11px;
            color: var(--error);
        }

        /* REASONING TRACE */
        .trace-section {
            margin-top: 24px;
        }

        .trace-title {
            font-size: 15px;
            font-weight: 700;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .trace-box {
            background: var(--bg-input);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 20px;
            font-family: "Courier New", monospace;
            font-size: 13px;
            line-height: 1.8;
            color: var(--text-secondary);
            white-space: pre-wrap;
            overflow-x: auto;
        }

        .trace-box .trace-step {
            color: var(--accent-secondary);
            font-weight: 700;
        }

        .trace-box .trace-rule {
            color: var(--warning);
        }

        .trace-box .trace-source {
            color: var(--source-tag);
        }

        .trace-box .trace-conclusion {
            color: var(--success);
            font-weight: 700;
        }

        /* RULES TABLE VIEW */
        .rules-toggle {
            margin-top: 20px;
            text-align: center;
        }

        .rules-table-container {
            display: none;
            margin-top: 16px;
            overflow-x: auto;
        }

        .rules-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .rules-table th {
            text-align: left;
            padding: 10px 14px;
            background: var(--bg-secondary);
            color: var(--text-secondary);
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid var(--border-color);
        }

        .rules-table td {
            padding: 10px 14px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-primary);
            vertical-align: top;
        }

        .rules-table tr:hover td {
            background: var(--bg-card-hover);
        }

        /* NO RESULTS */
        .no-results {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-muted);
        }

        .no-results .no-results-icon {
            font-size: 48px;
            margin-bottom: 12px;
        }

        /* FOOTER */
        .footer {
            text-align: center;
            padding: 32px 20px;
            color: var(--text-muted);
            font-size: 12px;
            border-top: 1px solid var(--border-color);
            margin-top: 40px;
        }

        .footer a {
            color: var(--accent-secondary);
            text-decoration: none;
        }

        /* RESPONSIVE */
        @media (max-width: 640px) {
            .header h1 { font-size: 22px; }
            .card { padding: 20px; }
            .conditions-grid { grid-template-columns: 1fr; }
            .radio-option { min-width: 100%; }
            .btn-group { flex-direction: column; }
        }

        /* ANIMATIONS */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .fade-in {
            animation: fadeIn 0.3s ease forwards;
        }

        /* Method description */
        .method-info {
            padding: 14px;
            background: var(--info-bg);
            border: 1px solid rgba(59,130,246,0.15);
            border-radius: var(--radius-md);
            margin-top: 14px;
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
        }

        /* Observation summary */
        .obs-summary {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 16px;
        }

        .obs-chip {
            padding: 5px 12px;
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            font-size: 12px;
            color: var(--text-secondary);
        }

        .obs-chip strong {
            color: var(--text-primary);
        }
    </style>
</head>
<body>
    <div class="app-container">
        <!-- HEADER -->
        <header class="header">
            <div class="header-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="6" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><line x1="20" y1="4" x2="8.12" y2="15.88"></line><line x1="14.47" y1="14.48" x2="20" y2="20"></line><line x1="8.12" y1="8.12" x2="12" y2="12"></line></svg>
            </div>
            <h1>Garment Expert System</h1>
            <p>Advanced diagnostic tool for identifying and resolving garment sewing defects using industry-standard knowledge bases.</p>
        </header>

        <!-- STEP 1: INFERENCE METHOD -->
        <div class="card" id="step1-card">
            <div class="card-title">
                <span class="step-badge">1</span>
                Select Inference Method
            </div>
            <div class="card-subtitle">Choose how the system should reason about the defect.</div>
            <div class="radio-group">
                <div class="radio-option">
                    <input type="radio" id="method-forward" name="method" value="forward" checked>
                    <label for="method-forward">
                        <span class="radio-title">&#x27A1; Forward Chaining</span>
                        <span class="radio-desc">Data-driven: start with observations, find matching causes</span>
                    </label>
                </div>
                <div class="radio-option">
                    <input type="radio" id="method-backward" name="method" value="backward">
                    <label for="method-backward">
                        <span class="radio-title">&#x2B05; Backward Chaining</span>
                        <span class="radio-desc">Goal-driven: start with a hypothesis, verify conditions</span>
                    </label>
                </div>
            </div>
        </div>

        <!-- STEP 2: DEFECT SELECTION -->
        <div class="card" id="step2-card">
            <div class="card-title">
                <span class="step-badge">2</span>
                Select Observed Defect
            </div>
            <div class="card-subtitle">Choose the defect you have observed in the garment.</div>
            <div class="form-group">
                <select id="defect-select">
                    <option value="">-- Select a defect --</option>
                </select>
            </div>
            <div id="defect-description" style="display:none; margin-top:10px; padding:10px 14px; background:var(--bg-input); border-radius:var(--radius-sm); font-size:13px; color:var(--text-secondary);"></div>
        </div>

        <!-- STEP 3: CONDITIONS -->
        <div class="card" id="step3-card" style="display:none;">
            <div class="card-title">
                <span class="step-badge">3</span>
                Specify Observed Conditions
            </div>
            <div class="card-subtitle">Set the conditions you have observed. Leave as "Not specified" if unknown.</div>
            <div class="conditions-grid" id="conditions-grid"></div>

            <!-- HYPOTHESIS (backward only) -->
            <div id="hypothesis-section">
                <div class="form-group">
                    <label class="form-label">Hypothesis (Possible Cause to Investigate)</label>
                    <select id="hypothesis-select">
                        <option value="">-- Select a hypothesis --</option>
                    </select>
                </div>
            </div>
        </div>

        <!-- DIAGNOSE BUTTON -->
        <div class="btn-group" id="action-buttons" style="display:none;">
            <button class="btn btn-primary" id="diagnose-btn" onclick="runDiagnosis()">
                &#x1F50D; Run Diagnosis
            </button>
            <button class="btn btn-secondary" onclick="resetForm()">
                &#x21BA; Reset
            </button>
        </div>

        <!-- RESULTS -->
        <div id="results-section">
            <div class="card fade-in" id="results-card"></div>
        </div>

        <!-- VIEW ALL RULES -->
        <div class="card" style="margin-top: 32px;">
            <div class="card-title">
                <span class="step-badge">&#x2139;</span>
                Knowledge Base Rules
            </div>
            <div class="card-subtitle">All 28 source-backed rules implemented in the system.</div>
            <div class="rules-toggle">
                <button class="btn btn-secondary" onclick="toggleRulesTable()">
                    &#x1F4CB; View All Rules &amp; Sources
                </button>
            </div>
            <div class="rules-table-container" id="rules-table-container">
                <table class="rules-table" id="rules-table">
                    <thead>
                        <tr>
                            <th>Rule</th>
                            <th>Defect</th>
                            <th>Conditions</th>
                            <th>Concluded Cause</th>
                            <th>Source</th>
                        </tr>
                    </thead>
                    <tbody id="rules-table-body"></tbody>
                </table>
            </div>
        </div>

        <!-- FOOTER -->
        <footer class="footer">
            <p>Garment Quality Diagnosis Expert System &mdash; University Assignment</p>
            <p style="margin-top:4px;">Knowledge sourced from
                <a href="https://ebooks.inflibnet.ac.in/hsp08/chapter/apparel-quality-analysis-common-defects-in-spreading-cutting-bundling-sewing-pressing-and-finishing-quality-control-in-apparel-production/" target="_blank" rel="noopener">INFLIBNET</a> and
                <a href="https://bharatskills.gov.in/pdf/E_Books/CITS/431/English/Sewing%20technology%20(Trade%20Practical)%20-%20(Volume%20-%202).pdf" target="_blank" rel="noopener">CITS Sewing Technology</a>
            </p>
        </footer>
    </div>

    <script>
    // =====================================================================
    // APPLICATION STATE
    // =====================================================================
    let defects = [];
    let conditions = [];
    let causes = [];
    let rulesLoaded = false;

    // =====================================================================
    // INITIALIZATION
    // =====================================================================
    document.addEventListener("DOMContentLoaded", init);

    async function init() {
        await loadDefects();
        setupMethodListeners();
    }

    function setupMethodListeners() {
        document.querySelectorAll("input[name=method]").forEach(radio => {
            radio.addEventListener("change", () => {
                updateHypothesisVisibility();
            });
        });
    }

    // =====================================================================
    // LOAD DEFECTS
    // =====================================================================
    async function loadDefects() {
        try {
            const resp = await fetch("/api/defects");
            const data = await resp.json();
            defects = data.defects;
            const sel = document.getElementById("defect-select");
            defects.forEach(d => {
                const opt = document.createElement("option");
                opt.value = d.id;
                opt.textContent = d.name;
                sel.appendChild(opt);
            });
            sel.addEventListener("change", onDefectChange);
        } catch (e) {
            console.error("Failed to load defects:", e);
        }
    }

    // =====================================================================
    // ON DEFECT CHANGE
    // =====================================================================
    async function onDefectChange() {
        const defectId = document.getElementById("defect-select").value;
        const descDiv = document.getElementById("defect-description");
        const step3 = document.getElementById("step3-card");
        const actions = document.getElementById("action-buttons");

        if (!defectId) {
            descDiv.style.display = "none";
            step3.style.display = "none";
            actions.style.display = "none";
            return;
        }

        // Show description
        const defect = defects.find(d => d.id === defectId);
        if (defect) {
            descDiv.textContent = defect.description;
            descDiv.style.display = "block";
        }

        // Load conditions
        await loadConditions(defectId);

        // Load causes for backward chaining
        await loadCauses(defectId);

        step3.style.display = "block";
        step3.classList.add("fade-in");
        actions.style.display = "flex";

        updateHypothesisVisibility();
        hideResults();
    }

    // =====================================================================
    // LOAD CONDITIONS
    // =====================================================================
    async function loadConditions(defectId) {
        try {
            const resp = await fetch("/api/conditions?defect=" + encodeURIComponent(defectId));
            const data = await resp.json();
            conditions = data.conditions;

            const grid = document.getElementById("conditions-grid");
            grid.innerHTML = "";

            conditions.forEach(cond => {
                const item = document.createElement("div");
                item.className = "condition-item";

                const label = document.createElement("div");
                label.className = "cond-label";
                label.textContent = cond.id.replace(/_/g, " ");
                item.appendChild(label);

                const sel = document.createElement("select");
                sel.id = "cond-" + cond.id;
                sel.dataset.condId = cond.id;
                sel.className = "condition-select";

                cond.values.forEach(v => {
                    const opt = document.createElement("option");
                    opt.value = v.value;
                    opt.textContent = v.label;
                    if (v.value === "not_specified") opt.selected = true;
                    sel.appendChild(opt);
                });

                item.appendChild(sel);
                grid.appendChild(item);
            });
        } catch (e) {
            console.error("Failed to load conditions:", e);
        }
    }

    // =====================================================================
    // LOAD CAUSES (for backward chaining)
    // =====================================================================
    async function loadCauses(defectId) {
        try {
            const resp = await fetch("/api/causes?defect=" + encodeURIComponent(defectId));
            const data = await resp.json();
            causes = data.causes;

            const sel = document.getElementById("hypothesis-select");
            sel.innerHTML = "<option value=''''>-- Select a hypothesis --</option>";
            causes.forEach(c => {
                const opt = document.createElement("option");
                opt.value = c.cause;
                opt.textContent = c.cause.replace(/_/g, " ") + " (" + c.rule_id + ", " + c.source + ")";
                sel.appendChild(opt);
            });
        } catch (e) {
            console.error("Failed to load causes:", e);
        }
    }

    // =====================================================================
    // HYPOTHESIS VISIBILITY
    // =====================================================================
    function updateHypothesisVisibility() {
        const method = document.querySelector("input[name=method]:checked").value;
        const hypoSection = document.getElementById("hypothesis-section");
        hypoSection.style.display = method === "backward" ? "block" : "none";
    }

    // =====================================================================
    // RUN DIAGNOSIS
    // =====================================================================
    async function runDiagnosis() {
        const method = document.querySelector("input[name=method]:checked").value;
        const defectId = document.getElementById("defect-select").value;

        if (!defectId) {
            alert("Please select a defect first.");
            return;
        }

        // Gather observations
        const observations = [];
        document.querySelectorAll(".condition-select").forEach(sel => {
            const condId = sel.dataset.condId;
            const value = sel.value;
            if (value !== "not_specified") {
                observations.push({ condition: condId, value: value });
            }
        });

        // Build request
        const requestBody = {
            method: method,
            defect: defectId,
            observations: observations
        };

        if (method === "backward") {
            const hypothesis = document.getElementById("hypothesis-select").value;
            if (!hypothesis) {
                alert("Please select a hypothesis for backward chaining.");
                return;
            }
            requestBody.hypothesis = hypothesis;
        }

        // Show loading
        const btn = document.getElementById("diagnose-btn");
        const origText = btn.innerHTML;
        btn.innerHTML = "<span class=\\"spinner\\"></span> Diagnosing...";
        btn.disabled = true;

        try {
            const resp = await fetch("/diagnose", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(requestBody)
            });
            const result = await resp.json();
            displayResults(result);
        } catch (e) {
            console.error("Diagnosis failed:", e);
            alert("Diagnosis request failed. Please check the server.");
        } finally {
            btn.innerHTML = origText;
            btn.disabled = false;
        }
    }

    // =====================================================================
    // DISPLAY RESULTS
    // =====================================================================
    function displayResults(result) {
        const section = document.getElementById("results-section");
        const card = document.getElementById("results-card");
        card.innerHTML = "";

        if (result.method === "Forward Chaining") {
            displayForwardResults(card, result);
        } else {
            displayBackwardResults(card, result);
        }

        section.style.display = "block";
        section.scrollIntoView({ behavior: "smooth", block: "start" });
    }

    function displayForwardResults(card, result) {
        const numFired = result.num_rules_fired || 0;
        const hasResults = numFired > 0;

        // Header
        let headerHTML = "<div class=\\"result-header\\">";
        if (hasResults) {
            headerHTML += "<div class=\\"result-icon success\\">\\u2705</div>";
            headerHTML += "<div><div class=\\"result-title\\">Diagnosis Complete</div>";
            headerHTML += "<div class=\\"result-subtitle\\">" + numFired + " rule(s) fired for " + result.defect + "</div></div>";
        } else {
            headerHTML += "<div class=\\"result-icon warning\\">\\u26A0</div>";
            headerHTML += "<div><div class=\\"result-title\\">No Rules Fired</div>";
            headerHTML += "<div class=\\"result-subtitle\\">The given observations did not match any rule conditions for " + result.defect + ".</div></div>";
        }
        headerHTML += "</div>";
        card.innerHTML += headerHTML;

        // Method info
        card.innerHTML += "<div class=\\"method-info\\"><strong>Inference Method:</strong> " + result.method + "<br>" + result.method_description + "</div>";

        // Observations
        if (result.observations && result.observations.length > 0) {
            let obsHTML = "<div style=\\"margin-top:16px;\\"><div class=\\"detail-label\\">OBSERVED CONDITIONS</div><div class=\\"obs-summary\\">";
            result.observations.forEach(obs => {
                obsHTML += "<span class=\\"obs-chip\\"><strong>" + obs.condition.replace(/_/g, " ") + ":</strong> " + obs.label + "</span>";
            });
            obsHTML += "</div></div>";
            card.innerHTML += obsHTML;
        }

        // Each result
        if (hasResults && result.results) {
            result.results.forEach(r => {
                card.innerHTML += renderForwardResultCard(r);
            });
        }

        // Reasoning trace
        if (hasResults && result.results) {
            card.innerHTML += renderForwardTrace(result);
        }
    }

    function renderForwardResultCard(r) {
        let html = "<div class=\\"result-card\\">";
        html += "<span class=\\"rule-badge\\">" + r.rule_id + "</span>";

        // Source tag
        if (r.source_url) {
            html += "<a href=\\"" + r.source_url + "\\" target=\\"_blank\\" rel=\\"noopener\\" class=\\"source-tag\\">\\uD83D\\uDCDA " + r.source_id + "</a>";
        } else {
            html += "<span class=\\"source-tag\\">\\uD83D\\uDCDA " + r.source_id + "</span>";
        }

        // Cause
        html += "<div class=\\"cause-text\\">Possible Cause: " + r.cause.replace(/_/g, " ") + "</div>";

        // Matched conditions
        html += "<div class=\\"matched-conditions\\">";
        if (r.matched_conditions) {
            r.matched_conditions.forEach(mc => {
                html += "<span class=\\"matched-cond-tag\\">\\u2713 " + mc.condition.replace(/_/g, " ") + " = " + mc.label + "</span>";
            });
        }
        html += "</div>";

        // Source explanation
        html += "<div class=\\"result-detail\\"><div class=\\"detail-label\\">SOURCE EXPLANATION</div>";
        html += "<div class=\\"detail-value\\">" + r.source_explanation + "</div></div>";

        // Source name
        html += "<div class=\\"result-detail\\"><div class=\\"detail-label\\">SOURCE DOCUMENT</div>";
        html += "<div class=\\"detail-value\\">" + r.source_name + "</div></div>";

        // Corrective action
        const isNoCorrectiveAction = r.corrective_action.indexOf("No source-backed") !== -1;
        const actionClass = isNoCorrectiveAction ? "corrective-action no-corrective" : "corrective-action";
        html += "<div class=\\"" + actionClass + "\\"><div class=\\"detail-label\\">CORRECTIVE ACTION</div>";
        html += "<div class=\\"detail-value\\">" + r.corrective_action + "</div></div>";

        html += "</div>";
        return html;
    }

    function renderForwardTrace(result) {
        let trace = "";
        trace += "<span class=\\"trace-step\\">FORWARD CHAINING REASONING TRACE</span>\\n";
        trace += "\\u2550".repeat(50) + "\\n\\n";

        trace += "<span class=\\"trace-step\\">Step 1: Collect Observations</span>\\n";
        result.observations.forEach(obs => {
            trace += "  \\u2022 " + obs.condition.replace(/_/g, " ") + " = " + obs.label + "\\n";
        });
        trace += "\\n";

        trace += "<span class=\\"trace-step\\">Step 2: Scan Rules for Defect \\u201C" + result.defect + "\\u201D</span>\\n";
        trace += "  Checking all rules whose defect matches...\\n\\n";

        if (result.results && result.results.length > 0) {
            result.results.forEach((r, i) => {
                trace += "<span class=\\"trace-step\\">Step " + (3 + i) + ": Evaluate " + r.rule_id + "</span>\\n";
                trace += "  <span class=\\"trace-rule\\">Rule: " + r.rule_id + "</span>\\n";
                trace += "  Conditions required:\\n";
                if (r.matched_conditions) {
                    r.matched_conditions.forEach(mc => {
                        trace += "    \\u2713 " + mc.condition.replace(/_/g, " ") + " = " + mc.value + " [SATISFIED]\\n";
                    });
                }
                trace += "  All conditions satisfied \\u2192 RULE FIRES\\n";
                trace += "  <span class=\\"trace-source\\">Source: " + r.source_name + "</span>\\n";
                trace += "  <span class=\\"trace-conclusion\\">\\u2192 Conclusion: Possible cause = " + r.cause.replace(/_/g, " ") + "</span>\\n\\n";
            });
        } else {
            trace += "<span class=\\"trace-step\\">No rules matched the given observations.</span>\\n";
        }

        trace += "\\u2550".repeat(50) + "\\n";
        trace += "<span class=\\"trace-conclusion\\">DIAGNOSIS COMPLETE: " + (result.num_rules_fired || 0) + " rule(s) fired.</span>";

        let html = "<div class=\\"trace-section\\">";
        html += "<div class=\\"trace-title\\">\\uD83D\\uDD0D Full Reasoning Trace</div>";
        html += "<div class=\\"trace-box\\">" + trace + "</div></div>";
        return html;
    }

    function displayBackwardResults(card, result) {
        const numAttempts = result.num_proof_attempts || 0;

        let headerHTML = "<div class=\\"result-header\\">";
        if (numAttempts > 0) {
            const anyProven = result.proof_results.some(p => p.status === "proven");
            if (anyProven) {
                headerHTML += "<div class=\\"result-icon success\\">\\u2705</div>";
                headerHTML += "<div><div class=\\"result-title\\">Hypothesis Confirmed</div>";
            } else {
                headerHTML += "<div class=\\"result-icon warning\\">\\u26A0</div>";
                headerHTML += "<div><div class=\\"result-title\\">Hypothesis Not Confirmed</div>";
            }
            headerHTML += "<div class=\\"result-subtitle\\">" + numAttempts + " rule(s) evaluated for hypothesis: " + result.hypothesis.replace(/_/g, " ") + "</div></div>";
        } else {
            headerHTML += "<div class=\\"result-icon warning\\">\\u26A0</div>";
            headerHTML += "<div><div class=\\"result-title\\">No Matching Rules</div>";
            headerHTML += "<div class=\\"result-subtitle\\">No rules conclude the hypothesis \\u201C" + result.hypothesis.replace(/_/g, " ") + "\\u201D for " + result.defect + ".</div></div>";
        }
        headerHTML += "</div>";
        card.innerHTML += headerHTML;

        // Method info
        card.innerHTML += "<div class=\\"method-info\\"><strong>Inference Method:</strong> " + result.method + "<br>" + result.method_description + "</div>";

        // Observations
        if (result.observations && result.observations.length > 0) {
            let obsHTML = "<div style=\\"margin-top:16px;\\"><div class=\\"detail-label\\">PROVIDED OBSERVATIONS</div><div class=\\"obs-summary\\">";
            result.observations.forEach(obs => {
                obsHTML += "<span class=\\"obs-chip\\"><strong>" + obs.condition.replace(/_/g, " ") + ":</strong> " + obs.label + "</span>";
            });
            obsHTML += "</div></div>";
            card.innerHTML += obsHTML;
        }

        // Proof results
        if (result.proof_results) {
            result.proof_results.forEach(p => {
                card.innerHTML += renderBackwardResultCard(p);
            });
        }

        // Reasoning trace
        if (result.proof_results) {
            card.innerHTML += renderBackwardTrace(result);
        }
    }

    function renderBackwardResultCard(p) {
        let html = "<div class=\\"result-card\\">";
        html += "<span class=\\"rule-badge\\">" + p.rule_id + "</span>";
        html += "<span class=\\"proof-status " + p.status + "\\">" + p.status.replace(/_/g, " ") + "</span>";

        if (p.source_url) {
            html += " <a href=\\"" + p.source_url + "\\" target=\\"_blank\\" rel=\\"noopener\\" class=\\"source-tag\\">\\uD83D\\uDCDA " + p.source_id + "</a>";
        }

        html += "<div class=\\"cause-text\\">Hypothesis: " + p.hypothesis.replace(/_/g, " ") + "</div>";

        // Satisfied conditions
        if (p.satisfied_conditions && p.satisfied_conditions.length > 0) {
            html += "<div class=\\"matched-conditions\\">";
            p.satisfied_conditions.forEach(sc => {
                html += "<span class=\\"matched-cond-tag\\">\\u2713 " + sc.condition.replace(/_/g, " ") + " = " + sc.label + "</span>";
            });
            html += "</div>";
        }

        // Missing conditions
        if (p.missing_conditions && p.missing_conditions.length > 0) {
            html += "<div class=\\"matched-conditions\\" style=\\"margin-top:6px;\\">";
            p.missing_conditions.forEach(mc => {
                html += "<span class=\\"missing-cond-tag\\">\\u2717 MISSING: " + mc.condition.replace(/_/g, " ") + " = " + mc.label + "</span>";
            });
            html += "</div>";
        }

        // Source explanation
        html += "<div class=\\"result-detail\\"><div class=\\"detail-label\\">SOURCE EXPLANATION</div>";
        html += "<div class=\\"detail-value\\">" + p.source_explanation + "</div></div>";

        // Corrective action
        if (p.status === "proven") {
            const isNoAction = p.corrective_action.indexOf("No source-backed") !== -1;
            const actionClass = isNoAction ? "corrective-action no-corrective" : "corrective-action";
            html += "<div class=\\"" + actionClass + "\\"><div class=\\"detail-label\\">CORRECTIVE ACTION</div>";
            html += "<div class=\\"detail-value\\">" + p.corrective_action + "</div></div>";
        }

        html += "</div>";
        return html;
    }

    function renderBackwardTrace(result) {
        let trace = "";
        trace += "<span class=\\"trace-step\\">BACKWARD CHAINING REASONING TRACE</span>\\n";
        trace += "\\u2550".repeat(50) + "\\n\\n";

        trace += "<span class=\\"trace-step\\">Step 1: Set Hypothesis</span>\\n";
        trace += "  Hypothesis: " + result.hypothesis.replace(/_/g, " ") + "\\n";
        trace += "  Defect context: " + result.defect + "\\n\\n";

        trace += "<span class=\\"trace-step\\">Step 2: Collect Observations</span>\\n";
        if (result.observations && result.observations.length > 0) {
            result.observations.forEach(obs => {
                trace += "  \\u2022 " + obs.condition.replace(/_/g, " ") + " = " + obs.label + "\\n";
            });
        } else {
            trace += "  (no observations provided)\\n";
        }
        trace += "\\n";

        trace += "<span class=\\"trace-step\\">Step 3: Find Rules Concluding Hypothesis</span>\\n";

        if (result.proof_results && result.proof_results.length > 0) {
            result.proof_results.forEach((p, i) => {
                trace += "\\n<span class=\\"trace-step\\">Step " + (4 + i) + ": Evaluate " + p.rule_id + "</span>\\n";
                trace += "  <span class=\\"trace-rule\\">Rule: " + p.rule_id + "</span>\\n";
                trace += "  Required conditions:\\n";
                if (p.satisfied_conditions) {
                    p.satisfied_conditions.forEach(sc => {
                        trace += "    \\u2713 " + sc.condition.replace(/_/g, " ") + " = " + sc.value + " [PRESENT IN OBSERVATIONS]\\n";
                    });
                }
                if (p.missing_conditions) {
                    p.missing_conditions.forEach(mc => {
                        trace += "    \\u2717 " + mc.condition.replace(/_/g, " ") + " = " + mc.value + " [NOT IN OBSERVATIONS]\\n";
                    });
                }
                trace += "  <span class=\\"trace-source\\">Source: " + p.source_id + "</span>\\n";
                if (p.status === "proven") {
                    trace += "  <span class=\\"trace-conclusion\\">\\u2192 All conditions satisfied. HYPOTHESIS PROVEN.</span>\\n";
                } else {
                    trace += "  \\u2192 Missing conditions. Hypothesis NOT proven via this rule.\\n";
                }
            });
        } else {
            trace += "  No rules found that conclude this hypothesis.\\n";
        }

        trace += "\\n" + "\\u2550".repeat(50) + "\\n";
        const anyProven = result.proof_results && result.proof_results.some(p => p.status === "proven");
        if (anyProven) {
            trace += "<span class=\\"trace-conclusion\\">CONCLUSION: Hypothesis CONFIRMED by at least one rule.</span>";
        } else {
            trace += "CONCLUSION: Hypothesis could NOT be confirmed with the given observations.";
        }

        let html = "<div class=\\"trace-section\\">";
        html += "<div class=\\"trace-title\\">\\uD83D\\uDD0D Full Reasoning Trace</div>";
        html += "<div class=\\"trace-box\\">" + trace + "</div></div>";
        return html;
    }

    // =====================================================================
    // RULES TABLE
    // =====================================================================
    async function toggleRulesTable() {
        const container = document.getElementById("rules-table-container");
        if (container.style.display === "block") {
            container.style.display = "none";
            return;
        }

        if (!rulesLoaded) {
            try {
                const resp = await fetch("/api/rules");
                const data = await resp.json();
                const tbody = document.getElementById("rules-table-body");
                tbody.innerHTML = "";
                data.rules.forEach(r => {
                    const tr = document.createElement("tr");
                    const conds = Array.isArray(r.conditions) ? r.conditions.join(", ") : r.conditions;
                    tr.innerHTML = "<td><span class=\\"rule-badge\\">" + r.rule_id + "</span></td>" +
                        "<td>" + r.defect + "</td>" +
                        "<td>" + conds + "</td>" +
                        "<td>" + (r.cause ? r.cause.toString().replace(/_/g, " ") : "") + "</td>" +
                        "<td><a href=\\"" + (r.source_url || "#") + "\\" target=\\"_blank\\" rel=\\"noopener\\" class=\\"source-tag\\">\\uD83D\\uDCDA " + r.source_id + "</a></td>";
                    tbody.appendChild(tr);
                });
                rulesLoaded = true;
            } catch (e) {
                console.error("Failed to load rules:", e);
            }
        }

        container.style.display = "block";
    }

    // =====================================================================
    // UTILITIES
    // =====================================================================
    function hideResults() {
        document.getElementById("results-section").style.display = "none";
    }

    function resetForm() {
        document.getElementById("defect-select").value = "";
        document.getElementById("defect-description").style.display = "none";
        document.getElementById("step3-card").style.display = "none";
        document.getElementById("action-buttons").style.display = "none";
        document.getElementById("conditions-grid").innerHTML = "";
        document.getElementById("hypothesis-select").innerHTML = "<option value=''''>-- Select a hypothesis --</option>";
        document.querySelector("#method-forward").checked = true;
        updateHypothesisVisibility();
        hideResults();
        window.scrollTo({ top: 0, behavior: "smooth" });
    }
    </script>
</body>
</html>
').


