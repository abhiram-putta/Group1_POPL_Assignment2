# CS F301 Principles of Programming Languages: Assignment 2

Logic and Functional Programming. **Group ID: 1**

## Members

| Member | Name | Work |
|---|---|---|
| A | Abhiram | P1, `prolog-dev` skill, `P1_REPORT.md` |
| B | Tarun | P2 |
| C | Shriyans | S1, `scheme-dev` skill |
| D | Prabhas | S2, README |

## Layout

```
code/      1_q1.pl  1_q2.pl  1_q3.rkt  1_q4.rkt
tests/     test_q1.pl  test_q2.pl  test_q3.sh  test_q4.sh
skills/    prolog-dev/SKILL.md  scheme-dev/SKILL.md
prompts/   P1.md  P2.md  S1.md  S2.md
P1_REPORT.md
```

## Running the solutions

Run everything from the repository root (SWI-Prolog 9.x, Racket 8.x).

```bash
swipl -q -f code/1_q1.pl -g main -t halt
swipl -q -f code/1_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt
```

The Racket files contain only definitions and print nothing on load. The grader appends its own calls to `code/1_q3.rkt` and `code/1_q4.rkt`. To try one by hand:

```bash
(cat code/1_q3.rkt; echo "(print-inorder '(4 (2 () ()) (6 () ())))") > /tmp/s1.rkt && racket /tmp/s1.rkt
(cat code/1_q4.rkt; echo "(print-insert-result)") > /tmp/s2.rkt && echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket /tmp/s2.rkt
```

## Running the tests

```bash
swipl -q -g run_tests -t halt tests/test_q1.pl
swipl -q -g run_tests -t halt tests/test_q2.pl
bash tests/test_q3.sh
bash tests/test_q4.sh
```

The tests cover every example in the PDF plus our own edge cases. The Scheme scripts print `PASS`/`FAIL` per test and a final count.

## AI use

We used Claude, guided by our skill files in `skills/`, one unit of work (one predicate, function, test file or review) per prompt. Every prompt is logged word for word in `prompts/`, one file per problem.

