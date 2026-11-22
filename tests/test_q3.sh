#!/usr/bin/env bash
# Tests for S1 (binary tree traversals), code/1_q3.rkt.
# Run from the repo root: bash tests/test_q3.sh
# Each test copies the code file to a temporary file, appends the tree
# define and one call (the way the grader does), runs racket and compares
# the output with the expected output.

CODE="code/1_q3.rkt"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/test_q3.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

pass=0
fail=0

# check NAME EXPECTED ACTUAL
check() {
  if [ "$2" == "$3" ]; then
    echo "PASS $1"
    pass=$((pass + 1))
  else
    echo "FAIL $1"
    echo "  expected: $(printf '%s' "$2" | sed -n '1h;1!H;${x;s/\n/ | /g;p}')"
    echo "  actual:   $(printf '%s' "$3" | sed -n '1h;1!H;${x;s/\n/ | /g;p}')"
    fail=$((fail + 1))
  fi
}

# run_case NAME TREE CALL EXPECTED
# TREE is a quoted tree, e.g. '(5 () ()). CALL uses the name t.
run_case() {
  local file="$TMP_DIR/case.rkt"
  { cat "$CODE"; echo; echo "(define t $2)"; echo "$3"; } > "$file"
  local actual
  actual="$(racket "$file" 2>&1 | tr -d '\r')"
  check "$1" "$4" "$actual"
}

T1="'(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ())))"
T2="'(1 () (2 () (3 () ())))"
T3="'(a (b () ()) (c () ()))"
EMPTY="'()"
SINGLE="'(5 () ())"
LEFT_CHAIN="'(3 (2 (1 () ()) ()) ())"

NL=$'\n'

# --- Examples from the PDF ---
run_case "t1 print-inorder" "$T1" "(print-inorder t)" "(1 2 3 4 5 6 7)"
run_case "t1 print-all-traversals" "$T1" "(print-all-traversals t)" \
  "(1 2 3 4 5 6 7)${NL}(4 2 1 3 6 5 7)${NL}(1 3 2 5 7 6 4)"
run_case "t1 print-height-and-leaves" "$T1" "(print-height-and-leaves t)" "(3 4)"

run_case "t2 print-inorder" "$T2" "(print-inorder t)" "(1 2 3)"
run_case "t2 print-all-traversals" "$T2" "(print-all-traversals t)" \
  "(1 2 3)${NL}(1 2 3)${NL}(3 2 1)"
run_case "t2 print-height-and-leaves" "$T2" "(print-height-and-leaves t)" "(3 1)"

run_case "t3 print-inorder" "$T3" "(print-inorder t)" "(b a c)"
run_case "t3 print-all-traversals" "$T3" "(print-all-traversals t)" \
  "(b a c)${NL}(a b c)${NL}(b c a)"
run_case "t3 print-height-and-leaves" "$T3" "(print-height-and-leaves t)" "(2 2)"

run_case "empty print-inorder" "$EMPTY" "(print-inorder t)" "()"
run_case "empty print-all-traversals" "$EMPTY" "(print-all-traversals t)" \
  "()${NL}()${NL}()"
run_case "empty print-height-and-leaves" "$EMPTY" "(print-height-and-leaves t)" "(0 0)"

# --- Our own edge cases ---
run_case "single node print-inorder" "$SINGLE" "(print-inorder t)" "(5)"
run_case "single node print-all-traversals" "$SINGLE" "(print-all-traversals t)" \
  "(5)${NL}(5)${NL}(5)"
run_case "single node print-height-and-leaves" "$SINGLE" "(print-height-and-leaves t)" "(1 1)"

run_case "left chain print-inorder" "$LEFT_CHAIN" "(print-inorder t)" "(1 2 3)"
run_case "left chain print-all-traversals" "$LEFT_CHAIN" "(print-all-traversals t)" \
  "(1 2 3)${NL}(3 2 1)${NL}(1 2 3)"
run_case "left chain print-height-and-leaves" "$LEFT_CHAIN" "(print-height-and-leaves t)" "(3 1)"

# --- File rules ---
check "first line is #lang racket/base" "#lang racket/base" "$(head -n 1 "$CODE" | tr -d '\r')"
check "loading the file prints nothing" "" "$(racket "$CODE" 2>&1 | tr -d '\r')"

echo
echo "$pass passed, $fail failed, $((pass + fail)) total"
[ "$fail" -eq 0 ]
