# Alpha 0.5.27 — Manutenção e defesa da base

## Decisão

A 0.5.27 continua o capítulo **22 — Construção e Engenharia** iniciado na 0.5.26. A base deixa de ser um conjunto de peças permanentes e passa a possuir ciclo de uso e manutenção: abrir/fechar acessos, sofrer dano, reparar, desmontar e perder estruturas destruídas.

## Novas peças

- **Porta de madeira** — 3 tábuas + 1 corda; possui colisão fechada e abre com INTERAGIR;
- **Portão de madeira** — 4 madeiras + 1 corda; acesso largo para cercamentos e também abre com INTERAGIR.

As quatro peças anteriores permanecem disponíveis: piso, parede, cerca e caixa.

## Integridade estrutural

Cada construção do jogador passa a possuir integridade própria:

- piso: 90;
- parede: 180;
- cerca: 105;
- caixa: 95;
- porta: 135;
- portão: 150.

Saves da 0.5.26 recebem automaticamente integridade máxima ao carregar, preservando compatibilidade.

## Ataques de zumbis

Zumbis da 0.5.27 reconhecem colisões com construções do jogador. Quando uma estrutura bloqueia seu deslocamento durante perseguição/investigação, o zumbi pode atacá-la periodicamente. Variantes mais fortes causam dano ligeiramente maior.

Quando a integridade chega a zero:

- a estrutura é removida do mundo;
- não há devolução de material;
- se for uma caixa, o conteúdo armazenado é perdido junto com ela;
- a destruição é persistida no save.

## Reparo

O painel CONSTRUIR agora também funciona como painel de manutenção.

Ao aproximar-se de uma construção própria:

- a interface mostra tipo e integridade atual/máxima;
- REPARAR calcula custo proporcional ao dano;
- o custo utiliza aproximadamente 55% da fração equivalente do custo original, com mínimo de uma unidade quando houver reparo;
- uma reparação válida devolve a estrutura para integridade máxima.

## Desmontagem

DESMONTAR remove voluntariamente a construção mais próxima e devolve aproximadamente 50% dos materiais originais, arredondando para pelo menos uma unidade dos componentes utilizados.

Regra de segurança: uma caixa com itens dentro precisa ser esvaziada antes da desmontagem.

## Portas e portões

- fechados possuem colisão física;
- INTERAGIR abre/fecha;
- quando abertos a passagem é liberada;
- estado aberto/fechado é registrado no mesmo record persistente da estrutura;
- posição, rotação, integridade e estado de abertura reaparecem após carregar.

## Interface mobile

O painel de construção agora possui seis peças:

1. piso;
2. parede;
3. porta;
4. cerca;
5. portão;
6. caixa.

Além de GIRAR e COLOCAR, o painel possui:

- REPARAR PRÓXIMA;
- DESMONTAR PRÓXIMA;
- leitura da integridade e custo estimado de reparo;
- bloqueio de desmontagem para caixa ocupada.

## Critérios de aceite 0.5.27

A versão só é considerada válida quando:

- World/Player 0.5.27 são utilizados pela cena principal;
- Zombie 0.5.27 é instanciado pelo runtime;
- painel mobile lista seis peças;
- porta e portão podem ser construídos, possuem colisão fechados e abrem com INTERAGIR;
- abertura/fechamento persiste no save;
- todas as peças recebem integridade máxima ao nascer;
- dano reduz integridade e destruição em zero remove a estrutura;
- reparo consome materiais e restaura integridade;
- desmontagem devolve apenas parte dos materiais;
- caixa ocupada não pode ser desmontada;
- integridade e estruturas sobrevivem a salvar/carregar;
- regressões de crafting 0.5.25, construção/armazenamento 0.5.26, casas, água, veículos e IA anterior permanecem válidas;
- parser Godot, smoke tests e exportação Android passam no CI.

## Continuidade

Ficam para as próximas versões: barricadas de portas/janelas, telhados construíveis, fundação e suporte estrutural, fogueira, iluminação, captação de água, energia, armadilhas, fortificações pesadas e estações construíveis pelo jogador.
