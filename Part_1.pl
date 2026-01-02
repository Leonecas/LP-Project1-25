% Projeto de LP

:- encoding(utf8).
:- style_check(-discontiguous).
:- set_prolog_flag(answer_write_options,[max_depth(0)]).
:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].


% == PARTE 1 ==

% Predicado auxiliar aluno:
/* Este predicado relaciona o ID de um aluno com a sua idade e nota de exame.

argumentos:
- ID: Identificador único do aluno.
- Idade: Idade do aluno.
- Nota: Nota obtida pelo aluno no exame.

Exemplo:
aluno(s1000, Idade, Nota).
Idade = 23, Nota = 56.2.
*/

aluno(ID, Idade, Nota) :-
    estudante(ID, Idade, _),
    exame(ID, Nota).

% Predicado média:
/* Calcula a média de uma lista de valores numéricos.

argumentos:
- ListaValores: Lista de valores numéricos.
- Media: Média calculada dos valores na lista.

Exemplo:
media([10, 20, 30], Media). 
Media = 20.0
*/
media([], 0):-!.
media(ListaValores, Media) :-
    sum_list(ListaValores, SomaTotal),
    length(ListaValores, Comprimento),
    Comprimento > 0,
    MediaCalc is SomaTotal/Comprimento,
    arredonda(MediaCalc, Media).

% Predicado auxiliar soma_notas_idade:
/* Calcula a soma das notas dos alunos dentro de uma faixa etária específica.

argumentos:
- Min: Idade mínima (exclusiva).
- Max: Idade máxima (inclusiva).
- SomaNotas: Soma das notas dos alunos na faixa etária.

Exemplo:
soma_notas_idade(19, 20, Soma).
Soma = 6450.0
*/
soma_notas_idade(Min, Max, SomaNotas) :-
    findall(Nota,
        (aluno(_, Idade, Nota), Idade > Min, Idade =< Max),
        ListaNotas),
    sum_list(ListaNotas, SomaNotas).

% Predicado auxiliar conta_alunos_idade:
/* Conta o número de alunos dentro de uma faixa etária específica.

argumentos:
- Min: Idade mínima (exclusiva).
- Max: Idade máxima (inclusiva).
- Contagem: Número de alunos na faixa etária.

Exemplo:
conta_alunos_idade(20, 23, Contagem).
Contagem = 171
*/
conta_alunos_idade(Min, Max, Contagem) :-
    findall(_,
        (aluno(_, Idade, _), Idade > Min, Idade =< Max),
        Lista),
    length(Lista, Contagem).

% Predicado MediaNotasPorIdade:
/* Calcula a média das notas dos alunos dentro de uma faixa etária específica.

argumentos:
- IdadeMin: Idade mínima (exclusiva).
- IdadeMax: Idade máxima (inclusiva).
- Media: Média das notas dos alunos na faixa etária.

Exemplo:
mediaNotasPorIdade(16, 17, Media).
Media = 64.87.

*/
mediaNotasPorIdade(IdadeMin, IdadeMax, 0) :-
    % Caso base:
    conta_alunos_idade(IdadeMin, IdadeMax, 0), !.
mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    soma_notas_idade(IdadeMin, IdadeMax, SomaNotas),
    conta_alunos_idade(IdadeMin, IdadeMax, Contagem),
    Contagem > 0,
    MediaNoId is SomaNotas / Contagem,
    arredonda(MediaNoId, Media).

% Predicado FreqPorGenero:
/* Calcula a frequência média de aulas para um determinado género.

argumentos:
- Genero: Género dos estudantes (e.g., masculino, feminino).
- MediaFreq: Frequência média calculada.

Exemplo:
freqPorGenero(feminino, Media).
Media = 85.37.

*/
% Caso base:
freqPorGenero(Genero, 0) :- 
    \+ (estudante(_, _, Genero), atividade(_, _, _, _)), !. 
freqPorGenero(Genero, MediaFreq):-
    findall(FrequenciaAulas,
        (estudante(ID, _, Genero), atividade(ID, _, _, FrequenciaAulas)), 
        ListaFreq),
    media(ListaFreq, MediaFreq).

