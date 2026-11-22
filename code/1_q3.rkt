#lang racket/base

;; S1: Binary tree traversals.
;; A tree is either () or a three-element list (value left right).

;; (empty-tree? tree) -> #t when tree is the empty tree ().
;; Base case only: no recursion, just a null? test.
(define (empty-tree? tree)
  (null? tree))

;; (tree-value tree) -> the value at the root of a non-empty tree.
;; The value is the first element: (car tree).
(define (tree-value tree)
  (car tree))

;; (tree-left tree) -> the left subtree of a non-empty tree.
;; The left subtree is the second element: (cadr tree).
(define (tree-left tree)
  (cadr tree))

;; (tree-right tree) -> the right subtree of a non-empty tree.
;; The right subtree is the third element: (caddr tree).
(define (tree-right tree)
  (caddr tree))

;; (leaf? tree) -> #t when tree is a node whose left and right subtrees
;; are both empty. The empty tree is not a leaf.
(define (leaf? tree)
  (and (not (empty-tree? tree))
       (empty-tree? (tree-left tree))
       (empty-tree? (tree-right tree))))
