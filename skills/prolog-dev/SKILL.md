---
name: prolog-dev
description: Rules for writing, testing and reviewing SWI-Prolog 9.x code for abhi's university assignment, one unit of work at a time.
---

# prolog-dev

## 0. Scope rule: one unit of work per message
- Do only the one unit of work asked for in the current message: one predicate, one helper, one test file, one fix or one explanation.
- Never write a whole problem at once, even when it looks easy or I could guess the rest.
- If the request is unclear or seems to need more than one unit, say what the smallest next unit is and ask before going further.
- End each answer by naming the next logical unit, but do not write it.

## 1. Language and version
- Target: SWI-Prolog 9.x. Use only standard 9.x built-ins and the allowed libraries (section 3).
- The grader runs files like this:
  - `swipl -q -f FILE -g main -t halt` for the main entry point.
  - `swipl -q -f FILE -g "<goal>" -t halt` for any other predicate, e.g. `swipl -q -f code/1_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), write(N), nl" -t halt`.
- So the file must load silently: no warnings (singleton, discontiguous, clauses not together), no output while loading.
- `-t halt` ends the process. The file itself must never halt.

## 2. Coding conventions
- Predicate and variable-ish atom names use snake_case (`count_vowels/2`, not `countVowels/2`). Variables use CamelCase (`Rest`, `Acc`).
- Above every predicate, write a comment that gives its declarative reading and its modes:
  ```prolog
  %% count_vowels(+Atom, -Count)
  %  count_vowels(A, N) is true when N is the number of vowels in atom A.
  ```
- Mode symbols: `+` must be bound on call, `-` must be unbound and gets bound, `?` may be either.
- Prefer small helper predicates over long clauses with nested if-then-else. A clause body longer than about 6 goals is a sign to split it.
- Keep all clauses of a predicate together. Put helpers directly below the predicate that uses them.
- Use accumulators (`foo_(List, Acc0, Result)`) for tail recursion and name the helper with a trailing underscore or `_acc`.
- Use `_` or `_Name` for unused variables so there are no singleton warnings.

## 3. Hard rules of the assignment (never break these)
- The file contains only definitions (facts, rules, the allowed `:- use_module` lines).
- No `:- initialization(...)` directive, no other goal directives.
- Never call `halt/0` or `halt/1`.
- No `assert`, `asserta`, `assertz`, `retract`, `retractall`, `b_setval`, `b_getval`, `nb_setval`, `nb_getval`, and no global variables of any kind.
- Only these libraries: `library(lists)`, `library(apply)`, `library(yall)`, `library(aggregate)`. No others, not even ones that autoload (e.g. no `pairs`, `strings`, `dcg/basics`, `clpfd`).
- Print nothing except exactly what the task asks for. No debug output, no prompts, no extra spaces or newlines, no `true.` or `false.` messages.
- When output is required, match the expected format exactly (spacing, newlines, brackets, quotes).

## 4. How to run and test
- Repository layout: solution files live in `code/` (`code/1_q1.pl`, `code/1_q2.pl`) and test files live in `tests/` (`tests/test_q1.pl`, `tests/test_q2.pl`).
- Run every command from the repository's top folder.
- Load and check for warnings:
  `swipl -q -f code/1_q1.pl -g true -t halt`
  `swipl -q -f code/1_q2.pl -g true -t halt`
- Run main (q1 only; q2 has no `main/0`, so run its predicates with `-g "<goal>"`):
  `swipl -q -f code/1_q1.pl -g main -t halt`
- Run one goal:
  `swipl -q -f code/1_q1.pl -g "my_pred(In, Out), write(Out), nl" -t halt`
- Check that a goal leaves no choice point: in `swipl code/1_q1.pl`, run the query; if it ends with `true.` it is deterministic, if it waits after `true` (`;` prompt) it left a choice point.
- Tests use plunit in a separate file under `tests/`, e.g. `tests/test_q1.pl`:
  ```prolog
  :- use_module(library(plunit)).
  :- consult('../code/1_q1.pl').

  :- begin_tests(count_vowels).
  test(simple, [true(N =:= 2)]) :- count_vowels(hello, N).
  test(empty, [true(N =:= 0)]) :- count_vowels('', N).
  test(det, [nondet]) :- count_vowels(abc, _).
  test(fails, [fail]) :- count_vowels(abc, 5).
  :- end_tests(count_vowels).
  ```
  `tests/test_q2.pl` is the same, but consults `'../code/1_q2.pl'`. plunit is only used in tests, never in the solution files.
- Run the tests:
  `swipl -q -g run_tests -t halt tests/test_q1.pl`
  `swipl -q -g run_tests -t halt tests/test_q2.pl`
- Each test file covers: a normal case, an edge case (empty list, zero, empty atom), a failure case, and determinism (plunit warns about choice points unless the test says `nondet`).

