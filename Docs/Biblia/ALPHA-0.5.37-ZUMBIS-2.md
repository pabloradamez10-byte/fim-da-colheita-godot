# Alpha Android 0.5.37 — Zumbis 2.0

## Objetivo

Transformar os infectados de inimigos isolados em uma ameaça dinâmica do mundo, mantendo compatibilidade com os sistemas de sobrevivência, ferimentos, clima, construção, veículos, progressão e missões já existentes.

## Implementado nesta versão

- quatro grupos de horda persistentes por mundo/seed;
- migração periódica das hordas entre regiões do mapa;
- atração coletiva por ruídos relevantes, incluindo tiros, motor e colisões de veículos;
- memória de alerta e alvo compartilhado com os membros da horda;
- pressão dos infectados sobre estruturas construídas, preservando o sistema da 0.5.27/0.5.28;
- portas e janelas do mundo com resistência própria contra ataques dos infectados;
- arrombamentos persistentes: uma barreira destruída permanece aberta no save;
- cinco perfis de infectados: errante, corredor, robusto, rural e operário;
- diferenças funcionais entre perfis em vida, velocidade, audição e capacidade de causar dano em barreiras;
- novo atlas visual com cinco perfis e oito quadros de animação por perfil;
- migração de seed corrigida para que hordas novas sejam posicionadas usando a seed efetivamente ativa;
- save 0.5.37 com posição/alvo das hordas, alertas e estado das barreiras;
- compatibilidade preservada com a frota 0.5.36.2 de 40 veículos e oito direções.

## Regras de gameplay

Ruído é risco. Armas de fogo e veículos podem deslocar a pressão zumbi para uma região. Um confronto local pode, portanto, produzir consequência além da tela imediata.

Abrigo não é invulnerabilidade. Portas, janelas, paredes, portões e barricadas são elementos físicos da defesa. Os infectados devem pressionar a barreira quando ela interrompe o caminho até um alvo investigado.

As hordas não são teletransportadas até o jogador. O sistema mantém centros e alvos de migração e desloca a pressão progressivamente, respeitando a lógica do mundo persistente.

## Perfis iniciais

- **Errante** — referência básica, lento e previsível.
- **Corredor** — deslocamento e resposta sonora maiores, menor resistência relativa.
- **Robusto** — mais vida e pressão física.
- **Rural** — equilíbrio entre resistência e percepção, alinhado ao ambiente rural do jogo.
- **Operário** — resistência intermediária e maior capacidade de pressionar estruturas.

## Persistência

O save registra:

- quatro registros de horda;
- centros, alvos e estado de alerta;
- contadores de migração e eventos sonoros;
- vida restante de portas/janelas atacadas;
- chaves das barreiras já arrombadas;
- último evento relevante da ecologia zumbi.

## Critérios de aceite

A versão só é aceita se:

1. o projeto importar sem erro de parser ou asset corrompido;
2. os cinco perfis visuais estiverem presentes;
3. os oito quadros de animação do atlas forem acessíveis;
4. existirem quatro hordas válidas;
5. uma migração alterar o alvo de uma horda;
6. um disparo de alto ruído alertar a ecologia;
7. uma porta de teste puder ser danificada e arrombada;
8. o estado de horda e arrombamento persistir no save;
9. as regressões de casas, água, construção, veículos, UI mobile e missões continuarem passando;
10. o APK Android for exportado pelo CI.

## Fora do fechamento desta versão

A 0.5.37 não encerra a visão final do Ecossistema Vivo. Densidade populacional regional de longo prazo, redistribuição entre chunks descarregados, eventos massivos de horda e simulação off-screen mais profunda continuam reservados para a evolução do World Simulator/AWE.
