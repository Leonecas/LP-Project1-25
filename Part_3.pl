% == PARTE 3 ==

% Predicado maratonaFilmes:
/* Gera todas as programações possíveis de uma maratona de filmes, respeitando
um conjunto de restrições.

argumentos:
- Filmes: Lista de filmes disponíveis.
- Restricoes: Lista de restrições a serem cumpridas.
- Programacoes: Lista de todas as programações possíveis que cumprem as restrições.

Exemplo:
maratonaFilmes([matrix, shrek, frozen],
    [terror(matrix), seguido(shrek, frozen)],
    Programacoes),
    length(Programacoes, N).
N = 10. 
*/
maratonaFilmes(Filmes, Restricoes, Programacoes) :-
    
    length(Filmes, N),
    Faltam is 7 - N,
    length(Emptys, Faltam),
    maplist(=(empty), Emptys),
    append(Filmes, Emptys, ListaCompleta),
    
    
    findall(Prog,
        (permutation(ListaCompleta, Prog),
         forall(member(R, Restricoes), cumpre(Prog, R))),
        ProgramacoesSemRep),
    sort(ProgramacoesSemRep, Programacoes).

% Restrições
cumpre(Prog, terror(F)) :- F \= empty, nth1(P, Prog, F), (P=3; P=4; P=7).
cumpre(Prog, soPode(F, S)) :- (F = empty -> true; nth1(S, Prog, F)).
cumpre(Prog, nunca(F, S)) :- (F = empty -> true; \+ nth1(S, Prog, F)).
cumpre(Prog, seguido(F1, F2)) :-
    F1 \= empty, F2 \= empty,
    nth1(P1, Prog, F1), nth1(P2, Prog, F2),
    P2 is P1+1, ((P1=<4, P2=<4); (P1>=5, P2>=5)).
cumpre(Prog, naoSeguido(F1, F2)) :-
    (F1 = empty; F2 = empty) -> true ;
    \+ (
        nth1(P1, Prog, F1),
        nth1(P2, Prog, F2),
        abs(P1 - P2) =:= 1,
        ((P1 =< 4, P2 =< 4) ; (P1 >= 5, P2 >= 5))
    ).
cumpre(Prog, antes(F1, F2)) :-
    F1 \= empty, F2 \= empty,
    nth1(P1, Prog, F1), nth1(P2, Prog, F2), P1 < P2.
