# Atlas Character Pipeline

## Objetivo

Criar personagens 3D modulares, consistentes e reutilizáveis.

## Estrutura

```text
CharacterBase
├── Body
├── Head
├── Hair
├── Beard
├── UpperClothes
├── LowerClothes
├── Footwear
├── Backpack
├── Accessories
└── WeaponSlots
```

## Regras

- Todos os humanos usam um rig principal compatível.
- Animações pertencem ao rig, não a um personagem específico.
- Armas e equipamentos são objetos independentes.
- Roupas devem acompanhar o esqueleto sem atravessamentos graves.
- Variações corporais iniciais: masculino e feminino, magro, médio e forte.
- Aparência muda com idade, cabelo, barba, roupas, equipamentos e cicatrizes.

## Animações-base

- idle;
- walk;
- run;
- crouch;
- melee_attack;
- ranged_attack;
- push;
- collect;
- woodcut;
- mine;
- build;
- fish;
- drive;
- sleep;
- injured_walk.

## Produção inicial

Começar com um único personagem-base, um rig e cinco animações: idle, walk, run, melee_attack e woodcut. Validar tudo na Godot antes de ampliar a biblioteca.

## Atualização futura

Desgaste visual dinâmico de roupas e equipamentos permanece aprovado para fase posterior.