## 5. Self-review checklist (go through every item before every answer)
1. Did I do only the one unit of work asked for?
2. Does every predicate have a declarative-reading comment and modes?
3. Are all names snake_case, clauses together, and no singleton variables?
4. No `initialization`, no `halt`, no assert/retract/b_setval/nb_setval/global variables?
5. Only lists, apply, yall, aggregate are used, and every built-in I call exists in SWI-Prolog 9.x?
6. Does the file load with `-q` with zero warnings and zero output?
7. Does it print only what is asked, in the exact format, using `write`/`format ~w` (not `writeq`/`print`) for atoms?
8. Is every `is/2`, `=:=`, `<`, etc. called only after its right-hand side is bound?
9. Is every `\+` called only on goals whose variables are already bound?
10. Is there no left recursion, and does recursion always move toward a base case?
11. Does the predicate give the right number of answers: no duplicates, and no leftover choice point when it should be deterministic?
12. Are cuts placed only after the clause is known to be the right one (green cuts), and does the code still work in every mode I documented?
13. Did I test it with the one-line swipl commands (or say clearly that I did not run it)?
14. Does every mode I claimed (+, -, ?) actually work? If not, fix the code or the comment.

## 6. Known failure modes of AI tools in Prolog
- **Negation on unbound variables.** `\+ member(X, L)` with X unbound means "L is empty", not "X is not in L". Bind X first, then negate. `\+` never binds anything.
- **`is/2` before variables are bound.** `X is Y + 1` with Y unbound raises an instantiation error. Order goals so inputs are bound first, especially in accumulator code where the recursive call must come after the arithmetic, or the arithmetic after the recursive call, depending on data flow.
- **`=` vs `is` vs `=:=`.** `X = 1+2` gives the term `1+2`, not 3. Use `is` to compute, `=:=` to compare numbers, `==` to compare terms without binding.
- **Quotes from `writeq` and `print`.** `writeq('AI')` prints `'AI'`, `print('c++')` prints `'c++'`. For plain output use `write/1` or `format("~w", [X])`. Use `~a` only for atoms. `print/1` quotes like `writeq`, so avoid it for output.
- **Strings vs atoms vs code lists.** In SWI-Prolog 9, `"abc"` is a string, not a code list. Do not mix them up; use `atom_chars/2`, `atom_codes/2`, `atom_string/2`, `number_codes/2` deliberately.
- **Infinite left recursion.** `ancestor(X, Z) :- ancestor(X, Y), parent(Y, Z).` loops. Put the base case first and a non-recursive goal before the recursive call.
- **Non-termination in other modes.** `length(L, N)` or `append(X, Y, Z)` with too few bound arguments can produce infinite answers. Only promise the modes that terminate.
- **Duplicate solutions.** Overlapping clauses (e.g. both `X =< Y` and `X >= Y` cases) or `member/2` on lists with repeats give the same answer twice. Make clauses mutually exclusive, or use `memberchk/2`, `sort/2`, `setof/3` or `aggregate_all/3` when one answer is wanted.
- **Leftover choice points.** A deterministic predicate that leaves `;` open is a bug. Fix with first-argument indexing (put the list/structure in the first argument, `[]` vs `[H|T]` clauses), mutually exclusive guards, `memberchk/2`, or if-then-else instead of separate clauses.
- **Cuts in the wrong place.** A cut before the clause is known to match (`foo(X, Y) :- !, X > 0, ...`) removes valid alternatives. A cut in a predicate with output arguments in the head (`max(X, Y, X) :- X >= Y, !.`) breaks when called with the output bound; put output unification after the cut. Prefer if-then-else (`( Cond -> Then ; Else )`) over red cuts.
- **`findall` vs `bagof`/`setof`.** `findall` gives `[]` on no solutions; `bagof`/`setof` fail and group by free variables unless you use `^`. Choose deliberately.
- **`aggregate_all(count, ...)` vs `aggregate(count, ...)`.** `aggregate/3` fails on zero solutions and groups by free variables; `aggregate_all/3` gives 0.
- **yall lambdas and free variables.** In `maplist([X]>>(Y is X*K), ...)`, variables outside the lambda are copied unless shared with `\` or `/`: write `K/[X,Y]>>(Y is X*K)` when needed, and test the lambda.
- **Singleton and discontiguous warnings.** These print to stderr on load and can fail the "print nothing" rule. Load with `-g true` to check.
- **Made-up built-ins.** Do not invent predicates (e.g. `sum/2`, `string_reverse/2`). Use real ones like `sum_list/2`, `max_list/2`, `nth0/3`, `nth1/3`, `last/2`, `msort/2`, `exclude/3`, `foldl/4`, or write a helper.
- **Floats vs integers.** `/` can give a float (`4/2` is `2` but `5/2` is `2.5`); use `//` for integer division and check the expected output format.