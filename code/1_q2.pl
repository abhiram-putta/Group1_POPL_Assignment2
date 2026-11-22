:- use_module(library(lists)).

%% split_list(+List, ?Left, ?Right)
%  split_list(L, Left, Right) is true when Left and Right are both non-empty
%  and append(Left, Right, L) holds, i.e. L is cut at position j with
%  1 =< j < length(L), keeping the original order. On backtracking it gives
%  every cut, from the shortest Left to the longest. Fails for lists of
%  length 0 or 1.
split_list([X|Xs], [X|Left0], [R|Rs]) :-
    append(Left0, [R|Rs], Xs).