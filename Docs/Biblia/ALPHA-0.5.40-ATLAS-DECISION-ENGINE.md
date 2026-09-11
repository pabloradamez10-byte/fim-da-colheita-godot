# Alpha Android 0.5.40 — Atlas Decision Engine Inicial

## Objetivo

A 0.5.40 encerra a sequência 0.5.x atual criando a primeira implementação funcional do **Atlas Decision Engine**. O objetivo é transformar sobreviventes humanos de agentes puramente reativos em agentes que avaliam o contexto e escolhem prioridades próprias.

Esta versão ainda não é uma IA social completa. Ela estabelece o núcleo local, determinístico e persistente sobre o qual serão construídos personalidade, memória, comunidades, facções e simulação sistêmica mais profunda.

## Princípio

Cada sobrevivente passa por um ciclo:

**Perceber contexto → pontuar alternativas → escolher prioridade → definir destino → agir → reavaliar.**

A decisão não entrega recursos mágicos nem substitui sistemas já existentes. Quando um NPC precisa de água, comida ou cuidado, o motor cria uma meta e um destino; se ele conhece o jogador e está próximo, pode procurar o jogador para pedir ajuda, mantendo o ciclo social introduzido na 0.5.39.

## Entradas do contexto

O motor 0.5.40 considera inicialmente:

- saúde;
- fome;
- sede;
- proximidade de zumbis;
- posição do jogador;
- distância até o jogador;
- confiança e primeiro contato;
- horário/noite;
- papel do sobrevivente;
- posição de casa/abrigo.

## Ações iniciais

O Decision Engine pontua sete ações:

1. **flee_threat** — fugir de ameaça imediata;
2. **seek_water** — procurar água/ajuda por sede;
3. **seek_medical** — procurar ajuda médica;
4. **seek_food** — procurar comida/ajuda por fome;
5. **return_home** — retornar para casa, especialmente à noite;
6. **regroup_player** — aproximar-se do jogador quando existe confiança suficiente;
7. **role_patrol** — executar rotina coerente com o papel quando nenhuma urgência domina.

Ameaças próximas têm prioridade forte e podem interromper outros objetivos. Necessidades críticas superam rotinas normais. O comportamento social só ganha peso quando o NPC já conhece o jogador e acumulou confiança.

## Scheduler inicial

O mundo executa ciclos periódicos de decisão. Em cada ciclo:

- os sobreviventes vivos são avaliados;
- o contexto atual é montado;
- o Decision Engine pontua as opções;
- a maior prioridade é selecionada;
- um alvo é resolvido;
- o NPC recebe a nova decisão;
- trocas de decisão e métricas são registradas.

A locomação continua utilizando o controlador físico já validado na 0.5.39. O motor de decisão escolhe **o que fazer e para onde ir**; o personagem continua responsável por colisão e deslocamento.

## Arquitetura

A 0.5.40 separa três responsabilidades:

- `atlas_decision_engine_v0540.gd` — cálculo de prioridades, sem dependência de UI ou rede;
- `survivor_npc_3d_v0540.gd` — estado individual da decisão e execução do destino;
- `world_runtime_3d_v0540.gd` — percepção do mundo, scheduler, resolução dos alvos e persistência.

O motor é **offline e determinístico** nesta fase. Nenhuma API externa ou LLM é necessária durante o jogo.

## Persistência

O save `0.5.40-alpha` registra:

- decisão atual de cada sobrevivente;
- pontuação e motivo;
- destino e tipo de destino;
- número de avaliações individuais;
- número de ciclos do scheduler;
- trocas de prioridade;
- contagem acumulada por ação;
- último evento de decisão.

O estado social da 0.5.39 continua sendo salvo no mesmo registro de sobreviventes.

## Integração com a 0.5.39

A Sociedade Humana permanece intacta:

- Helena, Davi e Mauro continuam persistentes;
- fome, sede, saúde, confiança e morte continuam válidas;
- primeiro contato, ajuda e compartilhamento de suprimentos continuam funcionando;
- o Decision Engine adiciona autonomia sem substituir interação manual.

## Limites desta etapa

Ainda ficam para uma geração posterior do Atlas World Engine:

- planejamento de múltiplas etapas;
- memória episódica e social profunda;
- inventário completo e consumo autônomo de recursos por NPC;
- diálogo ramificado;
- recrutamento e ordens de grupo;
- profissões produtivas completas;
- comunidades e assentamentos autônomos;
- facções, diplomacia, reputação e guerra;
- economia simulada;
- scheduler por distância/LOD de simulação;
- decisões de longo prazo entre dias/semanas;
- narrativa emergente.

## Critério de aceite

A 0.5.40 é considerada válida quando:

1. o motor expõe sete ações locais e determinísticas;
2. os três sobreviventes recebem decisões periódicas;
3. ameaça imediata supera necessidades e rotinas;
4. sede, fome e saúde baixa geram objetivos próprios;
5. noite pode gerar retorno para casa;
6. confiança pode gerar reagrupamento com o jogador;
7. NPC conhecido e necessitado pode procurar ajuda do jogador;
8. decisões e métricas persistem no save;
9. Sociedade Humana, fauna, zumbis, missões, veículos e demais regressões continuam válidos;
10. parser, smoke tests e exportação Android passam no CI.
