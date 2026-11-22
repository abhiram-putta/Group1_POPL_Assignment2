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


;; (my-reverse lst) -> the top-level elements of lst in reverse order
;; Base case: () gives acc (acc starts as ()).
;; Recursive case: cons (car lst) onto acc and reverse (cdr lst) into it.
;; Tail recursive.
(define (my-reverse lst)
  (let loop ((rest-lst lst) (acc '()))
    (if (null? rest-lst)
        acc
        (loop (cdr rest-lst) (cons (car rest-lst) acc)))))

;; (my-map f lst) -> list of (f e) for each top-level element e of lst, same order
;; Base case: () gives (my-reverse acc), the results put back in order.
;; Recursive case: cons (f (car lst)) onto acc and map over (cdr lst).
;; Tail recursive: acc is built backwards, then reversed once at the end.
(define (my-map f lst)
  (let loop ((rest-lst lst) (acc '()))
    (if (null? rest-lst)
        (my-reverse acc)
        (loop (cdr rest-lst) (cons (f (car rest-lst)) acc)))))

        