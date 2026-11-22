:- use_module(library(lists)).
:- use_module(library(apply)).
%% dept(?Dept)
%  dept(D) is true when D is one of the four departments.
dept(research).
dept(development).
dept(design).
dept(testing).

%% lang(?Lang)
%  lang(L) is true when L is one of the four favorite languages.
lang(python).
lang(java).
lang('c++').
lang(javascript).

%% project(?Project)
%  project(P) is true when P is one of the four project preferences.
project('AI').
project(web).
project(embedded).
project(data).

%% template(-Solution)
%  template(S) is true when S is a list of four p(Name, Dept, Lang, Project)
%  terms for 'Alex', 'Ben', 'Carla' and 'Dana', in that order, with Dept,
%  Lang and Project not yet filled in.
template([p('Alex', _, _, _),
          p('Ben', _, _, _),
          p('Carla', _, _, _),
          p('Dana', _, _, _)]).
%% fill(-Solution)
%  fill(S) is true when S is the template with every Dept, Lang and Project
%  filled in so that each value of each attribute is used exactly once.
%  On backtracking it gives every such assignment.
fill(S) :-
    template(S),
    attribute_perm(dept, Depts),
    attribute_perm(lang, Langs),
    attribute_perm(project, Projects),
    maplist(set_attrs, S, Depts, Langs, Projects).

%% attribute_perm(+Attr, -Perm)
%  attribute_perm(A, P) is true when P is an ordering of all the values V
%  for which A(V) holds, e.g. all four departments in some order.
attribute_perm(Attr, Perm) :-
    findall(V, call(Attr, V), Values),
    permutation(Values, Perm).

%% set_attrs(?Person, ?Dept, ?Lang, ?Project)
%  set_attrs(P, D, L, Pr) is true when P is a p/4 term whose department,
%  language and project are D, L and Pr.
set_attrs(p(_, D, L, P), D, L, P).         