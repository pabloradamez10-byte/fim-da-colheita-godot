# Alpha 0.5.29 — Sobrevivência hídrica e captação de chuva

## Decisão

A 0.5.29 conecta os sistemas já implementados de **clima, construção, sede e fogueira** em um ciclo de sobrevivência único. A água deixa de existir apenas como item de loot e passa a poder ser produzida na própria base, com risco quando consumida sem tratamento.

## Nova construção

### Coletor de chuva

Custo inicial:

- 3 tábuas;
- 2 cordas;
- 4 fibras.

Regras:

- capacidade máxima de 18 unidades;
- só coleta quando o clima atual é chuva;
- não coleta quando colocado sob abrigo/telhado reconhecido;
- taxa inicial de coleta: 0,055 unidade por minuto de jogo;
- possui 115 de integridade;
- pode ser reparado como as demais estruturas;
- só pode ser desmontado quando estiver vazio;
- água armazenada persiste no save.

## Água bruta e água segura

A água captada é considerada **água bruta**.

O jogador pode:

1. beber diretamente do coletor;
2. retirar uma unidade para a mochila como `dirty_water`;
3. levar a água bruta até uma fogueira acesa;
4. ferver uma unidade e transformá-la no item já existente `water`, considerado água segura.

Ferver uma unidade consome 10 minutos de combustível da fogueira.

## Risco sanitário

Beber água bruta:

- recupera sede;
- aumenta a nova variável de contaminação hídrica;
- contaminação moderada reduz fôlego;
- contaminação alta acelera perda de sede e aumenta dor;
- estágio crítico também causa perda de vida;
- o organismo recupera lentamente níveis não críticos quando está adequadamente hidratado.

A água fervida não aumenta contaminação hídrica.

## Interface mobile

- painel CONSTRUIR passa a possuir 9 peças;
- coletor possui painel próprio por INTERAGIR;
- painel mostra volume armazenado, capacidade, estado da chuva, água bruta/segura na mochila e contaminação hídrica;
- ações disponíveis: COLETAR 1 e BEBER CRUA;
- painel da fogueira recebe a ação FERVER 1 ÁGUA;
- inventário passa a exibir Água bruta e permite bebê-la diretamente;
- HUD sinaliza `CONTAM.ÁGUA` quando o valor se torna relevante.

## Critérios de aceite 0.5.29

A versão é considerada válida quando:

- cena principal usa World e Player 0.5.29;
- painel de construção possui 9 peças e inclui coletor;
- coletor pode ser construído e possui colisão;
- chuva aumenta água armazenada até a capacidade;
- tempo sem chuva não aumenta o reservatório;
- coletor sob abrigo não recebe chuva;
- retirar água transfere uma unidade para a mochila;
- beber água bruta aumenta a contaminação hídrica;
- fogueira acesa e com combustível transforma água bruta em água segura;
- fervura reduz combustível em 10 minutos por unidade;
- coletor com água não pode ser desmontado;
- água armazenada, água bruta e contaminação sobrevivem ao save/load;
- regressões de casas, água bloqueada, veículos, IA, construção, armazenamento e fogueira continuam válidas;
- parser Godot, smoke tests e exportação Android passam no CI.

## Continuidade

Ficam para versões posteriores: recipientes com volume/peso individual, poços, bombas, filtros, purificação química, água encanada, calhas/telhados construíveis, irrigação, consumo de água por agricultura e reservatórios maiores.
