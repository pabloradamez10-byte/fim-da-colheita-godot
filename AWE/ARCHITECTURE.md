# AWE — Atlas World Engine

## Missão

A AWE é o cérebro independente de renderização do **Fim da Colheita**. Ela descreve, gera e simula o mundo. A Godot apresenta os resultados visualmente.

## Princípios

1. **Data-driven:** conteúdo definido por dados, não por regras rígidas no código.
2. **Modular:** cada domínio possui catálogo e lógica próprios.
3. **Determinística por Seed:** a mesma Seed recria o mesmo estado inicial.
4. **Persistente:** toda ação relevante deixa consequências salvas.
5. **Orientada a objetivos:** NPCs e organizações tentam resolver problemas, não seguir roteiros.
6. **Simulação em níveis de detalhe:** regiões próximas recebem detalhes; regiões distantes recebem resultados resumidos.
7. **Jogador não central:** o mundo continua funcionando sem sua presença.

## Camadas

```text
Atlas DataCore
      ↓
World Generator
      ↓
World State
      ↓
Simulation Scheduler
      ↓
Decision Engine + Simuladores
      ↓
Event Bus
      ↓
Godot Adapter
      ↓
Godot 4
```

## Módulos planejados

- Core
- Rules
- DataCore
- WorldGenerator
- Terrain
- Biomes
- Nature
- Climate
- Wildlife
- Zombies
- NPC
- Communities
- Factions
- Economy
- Construction
- Crafting
- Logistics
- Events
- Persistence
- Tools
- GodotAdapter

## Primeira prova técnica

AWE v0.0.1 deve:

- receber uma Seed;
- gerar uma grade lógica de terreno;
- distribuir biomas;
- posicionar objetos válidos;
- respeitar regras do mundo;
- exportar um `world.json` que uma camada visual possa ler.

## Regra de desempenho

> Simular o máximo possível, processando apenas o necessário.
