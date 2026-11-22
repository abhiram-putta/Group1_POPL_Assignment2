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