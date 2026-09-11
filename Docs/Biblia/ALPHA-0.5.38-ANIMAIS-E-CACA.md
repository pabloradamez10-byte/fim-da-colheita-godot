# Alpha Android 0.5.38 — Animais & Caça

## Objetivo

Introduzir uma primeira camada funcional de fauna no mundo de **Fim da Colheita**, conectando animais à exploração, ao sistema de ruído, ao combate, à alimentação, à progressão e à persistência. A fauna deixa de ser apenas cenário e passa a ser recurso vivo, móvel e reativo.

## Implementado nesta versão

- 18 animais persistentes por mundo/seed;
- quatro espécies iniciais: coelho, veado, javali e galinha;
- distribuição determinística baseada na seed do mundo;
- comportamento de caminhada e fuga;
- reação à aproximação do jogador, zumbis e eventos de ruído;
- tiros e outros sons relevantes podem dispersar animais próximos;
- atributos distintos por espécie: vida, velocidade, audição e distância de fuga;
- animais podem receber dano pelas armas já existentes;
- carcaça persistente após o abate;
- interação com a carcaça para aproveitamento de recursos;
- carne crua de caça, couro e penas como novos recursos;
- carne de caça assada integrada ao ciclo de alimentação;
- carne crua e cozida com validade própria e deterioração;
- consumo de carne crua com penalidade de intoxicação alimentar;
- XP de combate por caça e XP de vasculhamento por aproveitamento da carcaça;
- save 0.5.38 com posição, vida, estado e aproveitamento de cada animal;
- integração preservada com Zumbis 2.0, hordas, missões, veículos, agricultura, clima, construção e UI mobile.

## Espécies iniciais

### Coelho

Animal pequeno, frágil e rápido. Detecta ameaças cedo e tende a fugir com velocidade. Fornece pequena quantidade de carne e couro.

### Veado

Animal de médio porte, resistente e muito sensível a ameaças. Foge rapidamente e fornece maior quantidade de carne e couro.

### Javali

Animal robusto, com maior vida e deslocamento mais pesado. Nesta primeira etapa prioriza evasão e resistência; comportamento territorial/agressivo mais profundo fica reservado para expansão posterior.

### Galinha

Animal pequeno ligado ao ambiente rural. Fornece carne e penas, abrindo material para futuras receitas, flechas, isolamento e crafting.

## Loop de caça

1. localizar um animal no mundo;
2. aproximar-se sem dispersá-lo ou aceitar o risco de perseguição;
3. usar arma branca ou arma de fogo;
4. o animal reage ao dano e tenta fugir;
5. ao morrer, permanece como carcaça;
6. aproximar-se e usar **INTERAGIR**;
7. receber carne e materiais conforme a espécie;
8. levar a carne para a fogueira e assar;
9. consumir ou armazenar antes da deterioração.

## Ruído e ecossistema

O sistema de ruído é compartilhado com a 0.5.37. Isso significa que um disparo pode simultaneamente:

- assustar a fauna;
- atrair infectados;
- alterar o destino de uma horda;
- transformar uma caça simples em um risco maior de sobrevivência.

Essa ligação é deliberada: comida obtida por caça deve competir com segurança, munição, tempo e exposição.

## Recursos iniciais

- **Carne crua de caça** — alimento de alto risco quando consumido sem preparo; deteriora rapidamente.
- **Carne de caça assada** — alimento seguro e com recuperação de fome superior.
- **Couro** — recurso reservado para vestuário, reparos e crafting futuro.
- **Penas** — recurso reservado para crafting e sistemas futuros.

## Persistência

Cada registro de fauna guarda:

- ID estável;
- espécie;
- posição atual;
- ponto de origem;
- vida atual;
- estado vivo/morto;
- estado da carcaça aproveitada ou não;
- último evento sonoro registrado.

Uma carcaça já aproveitada não reaparece ao recarregar o save.

## Critérios de aceite

A versão só é aceita se:

1. o projeto importar sem erro de parser;
2. existirem 18 registros de fauna em quatro espécies;
3. todos os animais vivos forem instanciados no mundo;
4. um ruído de tiro provocar reação de fuga;
5. um animal puder receber dano e morrer;
6. o abate gerar carcaça;
7. a carcaça puder ser aproveitada por interação;
8. o jogador receber carne e couro ou penas;
9. a carne puder ser assada e consumida;
10. fauna e carcaças persistirem no save 0.5.38;
11. um animal já aproveitado não reaparecer após reload;
12. as regressões de casas, combate, construção, água, veículos, UI, missões e Zumbis 2.0 permanecerem verdes;
13. o APK Android for exportado pelo CI.

## Fora do fechamento desta versão

A 0.5.38 é a primeira camada do sistema animal. Reprodução, fome/sede dos animais, ninhos, domesticação, criação, predadores, rastros visuais, armadilhas, doenças animais, territorialidade avançada, migração regional e simulação off-screen profunda ficam reservados para expansões do Ecossistema Vivo e do World Simulator/AWE.
