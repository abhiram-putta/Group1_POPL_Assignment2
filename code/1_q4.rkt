#lang racket/base

;; (my-length lst) -> number of top-level elements of lst
;; Sublists count as one element each; nested elements are not counted.
;; Base case: () has length acc (acc starts at 0).
;; Recursive case: one more than the length of (cdr lst), counted in acc.
;; Tail recursive, so 10,000-element lists use constant stack.
(define (my-length lst)
  (let loop ((rest-lst lst) (acc 0))
    (if (null? rest-lst)
        acc
        (loop (cdr rest-lst) (+ acc 1)))))
        