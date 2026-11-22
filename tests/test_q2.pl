%% tests/test_q2.pl -- plunit tests for P2 (form a valid arithmetic equation).
%  Run from the repository root:
%    swipl -q -g run_tests -t halt tests/test_q2.pl
%
%  Expected values are the PDF's examples plus edge cases. All expected lists
%  were cross-checked against an independent brute-force enumerator.

:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(time)).        % call_with_time_limit/2, tests only

%  Load the solution relative to THIS file's directory, not the CWD.
:- prolog_load_context(directory, Dir),
   atomic_list_concat([Dir, '/../code/1_q2.pl'], SolutionFile),
   consult(SolutionFile).

%% within_limit(:Goal)
%  within_limit(G) is true when G succeeds within 20 seconds. If G loops,
%  a time_limit_exceeded exception is raised and the test is reported as an
%  error instead of hanging the test run.
within_limit(Goal) :-
    call_with_time_limit(20, Goal).

%% pdf_equations(-Es)
%  pdf_equations(Es) is true when Es is the PDF's sorted list for [4,2,5,3].
pdf_equations(["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
               "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]).

%% well_formed(+Es)
%  well_formed(Es) is true when every element of Es is a string that
%  contains no space character.
well_formed(Es) :-
    forall(member(S, Es),
           ( string(S),
             \+ sub_string(S, _, _, _, " ") )).

% ---------------------------------------------------------------------------
:- begin_tests(generate_equation).

% 1. Must fail cleanly: no error (an exception makes plunit report an error)
%    and no loop (within_limit raises if it runs too long).
test(empty_list, [fail]) :-
    within_limit(generate_equation([], _)).
test(single_element, [fail]) :-
    within_limit(generate_equation([7], _)).
test(no_solution_234, [fail]) :-
    within_limit(generate_equation([2,3,4], _)).
test(no_solution_12, [fail]) :-
    within_limit(generate_equation([1,2], _)).

% 2. Any one of the PDF's seven equations, returned as a string.
%    nondet: the spec allows generate_equation to leave alternatives open.
test(pdf_example, [nondet, true((string(E), pdf_equations(Es), memberchk(E, Es)))]) :-
    within_limit(generate_equation([4,2,5,3], E)).

:- end_tests(generate_equation).

% ---------------------------------------------------------------------------
:- begin_tests(all_equations).

% == (not =) also checks that the elements are strings, not atoms or codes.

% 3. Exactly the PDF list, in sort/2 order.
test(pdf_example, [true(Es == Expected)]) :-
    pdf_equations(Expected),
    within_limit(all_equations([4,2,5,3], Es)).

% 4. PDF examples: none, and a single one.
test(no_solution_234, [true(Es == [])]) :-
    within_limit(all_equations([2,3,4], Es)).
test(single_248, [true(Es == ["2*4=8"])]) :-
    within_limit(all_equations([2,4,8], Es)).

% 5. Extra cases.
test(sum_123, [true(Es == ["1+2=3"])]) :-
    within_limit(all_equations([1,2,3], Es)).
test(div_and_mul_842, [true(Es == ["8/4=2", "8=4*2"])]) :-
    within_limit(all_equations([8,4,2], Es)).
test(div_by_zero_skipped_400, [true(Es == ["4*0=0"])]) :-
    within_limit(all_equations([4,0,0], Es)).
test(two_zeros, [true(Es == ["0=0"])]) :-
    within_limit(all_equations([0,0], Es)).

:- end_tests(all_equations).

% ---------------------------------------------------------------------------
:- begin_tests(count_equations).

% 6. == checks N is the integer, not just numerically equal.
test(pdf_example, [true(N == 7)]) :-
    within_limit(count_equations([4,2,5,3], N)).
test(all_ones, [true(N == 30)]) :-
    within_limit(count_equations([1,1,1,1], N)).
test(one_to_six, [true(N == 101)]) :-
    within_limit(count_equations([1,2,3,4,5,6], N)).
test(no_solution, [true(N == 0)]) :-
    within_limit(count_equations([2,3,4], N)).

:- end_tests(count_equations).

% ---------------------------------------------------------------------------
:- begin_tests(equation_format).

% 7. Every returned element is a string with no spaces.
test(pdf_example) :-
    within_limit(all_equations([4,2,5,3], Es)),
    well_formed(Es).
test(all_ones) :-
    within_limit(all_equations([1,1,1,1], Es)),
    well_formed(Es).
test(one_to_six) :-
    within_limit(all_equations([1,2,3,4,5,6], Es)),
    well_formed(Es).
test(with_zeros) :-
    within_limit(all_equations([4,0,0], Es)),
    well_formed(Es).

:- end_tests(equation_format).