#!/usr/bin/env swipl


:- use_module(library(main)).
:- use_module(library(optparse)).
%:- use_module(library(semweb/rdf_db)).
:- use_module(library(option)).

:- use_module(library(semweb/rdf_library)).
:- use_module(library(semweb/rdf_http_plugin)).
:- use_module(library(semweb/rdf_cache)).
:- use_module(library(semweb/rdf11)).
:- use_module(library(semweb/rdfs)).
%:- rdf_attach_library('void.ttl').
:- use_module(library(sparqlprog/ontologies/owl), []).
:- use_module(library(sparqlprog/owl_util)).

:- multifile http:location/3.
:- dynamic   http:location/3.

http:location(root, '/', []).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/html_write)).

:- use_module(library(pengines)).

:- use_module(pengine_sandbox:library(sparqlprog)).
:- use_module(pengine_sandbox:library(sparqlprog/labelutils)).
:- use_module(pengine_sandbox:library(semweb/rdf11)).
:- use_module(library(sandbox)).
:- use_module(library(semweb/rdf11)).
:- use_module(library(semweb/rdf_sandbox)).

:- multifile sandbox:safe_primitive/1.
sandbox:safe_primitive(rdf11:rdf(_,_,_)).
sandbox:safe_primitive(rdf11:rdf_iri(_)).
sandbox:safe_primitive(sparqlprog:'??'(_,_)).
%sandbox:safe_primitive(clause(_,_,_)).


http:location(pldoc, root(documentation), [priority(100)]).


:- rdf_set_cache_options([ global_directory('RDF-Cache'),
                           create_global_directory(true)
                         ]).

:- use_module(library(sparqlprog)).
:- use_module(library(sparqlprog/labelutils)).
:- use_module(library(sparqlprog/endpoints)).
:- use_module(library(sparqlprog/ontologies/wikidata)).

%:- initialization prolog_ide(thread_monitor).
:- initialization debug(sparqlprog).
:- initialization debug.

tobjprop(X) :- writeln( hhhhii), debug( sparqlprog,'FOO',[]), '??'(go, rdf(X,rdf:type,owl:'ObjectProperty')).
tobjprop(zzz).

sandbox:safe_primitive(user:tobjprop(_)).


server :-
        getenv('PORT',PortAtom),
        atom_number(PortAtom,Port),
        server(Port).

server(Port) :-
        http_server(http_dispatch, [port(Port)]).
