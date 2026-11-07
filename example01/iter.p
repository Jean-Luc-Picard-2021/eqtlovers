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
 * Scope of Mini-Prover9 v.0.1:
 * - baseline heuristic deepening
 */

:- ensure_loaded(library(hiord)).
:- ensure_loaded(library(cyclic)).
:- ensure_loaded(library(text/format)).

% rule(-Integer, -Term, -Term)
:- dynamic(rule/3).

% church(+List, +Integer, -Pair)
church(L, M, [([],-)-T|E]) :-
   append(R, [T=S], L),
   retractall(rule(_,_,_)),
   foldl(make, R, 0, _),
   find(T, S, 0, M, E).

% find(+Term, +Term, +Integer, +Integer, +List)
find(T, T, _, _, []).
find(T, S, K, M, [(P,Q)-H|E]) :-
   J is K+1,
   rewrite(T, H, P, Q),
   heuristic(H, S, J, N),
   N < M,
   find(H, S, J, M, E).

/************************************************************/
/* Term Rewriting                                           */
/************************************************************/

% make(+Pair, +Integer, -Integer)
make(E = F, N, M) :-
   M is N+1,
   assertz(rule(M, E, F)).

% rewrite(+Term, -Term, -List, -Term)
rewrite(T, S, [], l(K)) :- nonvar(T),
   rule(K, T, S), acyclic_term(T).
rewrite(T, S, [], r(K)) :- nonvar(T),
   rule(K, S, T), acyclic_term(T).
rewrite(T, S, P, Q) :- compound(T),
   T =.. [F|L],
   rewrite_list(L, R, 1, P, Q),
   S =.. [F|R].

% rewrite_list(+List, -List, +Integer, -List, -Term)
rewrite_list([X|L], [Y|L], I, [I|P], Q) :-
   rewrite(X, Y, P, Q).
rewrite_list([X|L], [X|R], I, P, Q) :-
   J is I+1,
   rewrite_list(L, R, J, P, Q).

/************************************************************/
/* Cost Estimate                                            */
/************************************************************/

% heuristic(+Term, +Term, +Integer, -Integer)
heuristic(T, S, N, C) :-
   H is N*2,
   heuristic_terms(T, S, H, J),
   C is J//2.

% heuristic_terms(+Term, +Term, +Integer, -Integer)
heuristic_terms(T, S, I, O) :- compound(T), compound(S),
   functor(T, F, N),
   functor(S, G, M),
   F/N == G/M, !,
   T =.. [_|L],
   S =.. [_|R],
   foldl(heuristic_terms, L, R, I, O).
heuristic_terms(T, S, I, I) :- compound(T), compound(S), !.
heuristic_terms(T, S, I, I) :- S == T, !.
heuristic_terms(T, S, I, O) :-
   heuristic_term(T, I, H),
   heuristic_term(S, H, O).

% heuristic_term(+Term, +Integer, -Integer)
heuristic_term(T, I, O) :- compound(T), !,
   T =.. [_|L],
   H is I+1,
   foldl(heuristic_term, L, H, O).
heuristic_term(_, I, O) :-
   O is I+1.

/************************************************************/
/* Display Proof                                            */
/************************************************************/

% list(+List)
list(L) :-
   numbervars(L, 0, _),
   foldl(list_step, L, 0, _).

% list_step(+Pair, +Integer, -Integer)
list_step(A-H, I, O) :-
   O is I+1,
   format('~t~d. ~5|~q~60|~w', [O,H,A]), nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dogelog Player 2.3.4 for Java

% ?- church([X * X = Y * (X * Y), a * a = (a * a) * (a * a)], 6, _G), list(_G).
%   1. a*a                                                    [], -
%   2. a*a*(a*(a*a))                                          [], l(1)
%   3. a*a*(a*a)                                              [2], r(1)
% true
