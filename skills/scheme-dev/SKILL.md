---
name: scheme-dev
description: Rules for writing, testing and reviewing Racket 8.x (#lang racket/base) code for the CS F301 Assignment 2 Scheme problems, one unit of work at a time.
---

# scheme-dev

## 0. Scope rule: one unit of work per message
- Do only the one unit of work asked for in the current message: one function (plus its small private helpers), one test script, one fix or one review.
- Never write a whole problem at once, even when it looks easy or the rest is obvious.
- If the request is unclear or seems to need more than one unit, say what the smallest next unit is and ask before going further.
- End each answer by naming the next logical unit, but do not write it.

## 1. Language and version
- Target: Racket 8.x. Every solution file starts with exactly this first line:
  ```racket
  #lang racket/base
  ```
- The grader runs `racket code/1_q3.rkt` and `racket code/1_q4.rkt` after adding its own `define`s and calls to the end of the file. So every function must work when called from code appended below it, and the file must print nothing by itself.
- Only the built-ins in section 2 may be used, even though `racket/base` provides many more.

## 2. Allowed and banned built-ins
**Allowed (from the PDF's "Scheme rules"; nothing else):**
- Special forms: `define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`, `quote` (written `'`).
- Pairs and lists: `cons`, `car`, `cdr`, `list`, and every composition of `car` and `cdr` up to four levels (`caar`, `cadr`, `cdar`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, and so on).
- Predicates and lookup: `null?`, `pair?`, `eq?`, `assq`, `assoc`.
- Arithmetic and comparison: `+ - * < > <= >= =`, `max`.
- Output: `display`, `newline`.
- S2 only: `read`.

**Banned (never use, not even once, not even in a helper):**
- `set!` and every relative (`set-car!`, `set-cdr!`, `set-box!`, boxes, parameters).
- Vectors, hash tables, strings and string functions, characters, `format`, `printf`, `fprintf`, `write`, `print`, `displayln`.
- Loops: `do`, `for`, `for/list`, `for/fold` and every other `for` form.
- `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `memv`, `list-ref`, `list-tail`.
- Racket-only names: `first`, `second`, `rest`, `last`, `empty`, `empty?`, `cons?`, `when`, `unless`, `foldl`, `foldr`, `apply`, `andmap`, `ormap`, `for-each`, `void`, `min`, `abs`, `add1`, `sub1`, `zero?`, `else` outside `cond`, `case`, `match`, `define-values`, `values`, `error`.
- If a banned function is needed, write a helper named `my-something` (for example `my-length`, `my-reverse`, `my-append`) using only allowed built-ins.

## 3. Coding conventions
- Names are kebab-case: `tree-value`, `inorder-list`, `count-leaves`. Predicates end in `?` (`leaf?`, `empty-tree?`).
- Above every function, a comment gives its recursive reading: what it returns, the base case and the recursive case. Example:
  ```racket
  ;; (my-length lst) -> number of top-level elements of lst
  ;; Base case: () has length acc.
  ;; Recursive case: one more than the length of (cdr lst), counted in acc.
  (define (my-length lst)
    (let loop ((rest-lst lst) (acc 0))
      (if (null? rest-lst)
          acc
          (loop (cdr rest-lst) (+ acc 1)))))
  ```
- All state is passed through function arguments. No global mutable state, no `set!`.
- Use tail recursion with an accumulator where it is natural (list walks, counting, building a list in reverse traversal order). Tree walks that must visit both subtrees may recurse non-tail on one side; thread an accumulator through both calls instead of appending.
- Every `if` has both a then branch and an else branch. Use `cond` with a final `else` for three or more cases.
- Small helper functions are better than one long function. Put helpers directly above the function that uses them.

## 4. File rules
- The file contains only definitions (`define`) and comments.
- No top-level calls or expressions: no `(print-inorder t1)`, no test code, no `(define t1 ...)` example trees left in the file.
- Nothing is printed when the file loads: `racket code/1_q3.rkt` must produce no output at all.
- Every print function ends its output with `(newline)` as its last expression, so it returns `#<void>` from `newline`, which the module body does not echo, and the output ends with a newline as the PDF requires.
- Print exactly what is asked, using `display` (not `write`, so symbols and lists print without quotes): no prompts, labels, spaces or extra blank lines.

## 5. How to run and test
- Run every command from the repository's top folder.
- Load check (must print nothing):
  `racket code/1_q3.rkt`
- Try one call the way the grader does, by appending it to a throwaway copy of the file (the repo file never changes):
  ```bash
  (cat code/1_q3.rkt; echo "(print-inorder '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))") > /tmp/s1.rkt && racket /tmp/s1.rkt
  ```
- For S2 functions that read input, pipe the input in:
  ```bash
  (cat code/1_q4.rkt; echo "(print-insert-result)") > /tmp/s2.rkt && echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket /tmp/s2.rkt
  ```
- Tests are bash scripts under `tests/` (`tests/test_q3.sh`, `tests/test_q4.sh`), run as `bash tests/test_q3.sh`. For each test the script copies the code file to a temporary file, appends the test's defines and one call, runs `racket` on it, compares the output with the expected output, prints `PASS name` or `FAIL name` (with expected and actual output on failure) and ends with a count, exiting non-zero if anything failed.
- Each test script covers every example in the PDF plus our own edge cases: the empty list or tree, a single element or node, a one-sided (chain) structure, and for S2 the large inputs (depth 100, 10,000 elements).

## 6. Self-review checklist (go through every item before every answer)
1. Did I do only the one unit of work asked for?
2. Is the first line exactly `#lang racket/base`?
3. Scan every identifier in the code: is each one either defined in this file, a parameter or local name, or on the allowed list in section 2? Search specifically for `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`, `set!`, `first`, `rest`, `empty?`, `when`, `unless`, `foldl`, `foldr`, `apply`, `printf`, `format`, `string`, `vector`, `for`, `do`, `void`, `add1`, `sub1`, `zero?`.
4. Does every function have a comment with its recursive reading (base case, recursive case)?
5. Does every `if` have an else branch, and every `cond` end with `else`?
6. Is the empty list or empty tree handled, and does the base case come first?
7. Does every recursive call move toward a base case (a smaller list or subtree)?
8. Is all state passed through arguments, with no mutation?
9. Is recursion tail recursive with an accumulator where natural, and safe for 10,000-element lists and 100-level nesting?
10. Does the file contain only definitions, with no top-level calls and no output on load?
11. Does every print function use `display`, print exactly the required text, and end with `(newline)`?
12. Did I run it (append a call to a copy and run `racket`), or say clearly that I did not?

## 7. Known failure modes of AI tools in Scheme/Racket
- **Quietly using banned list functions.** AI tools reach for `length`, `append`, `reverse`, `map`, `filter`, `member` and `list-ref` out of habit. Replace them with accumulators or `my-` helpers.
- **Building traversals with `append`.** `(append (inorder l) (list v) (inorder r))` is both banned and quadratic. Thread an accumulator instead: walk the right subtree first, `cons` the value, then walk the left subtree with the result.
- **Accumulator producing reversed output.** Consing while walking left to right gives a backwards list. Either walk in reverse order (right before left) or build in reverse and fix it with a `my-reverse` helper, and test the order.
- **`if` without an else branch.** In Racket, `(if c x)` is a syntax error. Always give both branches or use `cond` with `else`.
- **Racket-only shortcuts.** `first`, `rest`, `empty?`, `empty`, `when`, `unless`, `foldl`, `apply`, `printf`, `add1`, `void` are not in the allowed list even though `racket/base` (or `racket`) has them.
- **Wrong handling of the empty list.** Calling `car` or `cadr` on `()` raises an error. Check `null?` first, and remember the empty tree `()` prints as `()`, has height 0 and has 0 leaves.
- **Confusing a leaf with an empty tree.** A leaf is a node `(v () ())`, not `()`.
- **Deep non-tail recursion.** A non-tail `my-length` or list walk over 10,000 elements builds a deep continuation. Racket CS usually survives this, but write list walks tail-recursively with an accumulator anyway.
- **Printing extra text.** Labels, spaces, a missing final `(newline)`, an extra blank line, or using `write`/`print` instead of `display` all break exact-output tests.
- **Leaving test calls in the file.** A top-level `(print-inorder t1)` or `(define t1 ...)` left in the file prints output on load or clashes with the grader's own `define`s.
- **Quoting mistakes.** `'(4 (2 () ()) ())` is data; `(4 (2 () ()) ())` without the quote tries to call 4 as a function.
- **Shadowing built-ins.** Naming a parameter `list` hides the `list` function inside that function. Use `lst`, `tree`, `acc` instead.
