% == PARTE 1 ==

% Predicado auxiliar aluno:
aluno(ID, Idade, Nota) :-
    estudante(ID, Idade, _),
    exame(ID, Nota).

% Predicado média:
media([], 0):-!.
media(ListaValores, Media) :-
    sum_list(ListaValores, SomaTotal),
    length(ListaValores, Comprimento),
    Comprimento > 0,
    MediaCalc is SomaTotal/Comprimento,
    arredonda(MediaCalc, Media).

% Predicado auxiliar soma_notas_idade:
soma_notas_idade(Min, Max, SomaNotas) :-
    findall(Nota,
        (aluno(_, Idade, Nota), Idade > Min, Idade =< Max),
        ListaNotas),
    sum_list(ListaNotas, SomaNotas).

% Predicado auxiliar conta_alunos_idade:
conta_alunos_idade(Min, Max, Contagem) :-
    findall(_,
        (aluno(_, Idade, _), Idade > Min, Idade =< Max),
        Lista),
    length(Lista, Contagem).

% Predicado MediaNotasPorIdade:
mediaNotasPorIdade(IdadeMin, IdadeMax, 0) :-
    conta_alunos_idade(IdadeMin, IdadeMax, 0), !.
mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    soma_notas_idade(IdadeMin, IdadeMax, SomaNotas),
    conta_alunos_idade(IdadeMin, IdadeMax, Contagem),
    Contagem > 0,
    MediaNoId is SomaNotas / Contagem,
    arredonda(MediaNoId, Media).

% Predicado FreqPorGenero:
freqPorGenero(Genero, 0) :-
    \+ (estudante(_, _, Genero), atividade(_, _, _, _)), !. 
freqPorGenero(Genero, MediaFreq):-
    findall(FrequenciaAulas,
        (estudante(ID, _, Genero), atividade(ID, _, _, FrequenciaAulas)), 
        ListaFreq),
    media(ListaFreq, MediaFreq).

% Predicado AlertaSaude:
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos):-
    findall(ID,
        (saude(ID, HorasSonoAluno, fraca, ExercicioAluno, SaudeMentalAluno),
         HorasSonoAluno < HorasSono, 
         ExercicioAluno < Exercicio, 
         SaudeMentalAluno < SaudeMental),
        ListaAlunos).

% Predicado ProbEcraNotasAltas:
probEcraNotasAltas(HorasEcra, _Nota, 0) :- 
    % Caso base: se ninguém passa mais de HorasEcra no ecrã
    findall(ID,
        (atividade(ID, _, HorasEcraAluno, _),
        HorasEcraAluno > HorasEcra),
        ListaEcra),
    length(ListaEcra, 0), !.

probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :-
    % (A ∩ B): alunos com nota > Nota e horas ecrã > HorasEcra
    findall(ID, 
        (atividade(ID, _, HorasEcraAluno, _), 
        exame(ID, NotaAluno),
        HorasEcraAluno > HorasEcra,
        NotaAluno > Nota),
        ListaIntersecao),
    length(ListaIntersecao, CountBoth),
    
    % (B): alunos com horas ecrã > HorasEcra
    findall(ID,
        (atividade(ID, _, HorasEcraAluno, _),
        HorasEcraAluno > HorasEcra),
        ListaEcra),
    length(ListaEcra, CountEcra),
    
    CountEcra > 0,
    ProbabilidadeProvisoria is CountBoth / CountEcra,
    arredonda(ProbabilidadeProvisoria, Probabilidade).

% Predicado subtraiValorDeLista:
subtraiValorDeLista([], _, []). 

subtraiValorDeLista([X|Xs], Valor, [NovoX|NovoXs]) :- 
    NovoX is X - Valor,
    subtraiValorDeLista(Xs, Valor, NovoXs).

% Predicado somaQuadrados:
somaQuadrados([], 0). 
somaQuadrados([X|Xs], Soma) :-
    somaQuadrados(Xs, SomaXs),
    Soma is X * X + SomaXs.

% Predicado produtoEscalar:
produtoEscalar([], [], 0). 

produtoEscalar([X|Xs], [Y|Ys], Resultado):- 
    produtoEscalar(Xs, Ys, ResultadoXs),
    Resultado is (X * Y) + ResultadoXs.

% Predicado correlação: 

% Parte A: soma de (X - médiaX) × (Y - médiaY)
% Parte B: soma de (X - médiaX)²
% Parte C: soma de (Y - médiaY)²
% Fórmula final: Resultado = ParteA / √(ParteB × ParteC)

correlacao(Lista1, Lista2, Resultado):-
    length(Lista1, N),
    length(Lista2, N),
    N > 0,
    media(Lista1, Media1),
    media(Lista2, Media2),
    calculaPartes(Lista1, Lista2, Media1, Media2, ParteA, ParteB, ParteC),
    ParteBxC is ParteB * ParteC,
    ParteBxC > 0,
    Denominador is sqrt(ParteBxC),
    ResultadoExato  is ParteA / Denominador,
    arredonda(ResultadoExato, Resultado).

% Predicado auxiliar
calculaPartes([], [], _, _, 0, 0, 0).
calculaPartes([X|Xs], [Y|Ys], M1, M2, A, B, C):-
    calculaPartes(Xs, Ys, M1, M2, A1, B1, C1),
    DiferencaX is X - M1,
    DiferencaY is Y - M2,
    A is (DiferencaX * DiferencaY) + A1,
    B is (DiferencaX * DiferencaX) + B1,
    C is (DiferencaY * DiferencaY) + C1.
