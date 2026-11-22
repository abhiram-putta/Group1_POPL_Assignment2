:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(apply)).

% Load ../code/1_q1.pl relative to this test file's own folder, so the
% tests work no matter which folder swipl is started from.
:- prolog_load_context(directory, Dir),
   directory_file_path(Dir, '../code/1_q1.pl', File),
   consult(File).

%% hand_solution(-Solution)
%  hand_solution(S) is true when S is the hand-made test solution.
hand_solution([p('Alex', design, java, web),
               p('Ben', testing, python, data),
               p('Carla', research, 'c++', 'AI'),
               p('Dana', development, javascript, embedded)]).

%% uses_each_once(+Solution)
%  uses_each_once(S) is true when every dept, lang and project value
%  appears exactly once in S.
uses_each_once(S) :-
    maplist([p(_, D, _, _), D]>>true, S, Ds),
    maplist([p(_, _, L, _), L]>>true, S, Ls),
    maplist([p(_, _, _, P), P]>>true, S, Ps),
    same_values(dept, Ds),
    same_values(lang, Ls),
    same_values(project, Ps).

%% same_values(+Attr, +Values)
%  same_values(A, Vs) is true when Vs holds exactly the values of A,
%  each once, in any order.
same_values(Attr, Values) :-
    findall(V, call(Attr, V), All),
    msort(All, Sorted),
    msort(Values, Sorted).

%% starts_with(+Prefix, +Line)
%  starts_with(P, L) is true when string L begins with string P.
starts_with(Prefix, Line) :-
    string_concat(Prefix, _, Line).

% ---------------------------------------------------------------
% Test 1: clues 1 to 8 on the hand-made solution
% ---------------------------------------------------------------
:- begin_tests(hand_solution_clues).

test(clue1_fails, [fail])   :- hand_solution(S), clue(1, S).
test(clue2_holds, [nondet]) :- hand_solution(S), clue(2, S).
test(clue3_holds, [nondet]) :- hand_solution(S), clue(3, S).
test(clue4_fails, [fail])   :- hand_solution(S), clue(4, S).
test(clue5_holds, [nondet]) :- hand_solution(S), clue(5, S).
test(clue6_holds, [nondet]) :- hand_solution(S), clue(6, S).
test(clue7_fails, [fail])   :- hand_solution(S), clue(7, S).
test(clue8_fails, [fail])   :- hand_solution(S), clue(8, S).

:- end_tests(hand_solution_clues).

% ---------------------------------------------------------------
% Test 2: every solution of solve/1 is valid
% ---------------------------------------------------------------
:- begin_tests(solve).

test(has_a_solution, [nondet]) :-
    solve(_).

test(all_clues_hold) :-
    forall(solve(S),
           forall(member(N, [1, 2, 3, 4, 5, 6, 7, 8]), clue(N, S))).

test(each_value_once) :-
    forall(solve(S), uses_each_once(S)).

:- end_tests(solve).

% ---------------------------------------------------------------
% Test 3: main/0 output shape
% ---------------------------------------------------------------
:- begin_tests(main_output).

test(four_lines_in_order) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", Parts),
    append(Lines, [""], Parts),
    Lines = [L1, L2, L3, L4],
    starts_with("Alex = [", L1),
    starts_with("Ben = [", L2),
    starts_with("Carla = [", L3),
    starts_with("Dana = [", L4).

:- end_tests(main_output).

% ---------------------------------------------------------------
% count_solutions/2 tests (P1.b)
% ---------------------------------------------------------------
:- begin_tests(count_solutions).

test(no_clues, [true(N =:= 13824)]) :-
    count_solutions([], N).

test(clue4_only, [true(N =:= 2592)]) :-
    count_solutions([4], N).

test(clue5_only, [true(N =:= 3456)]) :-
    count_solutions([5], N).

test(clues_1_to_8, [true(N =:= 3)]) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8], N).

:- end_tests(count_solutions).

% ---------------------------------------------------------------
% clue 9 tests (P1.c)
% ---------------------------------------------------------------
:- begin_tests(clue9).

test(clues_1_to_9_unique, [true(N =:= 1)]) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8, 9], N).

test(clue9_keeps_one_solve_solution, [true(C =:= 1)]) :-
    aggregate_all(count, (solve(S), clue(9, S)), C).

:- end_tests(clue9).