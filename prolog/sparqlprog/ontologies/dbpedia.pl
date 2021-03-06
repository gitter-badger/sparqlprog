/*

expose a subclass of dbpedia for demo purposes

  For complete ontology use rdfs2pl

  
  
*/

:- module(dbpedia,
          [person/1,
           musical_artist/1,
           photographer/1,
           disease/1,

           child/2,
           has_director/2,
           directed/2,
           band_member/2,
           has_name/2]).

:- use_module(library(sparqlprog)).
:- use_module(library(semweb/rdf11)).

:- sparql_endpoint( dbp, 'http://dbpedia.org/sparql/').

:- rdf_register_prefix(foaf,'http://xmlns.com/foaf/0.1/').
:- rdf_register_prefix(dbo,'http://dbpedia.org/ontology/').
:- rdf_register_prefix(dbr,'http://dbpedia.org/resource/').

person(Person) :- rdf(Person,rdf:type,foaf:'Person').
has_name(S,L) :- rdf(S,foaf:'Name',L).

has_director(S,O) :- rdf(S,dbont:director,O).
directed(S,O) :- rdf(O,dbont:director,S).
child(S,O) :- rdf(S,dbont:child,O).

band_member(S,O) :- rdf(S,dbont:bandMember,O).


related_to(S,O) :- child(S,O).
related_to(S,O) :- child(O,S).


photographer(X) :- rdf(X,rdf:type,dbont:'Photographer').
musical_artist(X) :- rdf(X,rdf:type,dbont:'MusicalArtist').

disease(X) :- rdf(X,rdf:type,dbont:'Disease').
