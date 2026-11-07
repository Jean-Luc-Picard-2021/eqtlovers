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

:- ensure_loaded(library(text/format)).

% :- [iter].
:- [iter2].
% :- [light].
:- [light2].

% bench(+Integer, +Integer)
bench(K, R) :-
   data(I, E, F, R),
   attempt(K, E, F, I, R),
   fail.
bench(_, _).

% attempt(+Integer, +Term, +Term, +Atom, +Integer)
attempt(K, E, F, I, 1) :-
   as_axiom(E, G, [], _),
   between(1, K, N),
   church([G,F], N, R), !,
   format('-- ~w proof ~d --~n', [I, N]),
   list(R).
attempt(K, E, F, I, 0) :-
   as_axiom(E, G, [], _),
   as_dual(F, H),
   J is K//4,
   between(1, J, N),
   mccune([G,H], N, [], R), !,
   format('-- ~w no proof ~d --~n', [I, N]),
   show([*], R).
attempt(_, _, _, I, _) :-
   format('-- ~w gave up --~n', [I]).

% as_axiom(+Term, +Term, +Map, -Map)
as_axiom(S, T, I, O) :- compound(S), !,
   S =.. [F|L],
   foldl(as_axiom, L, R, I, O),
   T =.. [F|R].
as_axiom(S, V, I, I) :- member(S-V, I), !.
as_axiom(S, V, I, [S-V|I]).

% as_dual(+Term, -Term)
as_dual(X = Y, X \= Y).

/* https://competition.sair.foundation/competitions */
data(4164-3927, x*y = y*y*x*x, x*y = x*(y*y)*x, 0).

/* https://arxiv.org/abs/2512.07087v2 */
data(3973-4023, x * y = (y * (z * x)) * z, x * y = (z * (z * x)) * y, 1).

/* https://competition.sair.foundation/competitions */
data(4208-3879, x * y = z * y * x * x, x * x = y * (x * x) * z, 1).

/* https://arxiv.org/abs/2605.21200v1 */
data(650-448, x = x * (y * ((z * x) * y)), x = x * (y * (z * (x * z))), 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dogelog Player 2.3.4 for Java

% ?- time(bench(17,0)).
% -- 4164-3927 no proof 4 --
% *|0 1 2 3
% -+--------
% 0|0 2 3 1
% 1|3 1 0 2
% 2|1 3 2 0
% 3|2 0 1 3
%
% % Zeit 306.949 ms, Benutzer 100 %, Lips 21282 k
% true.

% ?- time(bench(17,1)).
% -- 3973-4023 proof 12 --
%   1. x*y                                                    [], -
%   2. y*(x*(A*z)*x)*(x*(A*z))                                [], l(1)
%   3. y*(x*(z*(x*(A*z)*A)*(x*(A*z)))*(z*(x*(A*z)*A)))*(x*(A*z))[1, 2], l(1)
%   4. y*(x*(A*z)*(z*(x*(A*z)*A)))*(x*(A*z))                  [1, 2, 1, 2], r(1)
%   5. z*(x*(A*z)*A)*y                                        [], r(1)
%   6. z*(z*x)*y                                              [1, 2], r(1)
% -- 4208-3879 proof 14 --
%   1. x*x                                                    [], -
%   2. A*z*x*x*x*x                                            [], l(1)
%   3. y*(x*x)*x*(A*z*x*x*x)*(A*z*x*x*x)                      [], l(1)
%   4. B*x*(y*(x*x))*(y*(x*x))*(A*z*x*x*x)*(A*z*x*x*x)        [1, 1], l(1)
%   5. A*z*x*x*x*(y*(x*x))                                    [], r(1)
%   6. C*(y*(x*x))*x*x*(A*z*x*x)*(A*z*x*x)*(y*(x*x))          [1], l(1)
%   7. x*(y*(x*x))*(A*z*x*x)*(A*z*x*x)*(y*(x*x))              [1, 1, 1], r(1)
%   8. A*z*x*x*(y*(x*x))*(y*(x*x))                            [1], r(1)
%   9. x*z*(y*(x*x))*(y*(x*x))                                [1, 1], r(1)
%  10. y*(x*x)*z                                              [], r(1)
% -- 650-448 gave up --
% % Zeit 77.025 ms, Benutzer 100 %, Lips 15154 k
% true.