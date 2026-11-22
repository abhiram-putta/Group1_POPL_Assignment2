#!/usr/bin/env bash
# Tests for S2 (code/1_q4.rkt). Run from the repo root:  bash tests/test_q4.sh
# Each test copies the code file to a temp file, appends one call (like the
# grader does), runs racket, and compares the exact output (including the
# final newline) with the expected output.

CODE="code/1_q4.rkt"
TIME_LIMIT=10   # seconds per test; stress tests must finish well inside this

if [ ! -f "$CODE" ]; then
  echo "ERROR: $CODE not found (run from the repo root)"
  exit 2
fi

TMPDIR_T=$(mktemp -d)
trap 'rm -rf "$TMPDIR_T"' EXIT

pass=0
fail=0

# report NAME EXPECTED_FILE ACTUAL_FILE STATUS ELAPSED
report() {
  local name="$1" exp="$2" act="$3" status="$4" elapsed="$5"
  if [ "$status" -eq 124 ]; then
    echo "FAIL $name (timed out after ${TIME_LIMIT}s)"
    fail=$((fail + 1))
  elif cmp -s "$exp" "$act"; then
    echo "PASS $name (${elapsed}s)"
    pass=$((pass + 1))
  else
    echo "FAIL $name"
    if [ "$(wc -c < "$exp")" -gt 300 ]; then
      echo "  expected (first 300 chars): $(head -c 300 "$exp")"
      echo "  actual   (first 300 chars): $(head -c 300 "$act")"
    else
      echo "  expected: $(cat "$exp")"
      echo "  actual:   $(cat "$act")"
    fi
    fail=$((fail + 1))
  fi
}

# run_test NAME CALL STDIN EXPECTED
#   CALL     Racket code appended to the copy of the file
#   STDIN    text piped to racket ("" for none)
#   EXPECTED expected stdout, without the final newline (one is added)
run_test() {
  local name="$1" call="$2" input="$3" expected="$4"
  local src="$TMPDIR_T/t.rkt" exp="$TMPDIR_T/exp" act="$TMPDIR_T/act"
  { cat "$CODE"; printf '\n%s\n' "$call"; } > "$src"
  printf '%s\n' "$expected" > "$exp"
  local start end status
  start=$(date +%s%N)
  printf '%s\n' "$input" | timeout "$TIME_LIMIT" racket "$src" > "$act" 2>&1
  status=$?
  end=$(date +%s%N)
  local ms=$(( (end - start) / 1000000 ))
  report "$name" "$exp" "$act" "$status" "$((ms / 1000)).$(printf '%03d' $((ms % 1000)))"
}

# ---------- 0. loading the file prints nothing ----------
act0="$TMPDIR_T/load_out"
timeout "$TIME_LIMIT" racket "$CODE" > "$act0" 2>&1
st=$?
if [ "$st" -eq 0 ] && [ ! -s "$act0" ]; then
  echo "PASS load-prints-nothing"
  pass=$((pass + 1))
else
  echo "FAIL load-prints-nothing (exit $st)"
  echo "  output: $(cat "$act0")"
  fail=$((fail + 1))
fi

# ---------- 1. print-insert-result, PDF examples (stdin) ----------
run_test "pdf-ex1" "(print-insert-result)" \
  "42 ((1 2) (3 4 5) (6) ()) 3" \
  "((42 1 2) (3 4 5) (42 6) (42))"

run_test "pdf-ex2" "(print-insert-result)" \
  "0 (((1) 2) (3) ((4 5 6) ())) 3" \
  "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))"

run_test "pdf-ex3-empty-n3" "(print-insert-result)" \
  "7 () 3" \
  "(7)"

run_test "pdf-ex4-empty-n0" "(print-insert-result)" \
  "7 () 0" \
  "()"

# ---------- 2. direct calls (no print-insert-result, so no stdin wait) ----------
run_test "my-length-mixed" \
  "(display (my-length '(a (b c) ()))) (newline)" "" \
  "3"

run_test "my-length-empty" \
  "(display (my-length '())) (newline)" "" \
  "0"

run_test "my-map-add1" \
  "(display (my-map (lambda (v) (+ v 1)) '(1 2 3))) (newline)" "" \
  "(2 3 4)"

run_test "make-inserter-gt2" \
  "(display ((make-inserter 'z (lambda (k) (> k 2))) '((1 2) (3 4 5) (6) ()))) (newline)" "" \
  "(z (1 2) (z 3 4 5) (6) ())"

# ---------- 3. stress tests ----------
# 3a. 100 levels deep: (((...(1)...))) with x = a, n = 2.
#     Every list has length 1 < 2, so a goes in at every level:
#     (a (a (a ... (a 1) ...)))
open=""; close=""; exp_open=""
for _ in $(seq 1 100); do
  open="${open}("
  close="${close})"
  exp_open="${exp_open}(a "
done
run_test "stress-depth-100" "(print-insert-result)" \
  "a ${open}1${close} 2" \
  "${exp_open}1${close}"

# 3b. flat list 1..10000
nums=$(seq -s ' ' 1 10000)

#     n = 5: length 10000 is not < 5, so the list is unchanged
run_test "stress-flat-10000-n5" "(print-insert-result)" \
  "q (${nums}) 5" \
  "(${nums})"

#     n = 10001: length 10000 < 10001, so q goes in front
run_test "stress-flat-10000-n10001" "(print-insert-result)" \
  "q (${nums}) 10001" \
  "(q ${nums})"

# ---------- summary ----------
echo "----"
echo "$pass passed, $fail failed, $((pass + fail)) total"
[ "$fail" -eq 0 ]
