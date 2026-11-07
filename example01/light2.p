/**
 * Warranty & Liability
 * To the extent permitted by applicable law and unless explicitly
 * otherwise agreed upon, XLOG Technologies AG makes no warranties
 * regarding the provided information. XLOG Technologies AG assumes
 * no liability that any problems might be solved with the information
 * provided by XLOG Technologies AG.
 *
 * Rights & License
 * All industrial property rights regarding the information - copyright
 * and patent rights in particular - are the sole property of XLOG
 * Technologies AG. If the company was not the originator of some
 * excerpts, XLOG Technologies AG has at least obtained the right to
 * reproduce, change and translate the information.
 *
 * Reproduction is restricted to the whole unaltered document. Reproduction
 * of the information is only allowed for non-commercial uses. Selling,
 * giving away or letting of the execution of the library is prohibited.
 * The library can be distributed as part of your applications and libraries
 * for execution provided this comment remains unchanged.
 *
 * Restrictions
 * Only to be distributed with programs that add significant and primary
 * functionality to the library. Not to be distributed with additional
 * software intended to replace any components of the library.
 *
 * Trademarks
 * Jekejeke is a registered trademark of XLOG Technologies AG.
 */

/**
 * Scope of Mini-Mace4 v.0.2:
 * - baseline unit and pick
 * - speedup cell hash table
 */

:- ensure_loaded(library(hiord)).
:- ensure_loaded(library(util/hash)).
:- ensure_loaded(library(util/aggregate)).

% mccune(+List, +Integer, +Map, -Map)
mccune(L, N, I, O) :-
   hash_pairs(T, I),
   foldl(expand_axiom(N, T), L, H, []),
   find(H, N, T, M),
   hash_pairs(M, O).

% find(+List, +Integer, +Map, -Map)
find([], _, R, R) :- !.
find(L, N, R, S) :-
   cell(L, C, N, X),
   hash_add(R, C, X, T),
   foldl(reduce_axiom(T), L, H, []),
   find(H, N, T, S).

/************************************************************/
/* Pick Cell                                                */
/************************************************************/

% cell(+List, -Term, +Integer, -Integer)
cell(L, C, _, X) :-
   member(C = X, L), integer(X), is_cell(C), !.
cell(L, C, _, X) :-
   member(X = C, L), integer(X), is_cell(C), !.
cell(L, C, N, X) :-
   member(Y, L), pick_term(Y, C), !,
   M is N-1,
   between(0, M, X).

% pick_term(+Term, -Term)
pick_term(X, X) :-
   is_cell(X), !.
pick_term(X, T) :-
   X =.. [_|L],
   member(Y, L),
   pick_term(Y, T).

% is_cell(+Term)
is_cell(T) :-
   callable(T),
   T=.. [_|L],
   maplist(integer, L).

/************************************************************/
/* Goal Reduction                                           */
/************************************************************/

% reduce_axiom(+Map, +Goal, -List, +List)
reduce_axiom(M, E) -->
   {eval_axiom(M, E, F)},
   reduce_goal(F).

% reduce_goal(+Goal, -List, +List)
reduce_goal(X=Y) --> {X=Y}, !.
reduce_goal(X=Y) --> {integer(X), integer(Y)}, !, {fail}.
reduce_goal(X\=Y) --> {integer(X), integer(Y)}, !, {X\=Y}.
reduce_goal(G) --> [G].

/************************************************************/
/* Term Reduction                                           */
/************************************************************/

% eval_axiom(+Map, +Term, -Term)
eval_axiom(M, E, F) :-
   E =.. [P|L],
   maplist(eval_term(M), L, R),
   F =.. [P|R].

% eval_term(+Map, +Term, -Term)
eval_term(M, E, G) :-
   E =.. [P|L],
   maplist(eval_term(M), L, R),
   F =.. [P|R],
   eval_map(F, M, G).

% eval_map(+Term, +Map, -Term)
eval_map(F, M, G) :-
   hash_current(M, F, G), !.
eval_map(F, _, F).

/************************************************************/
/* Theory Grounding                                         */
/************************************************************/

% expand_axiom(+Integer, +Map, +Goal, -List, +List)
expand_axiom(N, I, X) -->
   {term_variables(X, L),
   findall(Y, (maplist(enum_var(N), L), eval_axiom(I, X, Y)), H)},
   foldl(reduce_goal, H).

% enum_var(+Integer, +Var)
enum_var(N, V) :-
   M is N-1,
   between(0, M, V).

/************************************************************/
/* Display Table                                            */
/************************************************************/

% show(+List, +Map)
show(L, T) :-
   member(F, L),
   get_dim(F, T, Q),
   show_head(F, Q),
   show_table(F, T, Q),
   fail.
show(L, T) :-
   member(F, L),
   get_dim(F, T, P, Q),
   show_head(F, Q),
   show_table(F, T, P, Q),
   fail.
show(_, _).

% show_table(+Atom, +Map, +Integer)
show_table(F, T, Q) :-
   write(' |'),
   between(0, Q, C),
   P =.. [F,C],
   (member(P-V, T) -> write(V); write('-')),
   write(' '),
   fail.
show_table(_, _, _) :-
   nl, nl.

% show_table(+Atom, +Map, +Integer, Integer)
show_table(F, T, P, Q) :-
   between(0, P, R),
   write(R), write('|'),
   show_row(F, Q, R, T),
   fail.
show_table(_, _, _, _) :-
   nl.

% show_head(+Atom, +Integer)
show_head(F, Q) :-
   write(F), write('|'),
   between(0, Q, C),
   write(C), write(' '),
   fail.
show_head(_, Q) :-
   nl, write('-+'),
   between(0, Q, _),
   write('--'),
   fail.
show_head(_, _) :-
   nl.

% show(+Atom, +Integer, +Integer, +Map)
show_row(F, Q, R, T) :-
   between(0, Q, C),
   P =.. [F,R,C],
   (member(P-V, T) -> write(V); write('-')),
   write(' '), fail.
show_row(_, _, _, _) :-
   nl.

% get_dim(+Atom, +Map, -Integer, -Integer)
get_dim(F, T, C) :-
   P =.. [F,A],
   aggregate_all((count, max(A)), member(P-_, T), (K,C)),
   K > 0.

% get_dim(+Atom, +Map, -Integer, -Integer)
get_dim(F, T, R, C) :-
   P =.. [F,A,B],
   aggregate_all((count, max(A),max(B)), member(P-_, T), (K,R,C)),
   K > 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dogelog Player 2.3.4 for Java

% ?- mccune([X * Y = Y * X * X, b * a \= a * b * a], 4, [], _G), show([*], _G).
% *|0 1 2 3
% -+--------
% 0|0 2 3 1
% 1|3 1 0 2
% 2|1 3 2 0
% 3|2 0 1 3
%
% true