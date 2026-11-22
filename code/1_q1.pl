:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
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

%% clue(+N, +Solution)
%  clue(N, S) is true when clue number N holds in the fully filled-in
%  solution S.

% CLUE 1: The friend who prefers the AI project does not work in research
% and is not Dana.
clue(1, S) :-
    member(p(_, _, _, 'AI'), S),
    \+ member(p(_, research, _, 'AI'), S),
    \+ member(p('Dana', _, _, 'AI'), S).

% CLUE 2: Alex does not work in development and does not prefer C++.
clue(2, S) :-
    member(p('Alex', _, _, _), S),
    \+ member(p('Alex', development, _, _), S),
    \+ member(p('Alex', _, 'c++', _), S).

% CLUE 3: The friend working in the testing department likes Python.
clue(3, S) :-
    member(p(_, testing, python, _), S).

% CLUE 4: Ben prefers web projects and does not work in testing.
clue(4, S) :-
    member(p('Ben', _, _, web), S),
    \+ member(p('Ben', testing, _, _), S).

% CLUE 5: The friend whose favorite language is Java works in the design
% department.
clue(5, S) :-
    member(p(_, design, java, _), S).

% CLUE 6: Carla's project preference is not embedded, and her department
% is not development.
clue(6, S) :-
    member(p('Carla', _, _, _), S),
    \+ member(p('Carla', _, _, embedded), S),
    \+ member(p('Carla', development, _, _), S).

% CLUE 7: Dana's favorite language is not Java, and she works in research
% or testing.
clue(7, S) :-
    member(p('Dana', Dept, _, _), S),
    \+ member(p('Dana', _, java, _), S),
    memberchk(Dept, [research, testing]).

% CLUE 8: The friend who prefers data projects works in research and does
% not use JavaScript.
clue(8, S) :-
    member(p(_, research, _, data), S),
    \+ member(p(_, _, javascript, data), S).    

% CLUE 9: The friend who works in the testing department prefers the AI project.
clue(9, S) :-
    member(p(_, testing, _, 'AI'), S).    

%% solve(-Solution)
%  solve(S) is true when S is a filled-in assignment of departments,
%  languages and projects that satisfies clues 1 to 8.
%  On backtracking it gives every such assignment.
solve(S) :-
    fill(S),
    maplist(holds_clue(S), [1, 2, 3, 4, 5, 6, 7, 8]).

%% holds_clue(+Solution, +N)
%  holds_clue(S, N) is true when clue number N holds in solution S.
holds_clue(S, N) :-
    clue(N, S).

%% count_solutions(+Active, -N)
%  count_solutions(Active, N) is true when N is the number of filled-in
%  solutions that satisfy every clue whose number is in Active, ignoring
%  all other clues.
count_solutions(Active, N) :-
    aggregate_all(count,
                  ( fill(S), maplist(holds_clue(S), Active) ),
                  N).    

%% main
%  main is true when the first solution of solve/1 has been printed as
%  four lines "Name = [Dept, Lang, Project]", in the order Alex, Ben,
%  Carla, Dana.
main :-
    once(solve(S)),
    maplist(print_person, S).

%% print_person(+Person)
%  print_person(P) is true when the p/4 term P has been printed as one
%  line "Name = [Dept, Lang, Project]" without quotes.
print_person(p(Name, Dept, Lang, Project)) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Project]).    
