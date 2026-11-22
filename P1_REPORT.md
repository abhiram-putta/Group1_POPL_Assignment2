# P1 Report: Department Assignment Puzzle

## Number of solutions for clues 1 to 8

`count_solutions([1,2,3,4,5,6,7,8], N)` gives **N = 3**.

This means the eight clues are **not enough** to pin down a single answer. Three
different assignments satisfy all of them:

| # | Alex | Ben | Carla | Dana |
|---|------|-----|-------|------|
| 1 | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| 2 | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| 3 | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

Ben's row is the same in all three, so the clues fix Ben completely. The
uncertainty is only in how Alex, Carla and Dana share the remaining values.

## Clue 9

> The friend who works in the testing department prefers the AI project.

With this clue, `count_solutions([1,2,3,4,5,6,7,8,9], N)` gives **N = 1**.

It keeps only solution 2, where the testing friend (Carla) prefers AI. In
solutions 1 and 3 the testing friend (Dana or Alex) prefers embedded, so the
clue is false there.

Solution 2 was the only one a clue could keep without naming anyone. Solutions
1 and 3 contain exactly the same four department-language-project
combinations, just given to different people. A clue that talks only about
attribute values can never tell them apart, so it can only separate out
solution 2.