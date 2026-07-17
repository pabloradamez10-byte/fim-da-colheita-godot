# Fim da Colheita — Godot + AWE

Repositório oficial de desenvolvimento do jogo **Fim da Colheita**.

## Arquitetura

- **Godot 4**: renderização, física, animações, áudio, câmera e interface.
- **AWE — Atlas World Engine**: regras, geração procedural, simulação global, decisões e persistência.
- **Atlas DataCore**: catálogos modulares em JSON que descrevem o universo.

## Estrutura inicial

```text
AWE/
  Core/
  Rules/
  WorldGenerator/
  Simulation/
  DataCore/
    Terrain/
    Biomes/
    Objects/
    Resources/
    Items/
    Recipes/
    Structures/
    Vehicles/
    Professions/
    Animals/
    Plants/
    Diseases/
    Factions/
    Communities/
    Events/
Catalogs/
  Art/
  Characters/
  Nature/
  Buildings/
  Vehicles/
Docs/
```

## Estado atual

Versão inicial: **AWE v0.0.1**.

Primeiro objetivo técnico: gerar um mundo por Seed com grama, terra, água, montanhas, biomas, objetos naturais e regras coerentes.

## Regra central

> Simular o máximo possível, processando apenas o necessário.