% Predicado AlertaSaude:
/* Identifica alunos com alerta de saúde com base em critérios específicos.

argumentos:
- HorasSono: Número mínimo de horas de sono.
- Exercicio: Nível mínimo de exercício físico.
- SaudeMental: Nível mínimo de saúde mental.
- ListaAlunos: Lista de IDs dos alunos que atendem aos critérios de alerta.

Exemplo:
alertaSaude(5, 1, 2, Lista).
Lista = []
*/
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos):-
    findall(ID,
        (saude(ID, HorasSonoAluno, fraca, ExercicioAluno, SaudeMentalAluno),
         HorasSonoAluno < HorasSono, 
         ExercicioAluno < Exercicio, 
         SaudeMentalAluno < SaudeMental),
        ListaAlunos).

% Predicado ProbEcraNotasAltas:
/* Calcula a probabilidade de alunos que passam no mínimo um determinado número
de horas em frente ao ecrã obterem uma determinada nota mínima.

argumentos:
- HorasEcra: Número mínimo de horas em frente ao ecrã.
- Nota: Nota mínima.
- Probabilidade: Probabilidade calculada.

Exemplo:
 probEcraNotasAltas(3, 80, Prob).
Prob = 0.25
*/
probEcraNotasAltas(HorasEcra, _Nota, 0) :- 
    % Caso base:
    findall(ID,
        (atividade(ID, _, HorasEcraAluno, _),
        HorasEcraAluno > HorasEcra),
        ListaEcra),
    length(ListaEcra, 0), !.

probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :-
    % (A ∩ B):
    findall(ID, 
        (atividade(ID, _, HorasEcraAluno, _), 
        exame(ID, NotaAluno),
        HorasEcraAluno > HorasEcra,
        NotaAluno > Nota),
        ListaIntersecao),
    length(ListaIntersecao, CountBoth),
    
    % (B):
    findall(ID,
        (atividade(ID, _, HorasEcraAluno, _),
        HorasEcraAluno > HorasEcra),
        ListaEcra),
    length(ListaEcra, CountEcra),
    
    CountEcra > 0,
    ProbabilidadeProvisoria is CountBoth / CountEcra,
    arredonda(ProbabilidadeProvisoria, Probabilidade).

% Predicado subtraiValorDeLista:
/* Subtrai um valor específico de cada elemento de uma lista.

argumentos:
- [X|Xs] (Lista): Lista original de números.
- Valor: Valor a ser subtraído de cada elemento.
- [NovoX|NovoXs] (NovaLista): Nova lista com os valores subtraídos.

Exemplo:
subtraiValorDeLista([10, 20, 30], 5, NovaLista).
NovaLista = [5, 15, 25].
*/
% Caso base:
subtraiValorDeLista([], _, []). 

subtraiValorDeLista([X|Xs], Valor, [NovoX|NovoXs]) :- 
    NovoX is X - Valor,
    subtraiValorDeLista(Xs, Valor, NovoXs).

% Predicado somaQuadrados:
/* Calcula a soma dos quadrados dos elementos de uma lista.

argumentos:
- [X|Xs] (Lista): Lista original de números.
- Soma: Soma dos quadrados dos elementos.

Exemplo:
somaQuadrados([2, 3, 4], Soma).
Soma = 29.
*/
somaQuadrados([], 0). 
somaQuadrados([X|Xs], Soma) :- 
    somaQuadrados(Xs, SomaXs),
    Soma is X * X + SomaXs.

% Predicado produtoEscalar:
/* Calcula o produto escalar de dois vetores (duas listas de números).

Argumentos:
- [X|Xs] (Lista1): Primeiro vetor.
- [Y|Ys] (Lista2): Segundo vetor.
- Resultado: Produto escalar dos dois vetores.

Exemplo:
produtoEscalar([1, 2, 3], [4, 5, 6], Resultado).
Resultado = 32.
*/
% Caso base:
produtoEscalar([], [], 0).

produtoEscalar([X|Xs], [Y|Ys], Resultado):- 
    produtoEscalar(Xs, Ys, ResultadoXs),
    Resultado is (X * Y) + ResultadoXs.

% Predicado correlação: 
/* Calcula a correlação entre dois conjuntos de dados representados por listas.

argumentos:
- Lista1: Primeiro conjunto de dados.
- Lista2: Segundo conjunto de dados.
- Resultado: Coeficiente de correlação entre os dois conjuntos.

Dados adicionais:
Parte A: soma de (X - médiaX) × (Y - médiaY)
% Parte B: soma de (X - médiaX)²
% Parte C: soma de (Y - médiaY)²
% Fórmula final: Resultado = ParteA / √(ParteB × ParteC)

Exemplo:
correlacao([1, 2, 3], [4, 5, 6], Resultado).
Resultado = 1.0.
*/
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
