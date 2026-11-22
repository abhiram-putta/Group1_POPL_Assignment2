:- use_module(library(lists)).

%% split_list(+List, ?Left, ?Right)
%  split_list(L, Left, Right) is true when Left and Right are both non-empty
%  and append(Left, Right, L) holds, i.e. L is cut at position j with
%  1 =< j < length(L), keeping the original order. On backtracking it gives
%  every cut, from the shortest Left to the longest. Fails for lists of
%  length 0 or 1.
split_list([X|Xs], [X|Left0], [R|Rs]) :-
    append(Left0, [R|Rs], Xs).

%% expr(+Numbers, -Tree, -Value)
%  expr(Ns, T, V) is true when T is an expression tree that uses every number
%  of the non-empty list Ns exactly once, in order, joined by + - * /, and V
%  is the integer value of T. Every division in T has a non-zero divisor and
%  is exact. On backtracking it gives every such tree once. Fails for [].
expr([N], N, N).
expr([A,B|Ns], Tree, Value) :-
    split_list([A,B|Ns], Left, Right),
    expr(Left, LTree, LValue),
    expr(Right, RTree, RValue),
    join_trees(LTree, LValue, RTree, RValue, Tree, Value).

%% join_trees(+LTree, +LValue, +RTree, +RValue, -Tree, -Value)
%  join_trees(LT, LV, RT, RV, T, V) is true when T is LT Op RT for an
%  operator Op in + - * /, and V is LV Op RV. The / case holds only when RV
%  is non-zero and divides LV exactly; this is tested before any division
%  is done, so it never raises an error.
join_trees(LT, LV, RT, RV, LT+RT, V) :- V is LV + RV.
join_trees(LT, LV, RT, RV, LT-RT, V) :- V is LV - RV.
join_trees(LT, LV, RT, RV, LT*RT, V) :- V is LV * RV.
join_trees(LT, LV, RT, RV, LT/RT, V) :-
    RV =\= 0,
    LV mod RV =:= 0,
    V is LV // RV.

%% expr_string(+Tree, -String)
%  expr_string(T, S) is true when S is the canonical string, with no spaces,
%  of the expression tree T (integers at the leaves, + - * / inside). A left
%  operand is bracketed only if its precedence is lower than its parent's; a
%  right operand is bracketed if its precedence is the same or lower. A
%  number is never bracketed.
expr_string(Tree, String) :-
    (   integer(Tree)
    ->  number_string(Tree, String)
    ;   binary_parts(Tree, Op, L, R),
        op_prec(Op, P),
        operand_string(left, L, P, LS),
        operand_string(right, R, P, RS),
        format(string(String), "~w~w~w", [LS, Op, RS])
    ).

%% binary_parts(+Tree, -Op, -Left, -Right)
%  binary_parts(T, Op, L, R) is true when T is the binary term L Op R for
%  Op in + - * /.
binary_parts(L+R, +, L, R).
binary_parts(L-R, -, L, R).
binary_parts(L*R, *, L, R).
binary_parts(L/R, /, L, R).

%% op_prec(?Op, ?Prec)
%  op_prec(Op, P) is true when P is the binding strength of operator Op:
%  1 for + and -, 2 for * and /.
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

%% tree_prec(+Tree, -Prec)
%  tree_prec(T, P) is true when P is the precedence of T's top operator, or
%  3 if T is a number (higher than any operator, so it is never bracketed).
tree_prec(Tree, Prec) :-
    (   integer(Tree)
    ->  Prec = 3
    ;   binary_parts(Tree, Op, _, _),
        op_prec(Op, Prec)
    ).

%% operand_string(+Side, +Tree, +ParentPrec, -String)
%  operand_string(Side, T, PP, S) is true when S is the string of operand T
%  on Side (left or right) of an operator with precedence PP, bracketed when
%  needs_parens/3 says so.
operand_string(Side, Tree, ParentPrec, String) :-
    expr_string(Tree, S0),
    tree_prec(Tree, Prec),
    (   needs_parens(Side, Prec, ParentPrec)
    ->  format(string(String), "(~w)", [S0])
    ;   String = S0
    ).

%% needs_parens(+Side, +Prec, +ParentPrec)
%  needs_parens(Side, P, PP) is true when an operand of precedence P on Side
%  of a parent with precedence PP must be bracketed: left when P < PP,
%  right when P =< PP.
needs_parens(left, Prec, ParentPrec) :- Prec < ParentPrec.
needs_parens(right, Prec, ParentPrec) :- Prec =< ParentPrec.

%% generate_equation(+List, -Equation)
%  generate_equation(L, E) is true when E is a string "Left=Right" with no
%  spaces, where Left is an expression over a non-empty prefix of L, Right
%  is an expression over the remaining non-empty suffix, and both have the
%  same integer value. On backtracking it gives every valid equation once.
%  Fails, without error, if there is none (including lists of length 0 or 1).
generate_equation(List, Equation) :-
    split_list(List, Left, Right),
    expr(Left, LTree, Value),
    expr(Right, RTree, RValue),
    Value =:= RValue,
    expr_string(LTree, LString),
    expr_string(RTree, RString),
    format(string(Equation), "~w=~w", [LString, RString]).

%% all_equations(+List, -Equations)
%  all_equations(L, Es) is true when Es is the list of all valid equation
%  strings for L (as given by generate_equation/2), without duplicates and
%  in standard order of terms. Es = [] if there are none.
all_equations(List, Equations) :-
    findall(Equation, generate_equation(List, Equation), All),
    sort(All, Equations).

%% count_equations(+List, -N)
%  count_equations(L, N) is true when N is the number of valid equations
%  for L, i.e. the length of the list given by all_equations(L, Es).
count_equations(List, N) :-
    all_equations(List, Equations),
    length(Equations, N).