# Alpha 0.5.35 — Progressão do Sobrevivente

## Estado

**IMPLEMENTADO / EM EXPANSÃO**

A 0.5.35 transforma ações recorrentes do jogador em evolução persistente do personagem. A progressão não é concedida por tempo parado: ela nasce de ações concretas no mundo e produz efeitos funcionais nos sistemas já existentes.

## Perícias iniciais

- **Combate** — evolui ao acertar zumbis; aumenta o dano causado.
- **Agricultura** — evolui ao preparar solo, plantar, regar e colher; melhora o rendimento das colheitas e, em níveis superiores, a recuperação de sementes.
- **Medicina** — evolui ao usar bandagens e antisséptico; melhora recuperação, controle de sangramento, dor e infecção.
- **Mecânica** — evolui ao abastecer e reparar veículos; aumenta o percentual de integridade restaurado por kit de reparo.
- **Vasculhamento** — evolui ao saquear casas e POIs; aumenta a chance de encontrar um recurso contextual adicional.

Cada perícia possui níveis de 0 a 10 e curva de XP crescente.

## Nível geral e atributos

O sobrevivente possui um nível geral derivado do XP acumulado nas perícias. A primeira implementação também introduz três atributos derivados:

- **Força** — cresce principalmente com Combate e Mecânica e contribui para dano.
- **Vigor** — cresce com a experiência geral e reduz parte da penalidade de peso do equipamento.
- **Percepção** — cresce com Vasculhamento e Agricultura e influencia a eficiência de exploração.

Esta é a base para profissões, vantagens, limitações e especializações futuras; esses sistemas não fazem parte da 0.5.35.

## Integrações com sistemas anteriores

A versão preserva e conecta:

- ferimentos e tratamento;
- combate e armas;
- agricultura 0.5.31/0.5.32;
- vestuário e peso 0.5.33;
- loot especializado 0.5.34;
- veículos e reparo 0.5.30;
- save e migração das versões anteriores.

## Interface mobile

A mochila passa a exibir também a progressão do personagem, contendo:

- nível geral;
- XP total;
- Força, Vigor e Percepção;
- nível e barra de progresso das cinco perícias;
- última evolução registrada.

A progressão foi colocada dentro da interface já existente para evitar a criação de mais um botão permanente na tela de jogo.

## Persistência

O save 0.5.35 registra o XP de cada perícia e recompõe níveis e atributos ao carregar. Contadores de integração de agricultura, vasculhamento e mecânica também permanecem persistentes.

## Critério de aceite

A versão é considerada válida quando:

1. ações reais concedem XP à perícia correspondente;
2. níveis alteram resultados de gameplay e não apenas a interface;
3. a progressão aparece na mochila mobile;
4. XP e níveis sobrevivem ao save/reload;
5. casas, veículos, água, construção, agricultura, vestuário e POIs continuam funcionando;
6. o APK Android é exportado após os testes automatizados.

## Próximas expansões previstas

- profissões de origem;
- vantagens e limitações;
- perícias adicionais de crafting, construção e armas específicas;
- desbloqueios de receitas por conhecimento;
- perda, manutenção ou transferência de conhecimento em sistemas de sucessão.
