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