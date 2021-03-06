
:- use_module(library(semweb/rdf11)).
:- use_module(library(sparqlprog)).
:- use_module(test_aux).

:- rdf_register_prefix(foaf,'http://xmlns.com/foaf/0.1/').
:- rdf_register_prefix('','http://example.org/').

:- begin_tests(basic_test).


test_select(Q,ExpectedSPARQL) :-
        test_select(Q,[],ExpectedSPARQL).
test_select(Q,Opts,ExpectedSPARQL) :-
        create_sparql_select(Q,Q,SPARQL,Opts),
        format(' ~q ==> ~w~n',[ Q, SPARQL ]),
        assertion( SPARQL = ExpectedSPARQL ).

test_construct(H,Q,ExpectedSPARQL) :-
        create_sparql_construct(H,Q,SPARQL,[]),
        format(' ~q :- ~q ==> ~w~n',[ H, Q, SPARQL ]),
        assertion( SPARQL = ExpectedSPARQL ).


test(bindings) :-
        Q=rdf(A,B,C),
        create_sparql_select(Q,Q,SPARQL,[bindings([a=A,b=B,c=C])]),
        assertion( SPARQL = "SELECT ?a ?b ?c WHERE {?a ?b ?c}" ).

test(simple_select) :-
        nl,
        test_select(rdf(_,_,_),"SELECT ?v0 ?v1 ?v2 WHERE {?v0 ?v1 ?v2}"),
        test_select(rdf(_,_,_,_),_),
        test_select(rdf(_,_,_,'':g1),_),
        true.

test(select_subset) :-
        nl,
        create_sparql_select(rdf(A,B,C),rdf(A,B,C),SPARQL1,[]),
        create_sparql_select(foo(A,B,C),rdf(A,B,C),SPARQL2,[]),
        assertion( SPARQL1 == SPARQL2 ),
        create_sparql_select(A,rdf(A,_,_),SPARQL3,[]),
        assertion( SPARQL3 = "SELECT ?v0 WHERE {?v0 ?v1 ?v2}" ),
        true.



test(conj) :-
        test_select( (rdf(S,'':p1,O),
                      rdf(S,'':p2,O)),
                     "SELECT ?v0 ?v1 WHERE {?v0 <http://example.org/p1> ?v1 . ?v0 <http://example.org/p2> ?v1}").

test(disj) :-
        test_select( (   rdf(S,'':p1,O)
                     ;   rdf(S,'':p2,O)),
                     "SELECT ?v0 ?v1 WHERE {{?v0 <http://example.org/p1> ?v1} UNION {?v0 <http://example.org/p2> ?v1}}").

test(negation) :-
        test_select( (rdf(S,'':p1,O),
                      \+ rdf(S,'':p2,O)),
                     "SELECT ?v0 ?v1 WHERE {?v0 <http://example.org/p1> ?v1 . FILTER NOT EXISTS {?v0 <http://example.org/p2> ?v1}}").

test(optional) :-
        test_select( (rdf(S,'':p1,_O),
                      optional(rdf(S,'':p2,_Z))),
                     "SELECT ?v0 ?v1 ?v2 WHERE {?v0 <http://example.org/p1> ?v1 . OPTIONAL {?v0 <http://example.org/p2> ?v2}}").

test(str_eq) :-
        test_select( (rdf(_S,rdfs:label,Label),
                      Label=="foo"),
                     "SELECT ?v0 ?v1 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#label> ?v1 . FILTER (?v1 = \"foo\")}").

test(str_eq2) :-
        test_select( rdf(_S,rdfs:label,"foo"),
                     "SELECT ?v0 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#label> ?v1 . FILTER (?v1 = \"foo\")}").

test(lang_literal_eq) :-
        test_select( rdf(_S,rdfs:label,"foo"@en),
                     "SELECT ?v0 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#label> \"foo\"@en}").

test(str_starts) :-
        test_select( (rdf(_S,rdfs:label,Label),
                      str_starts(Label,"foo")),
                     "SELECT ?v0 ?v1 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#label> ?v1 . FILTER (strStarts(?v1,\"foo\"))}").

test(construct) :-
        test_construct(rdf(O,P,S),rdf(S,P,O),_).

test(expand) :-
        test_select( my_unary_pred(_X),
                     "SELECT ?v0 WHERE {?v0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/c1>}").

test(recursive_expand_cycle) :-
        \+ catch(test_select( recursive_subclass_of(_,'':c1), _),
                 _,
                 fail).

% 
test(expand_with_unit_clause) :-
        test_select( (unify_with_iri(C),  % unit clause
                      rdf(_,rdf:type,C)),
                     "SELECT ?v0 WHERE {?v0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://x.org>}").

test(equals) :-
        test_select( (rdf(A,'':p1,X),
                      rdf(B,'':p1,X),
                      A==B),
                     "SELECT ?v0 ?v1 ?v2 WHERE {?v0 <http://example.org/p1> ?v1 . ?v2 <http://example.org/p1> ?v1 . FILTER (?v0 = ?v2)}").

test(not_equals) :-
        test_select( (rdf(A,'':p1,X),
                      rdf(B,'':p1,X),
                      A\=B),
                     "SELECT ?v0 ?v1 ?v2 WHERE {?v0 <http://example.org/p1> ?v1 . ?v2 <http://example.org/p1> ?v1 . FILTER (?v0 != ?v2)}").


test(expand_multi) :-
        test_select( a_or_b(_X),
                     "SELECT ?v0 WHERE {{?v0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/a>} UNION {?v0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/b>}}").

test(inject_labels) :-
        test_select( rdf(_A,rdf:type,'':c1),
                     [inject_labels(true)],
                     "SELECT ?v0 ?v1 WHERE {?v0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/c1> . OPTIONAL {?v0 <http://www.w3.org/2000/01/rdf-schema#label> ?v1}}").


test(rdf_path) :-
        test_select( rdf(_,zeroOrMore(rdfs:subClassOf),'':c1),
                     "SELECT ?v0 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#subClassOf>* <http://example.org/c1>}").


test(rdf_path2) :-
        test_select( rdf_path(_,zeroOrMore(rdfs:subClassOf),'':c1),
                     "SELECT ?v0 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#subClassOf>* <http://example.org/c1>}").

test(nofilter) :-
        test_select( (rdf(X,rdfs:label,L),
                      rdf(L,'http://www.bigdata.com/rdf/search#search',"foo")),
                     "SELECT ?v0 ?v1 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#label> ?v1 . ?v1 <http://www.bigdata.com/rdf/search#search> \"foo\"}").

test(arith) :-
        test_select( (rdf(X,'':v,V),
                      V2 is V/2),
                     "SELECT ?v0 ?v1 ?v2 WHERE {?v0 <http://example.org/v> ?v1 . BIND( (?v1 / 2) AS ?v2 )}").

%:- debug(sparqlprog).

%xxxtest(refl) :-
%        test_select( refl(_,_),
%                     "SELECT ?v0 ?v1 WHERE {?v0 <http://www.w3.org/2000/01/rdf-schema#label> ?v1 . ?v1 <http://www.bigdata.com/rdf/search#search> \"foo\"}").

test(agg) :-
        create_sparql_select(MaxVal,
                             aggregate(max(Val),rdf(_,'':v,Val),MaxVal),
                             SPARQL,
                             []),
        format(' Query ==> ~w~n',[ SPARQL ]),
        assertion( SPARQL = "SELECT ?v0 WHERE {SELECT max(?v1) AS ?v0 WHERE {?v2 <http://example.org/v> ?v1}}" ).


:- end_tests(basic_test).


