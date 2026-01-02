% == PARTE 2 ==

% Predicado tamanho:
/* Calcula o tamanho (número de caracteres) de uma palavra.

argumentos:
- Palavra: A palavra cuja tamanho será calculado.
- Tamanho: O tamanho da palavra.

Exemplo:
 tamanho("casa", Tamanho).
Tamanho = 4.
*/
tamanho(Palavra, Tamanho) :-
    string_chars(Palavra, Lista),
    length(Lista, Tamanho).

% Predicado verificaECalcula:
/* Verifica se duas palavras têm o mesmo tamanho e retorna suas listas de caracteres.

argumentos:
- Palavra1: A primeira palavra.
- Palavra2: A segunda palavra.
- CaracteresPalavra1: Lista de caracteres da primeira palavra.
- CaracteresPalavra2: Lista de caracteres da segunda palavra.

Exemplo:
verificaECalcula("casa", "pato", CaracteresPalavra1, CaracteresPalavra2).
CaracteresPalavra1 = ['c', 'a', 's', 'a'],
CaracteresPalavra2 = ['p', 'a', 't', 'o'].
*/
verificaECalcula(Palavra1, Palavra2, CaracteresPalavra1, CaracteresPalavra2) :-
    string_chars(Palavra1, CaracteresPalavra1),
    string_chars(Palavra2, CaracteresPalavra2),
    tamanho(Palavra1, Tamanho1),
    tamanho(Palavra2, Tamanho2),
    Tamanho1 =:= Tamanho2.
    
% Predicado quantasN:
/* Conta quantas palavras em uma lista têm um determinado tamanho.

argumentos:
- Id: Identificador da lista de palavras.
- N: Tamanho específico das palavras a serem contadas.
- Quantas: Número de palavras que têm o tamanho N.

Exemplo:
quantasN(pt, 4, Quantas).
Quantas = 68.
*/
% Caso base:
quantasN([], _, 0).
quantasN(Id, N, Quantas) :-
    lista_palavras(Id, Lista),
    contar_palavras_tamanho(Lista, N, Quantas).

contar_palavras_tamanho([], _, 0).
contar_palavras_tamanho([Palavra|Resto], N, Total) :-
    contar_palavras_tamanho(Resto, N, Subtotal),
    (   atom_length(Palavra, N)
    ->  Total is Subtotal + 1
    ;   Total = Subtotal
    ).

% Predicado quantasC:
/* Conta quantas palavras em uma lista começam com uma determinada letra.

argumentos:
- Id: Identificador da lista de palavras.
- C: Letra específica.
- Quantas: Número de palavras que começam com a letra C.

Exemplo:
quantasC(pt, 'a', Quantas).
Quantas = 69.
*/
quantasC(Id, C, Quantas) :-
    lista_palavras(Id, Lista),
    contar_palavras_letra(Lista, C, Quantas).

contar_palavras_letra([], _, 0).
contar_palavras_letra([Palavra|Resto], C, Total) :-
    contar_palavras_letra(Resto, C, Subtotal),
    (   atom_chars(Palavra, [C|_])
    ->  Total is Subtotal + 1
    ;   Total = Subtotal
    ).

% Predicado apagaElemento:
/* Remove a primeira ocorrência de um elemento de uma lista.

argumentos:
- X: Elemento a ser removido.
- Lista: Lista original.
- Resultado: Lista resultante após a remoção do elemento.

Exemplo:
apagaElemento(a, [a, b, c, a], Resultado).
Resultado = [b, c, a].
*/
apagaElemento(_, [], []) :- !.
apagaElemento(X, [X|Resto], Resto) :- !.
apagaElemento(X, [Y|Resto], [Y|Resultado]) :-
    apagaElemento(X, Resto, Resultado).

%Predicado posicoesPalavra:
/* Retorna uma lista de pares (carácter, posição) para cada carácter em uma palavra.

argumentos:
- Palavra: A palavra a ser analisada.
- Posicoes: Lista de pares (carácter, posição).
Exemplo:
posicoesPalavra("casa", Posicoes).
Posicoes = [('a', 2), ('a', 4), ('c', 1), ('s', 3)].
*/  
posicoesPalavra(Palavra, Posicoes) :-
    atom_chars(Palavra, Chars),
    posicoes_todas(Chars, 1, ParesNaoOrdenados),
    sort(ParesNaoOrdenados, Posicoes).

