:- module(test_aux,
          [my_unary_pred/1,
           a_or_b/1,
           unify_with_iri/1,
           a/1,
           b/1,
           refl/2,
           recursive_subclass_of/2]).

:- use_module(library(semweb/rdf_db)).
:- rdf_register_prefix('','http://example.org/').

:- srule(my_unary_pred, [instance], 'demo predicate').
my_unary_pred(X) :- rdf(X,rdf:type,'':c1).

:- srule(recursive_subclass_of, [sub, super]).
recursive_subclass_of(X,Y) :- rdf(X,rdfs:subClassOf,Y).
recursive_subclass_of(X,Y) :- rdf(X,rdfs:subClassOf,Z),recursive_subclass_of(Z,Y).

% NOTE: for this to be expanded, both a/1 and b/1 need to be exported
a_or_b(X) :- a(X).
a_or_b(X) :- b(X).

a(X) :- rdf(X,rdf:type,'':a).
b(X) :- rdf(X,rdf:type,'':b).

unify_with_iri('http://x.org').

refl(A,B) :- rdf(A,'':r,B).
refl(A,B) :- rdf(B,'':r,A).

% awkward
refl(A,B) :- a(A),B=A.

%% TODO: allow this
%% refl(A,A) :- a(A).

