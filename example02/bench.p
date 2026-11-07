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

:- ensure_loaded(library(hiord)).
:- ensure_loaded(library(util/aggregate)).

:- [hard2].
:- [hard3].

% :- ['../example01/light'].
:- ['../example01/light2'].
% :- ['../example01/iter'].
:- ['../example01/iter2'].

/**
 * See also:
 * Mathematics Distillation Challenge, EQT01-000092
 * https://competition.sair.foundation/competitions
 */

% bench(+Integer, -Integer, -Integer, +Integer)
bench(K, O, N, M) :-
   aggregate_all((sum(A),sum(B)),
     (data(_, E, F, M),
      attempt(M, K, E, F, A, B)), (O,N)).

% attempt(+Integer, +Integer, +Term, +Term, -Integer, -Integer)
attempt(0, K, E, F, 1, 0) :-
   as_axiom(E, G, [], _),
   as_dual(F, H),
   J is K//4,
   between(1, J, N),
   mccune([G,H], N, [], _), !.
attempt(1, K, E, F, 1, 0) :-
   as_axiom(E, G, [], _),
   between(1, K, N),
   church([G,F], N, _), !.
attempt(_, _, _, _, 0, 1).

% as_axiom(+Term, +Term, +Map, -Map)
as_axiom(S, T, I, O) :- compound(S), !,
   S =.. [F|L],
   foldl(as_axiom, L, R, I, O),
   T =.. [F|R].
as_axiom(S, V, I, I) :- member(S-V, I), !.
as_axiom(S, V, I, [S-V|I]).

% as_dual(+Term, -Term)
as_dual(X = Y, X \= Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dogelog Player 2.3.4 for Java

% ?- time(bench(17,O,N,1)).
% % Zeit 8136.361 ms, Benutzer 100 %, Lips 30778 k
% O = 255, N = 40.

% ?- time(bench(17,O,N,0)).
% % Zeit 66601.298 ms, Benutzer 100 %, Lips 21709 k
% O = 252, N = 53.
