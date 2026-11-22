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

;; (inorder-acc tree acc) -> the inorder list of tree followed by acc.
;; Base case: the empty tree adds nothing, so the result is acc.
;; Recursive case: first put the right subtree's inorder list in front of
;; acc, then cons the node's value in front of that, then put the left
;; subtree's inorder list in front of everything. Walking right before left
;; means each cons adds to the front and the final list is in order,
;; with no append.
(define (inorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (inorder-acc (tree-left tree)
                   (cons (tree-value tree)
                         (inorder-acc (tree-right tree) acc)))))

;; (inorder-list tree) -> list of the values of tree in inorder
;; (left subtree, node, right subtree). Starts the accumulator at ().
(define (inorder-list tree)
  (inorder-acc tree '()))

;; (print-inorder tree) displays the inorder list of tree on one line,
;; then a newline. The empty tree prints ().
(define (print-inorder tree)
  (display (inorder-list tree))
  (newline))

;; (preorder-acc tree acc) -> the preorder list of tree followed by acc.
;; Base case: the empty tree adds nothing, so the result is acc.
;; Recursive case: the right subtree's preorder list goes in front of acc,
;; then the left subtree's in front of that, and the node's value is
;; consed at the very front (node, left, right).
(define (preorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (cons (tree-value tree)
            (preorder-acc (tree-left tree)
                          (preorder-acc (tree-right tree) acc)))))

;; (preorder-list tree) -> list of the values of tree in preorder
;; (node, left subtree, right subtree). Starts the accumulator at ().
(define (preorder-list tree)
  (preorder-acc tree '()))

;; (postorder-acc tree acc) -> the postorder list of tree followed by acc.
;; Base case: the empty tree adds nothing, so the result is acc.
;; Recursive case: the node's value is consed onto acc first (it comes
;; last), then the right subtree's postorder list goes in front of it,
;; then the left subtree's (left, right, node).
(define (postorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (postorder-acc (tree-left tree)
                     (postorder-acc (tree-right tree)
                                    (cons (tree-value tree) acc)))))

;; (postorder-list tree) -> list of the values of tree in postorder
;; (left subtree, right subtree, node). Starts the accumulator at ().
(define (postorder-list tree)
  (postorder-acc tree '()))

;; (print-all-traversals tree) displays three lines: the inorder list,
;; the preorder list and the postorder list of tree, each followed by a
;; newline. Reuses the three list functions; no recursion of its own.
(define (print-all-traversals tree)
  (display (inorder-list tree))
  (newline)
  (display (preorder-list tree))
  (newline)
  (display (postorder-list tree))
  (newline))