posicoes_todas([], _, []).
posicoes_todas([Char|Resto], Pos, [(Char, Pos)|ParesResto]) :-
    NovaPos is Pos + 1,
    posicoes_todas(Resto, NovaPos, ParesResto).

% Predicado pista1:
/* Gera uma pista comparando duas palavras, atribuindo 2 para caracteres na posição correta e 0 caso contrário.

argumentos:
- Palavra1: A primeira palavra.
- Palavra2: A segunda palavra.
- Pista: Lista de valores representando a pista.   

Exemplo:
pista1("casa", "cama", Pista).
Pista = [2, 2, 0, 2].
*/
pista1(Palavra1, Palavra2, Pista) :-
    atom_chars(Palavra1, Lista1),
    atom_chars(Palavra2, Lista2),
    pista1_listas(Lista1, Lista2, Pista).

pista1_listas([], [], []).
pista1_listas([C1|R1], [C2|R2], [Valor|Resto]) :-
    (C1 == C2 -> Valor = 2 ; Valor = 0),
    pista1_listas(R1, R2, Resto).

% Predicado pista2:
/* Gera uma pista comparando duas palavras, atribuindo 2 para caracteres na
posição correta, 1 para caracteres presentes na palavra mas na posição errada,
e 0 caso contrário.

argumentos:
- Palavra1: A primeira palavra.
- Palavra2: A segunda palavra.
- Pista: Lista de valores representando a pista.

Exemplo:
pista2("casa", "saco", Pista).
Pista = [1, 2, 1, 0].
*/
pista2(Palavra1, Palavra2, Pista) :-
    atom_chars(Palavra1, Lista1),
    atom_chars(Palavra2, Lista2),
    pista2_listas(Lista1, Lista2, Lista1, Pista).

pista2_listas([], [], _, []).
pista2_listas([C1|R1], [C2|R2], OriginalPalavra1, [Valor|Resto]) :-
    (   C1 == C2 -> Valor = 2; C1 \== C2, member(C2, OriginalPalavra1) -> Valor = 1;
    Valor = 0),
    pista2_listas(R1, R2, OriginalPalavra1, Resto).

% Predicado pista3:
/* Gera uma pista comparando duas palavras, atribuindo 2 para caracteres na
posição correta, 1 para caracteres presentes na palavra mas na posição errada,
e 0 caso contrário, garantindo que cada carácter só é contado uma vez.

argumentos:
- Palavra1: A primeira palavra.
- Palavra2: A segunda palavra.
- Pista: Lista de valores representando a pista.

Exemplo:
pista3("aabc", "aaaa", Pista).
Pista = [2, 2, 0, 0].
*/
pista3(Palavra1, Palavra2, Pista) :-
    atom_chars(Palavra1, Chars1),
    atom_chars(Palavra2, Chars2),
    marcar_exatos(Chars1, Chars2, Restantes, PistaTemp),
    marcar_presentes(Chars2, Restantes, PistaTemp, Pista).

marcar_exatos([], [], [], []).
marcar_exatos([C1|R1], [C2|R2], [Resto|Restos], [V|Vs]) :-
    (   C1 == C2
    ->  V = 2,
        Resto = usado  
    ;   V = 0,
        Resto = C1     
    ),
    marcar_exatos(R1, R2, Restos, Vs).


marcar_presentes([], _, [], []).
marcar_presentes([C2|R2], Disponiveis, [V|Vs], [V2|Vs2]) :-
    (   V == 2
    ->  V2 = 2,
        marcar_presentes(R2, Disponiveis, Vs, Vs2)
    ;   
        encontrar_e_remover(C2, Disponiveis, NovasDisponiveis)
    ->  V2 = 1,
        marcar_presentes(R2, NovasDisponiveis, Vs, Vs2)
    ;   V2 = 0,
        marcar_presentes(R2, Disponiveis, Vs, Vs2)
    ).


encontrar_e_remover(X, [X|Xs], Xs) :- X \== usado, !.
encontrar_e_remover(X, [usado|Xs], [usado|Ys]) :-
    !, encontrar_e_remover(X, Xs, Ys).
encontrar_e_remover(X, [Y|Xs], [Y|Ys]) :-
    encontrar_e_remover(X, Xs, Ys).
