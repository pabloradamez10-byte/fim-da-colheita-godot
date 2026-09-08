# Alpha 0.5.26 — Construção e base persistente

## Decisão

A 0.5.26 inicia oficialmente o capítulo **22 — Construção e Engenharia** da Bíblia. O jogador deixa de depender apenas de estruturas pré-geradas e passa a alterar fisicamente o mundo com peças próprias, consumindo recursos processados e mantendo essas alterações no save.

## Loop implementado

1. coletar matérias-primas;
2. processar madeira/fibra na cadeia de crafting já existente;
3. abrir o modo **CONSTRUIR** no mobile;
4. escolher uma peça;
5. posicionar usando preview no mundo;
6. girar a peça em passos de 90°;
7. validar espaço e custo;
8. confirmar a construção;
9. usar a estrutura construída e mantê-la após salvar/carregar.

## Peças iniciais

- **Piso de madeira** — base visual modular; custo: 2 tábuas;
- **Parede de madeira** — barreira com colisão; custo: 3 tábuas + 1 corda;
- **Cerca de madeira** — posts/travessas com colisão; custo: 3 madeiras + 1 corda;
- **Caixa de armazenamento** — estrutura com colisão e inventário próprio; custo: 3 tábuas + 1 corda.

## Regras de posicionamento

- preview verde indica posição válida;
- preview vermelho indica bloqueio, falta de materiais ou distância inválida;
- peças usam grade de posicionamento para manter alinhamento;
- rotação ocorre em incrementos de 90°;
- o jogador não pode colocar a peça sobre si mesmo;
- colisões existentes impedem paredes, cercas e caixas de atravessarem estruturas físicas;
- piso permanece sem collider elevado para evitar repetir o problema antigo de degraus invisíveis no CharacterBody;
- piso pode servir como célula de base para outras peças sem bloquear automaticamente parede/cerca/caixa na mesma área.

## Armazenamento

A caixa construída é funcional:

- capacidade inicial de 60 unidades;
- INTERAGIR próximo à caixa abre sua interface;
- recursos, consumíveis, munição e materiais processados podem ser transferidos entre mochila e caixa;
- conteúdo da caixa é persistido pelo UID da estrutura;
- cada caixa possui inventário independente.

## Persistência

O save passa a registrar:

- lista de estruturas construídas;
- tipo, posição, rotação e UID de cada peça;
- serial de construção;
- inventários das caixas;
- contadores básicos de construção/transferência do personagem.

Saves anteriores continuam compatíveis: na ausência dos novos campos, o sistema inicia sem construções do jogador.

## Interface mobile

- botão **CONSTRUIR** abre o painel sem bloquear a visão do mundo;
- seleção rápida de piso, parede, cerca e caixa;
- botão **GIRAR 90°**;
- botão **COLOCAR**, habilitado apenas quando a posição é válida;
- texto de custo por peça e feedback de bloqueio;
- caixa de armazenamento possui painel próprio com transferência unitária nos dois sentidos.

## Critérios de aceite 0.5.26

A versão só é válida quando:

- a cena principal usa World/Player 0.5.26;
- o painel de construção possui as quatro peças;
- custos são descontados apenas ao confirmar uma colocação válida;
- posição inválida não consome materiais;
- parede, cerca e caixa possuem colisão física;
- piso não cria degrau bloqueante;
- rotação de 90° altera a orientação da peça;
- pelo menos quatro peças podem ser persistidas no mesmo save;
- caixa construída abre com INTERAGIR;
- depósito e retirada alteram os dois inventários corretamente;
- capacidade da caixa é respeitada;
- estruturas e conteúdo reaparecem após carregar o save;
- crafting 0.5.25, hotbar, clima, casas, água, veículos e IA dos zumbis não regridem;
- parser Godot, smoke tests e exportação Android passam no CI.

## Continuidade

Ainda ficam para as próximas etapas: desmontagem/demolição, portas e janelas construíveis, telhados, fundação/nível de terreno, integridade estrutural, dano a estruturas, reparo, barricadas, fogueira, coleta de água, energia, iluminação, fortificações, construção de bancada própria e expansão da base por módulos.
