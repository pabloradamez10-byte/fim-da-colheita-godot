# PKG-001 — Character Foundation

## Objetivo

Criar a base modular oficial de personagens humanos da Atlas World Engine e do jogo **Fim da Colheita**.

Este pacote deve permitir montar personagens proceduralmente sem criar um modelo completo para cada NPC.

## Estilo obrigatório

- 3D estilizado low-poly semi-realista;
- câmera isométrica/2.5D;
- proporções humanas críveis;
- cores naturais e moderadamente dessaturadas;
- roupas e equipamentos coerentes com ambiente rural do Rio Grande do Sul;
- aparência usada, vivida e pós-abandono;
- nada infantil, excessivamente cartunesco ou hiper-realista.

## Estrutura modular

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

## Produção mínima para validação

Antes de ampliar a biblioteca, o Pacote 001 deve validar:

- 1 rig compartilhado;
- 1 corpo masculino base;
- 1 corpo feminino base;
- 3 variações corporais: magro, médio e forte;
- 8 direções;
- 5 animações: `idle`, `walk`, `run`, `melee_attack`, `woodcut`;
- 3 roupas superiores;
- 3 roupas inferiores;
- 2 calçados;
- 2 cabelos;
- 2 barbas;
- 1 mochila;
- 3 ferramentas/armas;
- combinação procedural por seed.

## Ordem de montagem

```text
Body
Head
Hair
Beard
LowerClothes
UpperClothes
Footwear
Backpack
Accessories
WeaponSlots
```

## Regras procedurais

- cada personagem recebe uma seed persistente;
- o corpo define compatibilidade de rig e proporção;
- cabeça e tom de pele devem ser compatíveis;
- cabelo e barba podem ser ausentes;
- roupas seguem perfil de profissão, riqueza, idade e comunidade;
- mochila, acessórios e armas podem ser opcionais;
- peças raras usam pesos menores;
- o mesmo NPC deve sempre reconstruir a mesma aparência pela seed.

## Animações aprovadas para a biblioteca completa

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

## Formatos

### Produção oficial

- formato preferencial: GLB;
- rig compartilhado;
- materiais reutilizáveis;
- pivô e escala compatíveis com Godot 4;
- colisões separadas da malha visual.

### Preview web

- PNG transparente derivado do modelo oficial;
- perspectiva e iluminação idênticas em todos os frames;
- escala consistente;
- pivô visual na base dos pés;
- spritesheets somente após validação do modelo e do rig.

## Critérios de aprovação

Um asset só entra na biblioteca oficial se:

1. pertencer visualmente ao mesmo jogo;
2. funcionar em câmera isométrica;
3. respeitar o rig e a escala;
4. combinar sem atravessamentos graves;
5. contar uma história pela aparência;
6. estar otimizado para uso em grande quantidade;
7. manter consistência com o interior rural do Rio Grande do Sul.

## Integração no Alpha

O Pacote 001 será considerado validado quando:

- um personagem procedural for gerado por seed;
- ele caminhar nas 8 direções;
- trocar roupas sem alterar o movimento;
- usar uma ferramenta;
- executar `idle`, `walk`, `run`, `melee_attack` e `woodcut`;
- manter a mesma aparência após salvar e recarregar.

## Status

- Planejamento: concluído;
- produção visual: pendente;
- rig: pendente;
- animações: pendente;
- integração web: pendente;
- integração Godot: pendente.
