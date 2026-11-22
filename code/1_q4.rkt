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

;; (sublist? e) -> #t if e is a list (empty or not), #f if e is an atom
;; No recursion: () and pairs are lists, everything else is an atom.
(define (sublist? e)
  (or (null? e) (pair? e)))

;; (insert-if-short x lst n) -> lst with x put at the front of every list
;;   (lst itself and every nested list, () included) whose original length < n
;; Base case: an atom element is returned unchanged; () has no elements, so
;;   my-map gives () and x is added if 0 < n.
;; Recursive case: rebuild each sublist element with insert-if-short (smaller
;;   structure), keep atoms; then cons x on the front if (my-length lst) < n,
;;   where lst is the original, not the rebuilt list.
(define (insert-if-short x lst n)
  (let ((new-lst (my-map (lambda (e)
                           (if (sublist? e)
                               (insert-if-short x e n)
                               e))
                         lst)))
    (if (< (my-length lst) n)
        (cons x new-lst)
        new-lst)))

;; (print-insert-result) -> reads x, lst, n from standard input (in that
;;   order), displays (insert-if-short x lst n) and ends with a newline.
;; No recursion: let* forces the three reads to happen in order.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))

;; (make-inserter x len-ok?) -> a function (insert lst) that returns lst with
;;   x put at the front of every list (lst itself and every nested list,
;;   () included) whose original length satisfies len-ok?
;; insert's base case: an atom element is returned unchanged; () has no
;;   elements, so my-map gives () and x is added if (len-ok? 0).
;; insert's recursive case: rebuild each sublist element with insert (smaller
;;   structure), keep atoms; then cons x on the front if (len-ok? (my-length
;;   lst)), measured on the original lst, not the rebuilt list.
(define (make-inserter x len-ok?)
  (letrec ((insert
            (lambda (lst)
              (let ((new-lst (my-map (lambda (e)
                                       (if (sublist? e)
                                           (insert e)
                                           e))
                                     lst)))
                (if (len-ok? (my-length lst))
                    (cons x new-lst)
                    new-lst)))))
    insert))


