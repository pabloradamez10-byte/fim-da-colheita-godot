# Alpha 0.5.34 — Loot por Localização

## Objetivo

A 0.5.34 transforma exploração em decisão espacial: o jogador deixa de encontrar a mesma lógica de recursos em qualquer lugar e passa a procurar locais coerentes com a necessidade atual.

## Pontos de interesse especializados

A cidade passa a reservar parte das quadras para POIs especializados, identificados visualmente por placa e cor própria. O mundo rural registra fazendas como fonte especializada.

- **Posto médico / hospital** — curativos, antisséptico e água; pequena chance de vestuário útil.
- **Mercado** — batata, milho, cenoura, água e chance de sementes/mochila.
- **Oficina** — kit de reparo, gasolina, materiais e chance de ferramenta/roupa de trabalho.
- **Delegacia** — munição 9 mm, cartuchos, curativos e chance de armas de fogo.
- **Fazenda** — sementes das três culturas, alimentos colhidos, água e roupa de trabalho.

## Regras de geração

- a cidade continua majoritariamente residencial;
- aproximadamente uma em cada três quadras pode receber um POI especializado;
- apenas um lote da quadra é convertido em POI;
- o tipo do POI é determinístico pela seed do mundo e coordenada da quadra;
- fazendas usam a casa rural existente e adicionam fontes de loot agrícolas;
- cada POI cria duas fontes interativas de loot;
- as fontes respeitam `harvested_keys`, portanto não reaparecem após serem coletadas e recarregadas.

## Raridade e coerência

Cada tabela possui recursos garantidos de categoria e bônus raros. O resultado usa hash da seed + local + chave da fonte, mantendo o mesmo loot para a mesma seed e o mesmo recipiente.

Exemplos de raridade:

- oficina pode entregar machadinha;
- delegacia pode liberar pistola e, com menor chance, espingarda;
- mercado pode incluir pacote de sementes;
- POIs podem entregar vestuário coerente com o ambiente.

## Integração com sistemas anteriores

A 0.5.34 reutiliza sistemas já implementados, sem criar inventários paralelos:

- alimentos entram no sistema de frescor 0.5.32;
- sementes alimentam a agricultura 0.5.31/0.5.32;
- gasolina alimenta veículos 0.5.30;
- kits de reparo alimentam crafting/manutenção;
- armas passam pelo sistema de durabilidade 0.5.23;
- vestuário usa slots e proteção corporal 0.5.33;
- todo loot continua dentro do save principal.

## Persistência

O save passa a usar a versão `0.5.34-alpha` e registra:

- quantidade de fontes especializadas coletadas por tipo de local;
- último tipo de POI saqueado;
- chaves já coletadas continuam preservadas pelo sistema de `harvested_keys` herdado.

## Critérios de aceite

A versão é aceita quando:

1. hospital, mercado, oficina, delegacia e fazenda possuem tabelas distintas;
2. as tabelas entregam seus recursos centrais garantidos;
3. POIs urbanos são gerados deterministicamente pela seed;
4. fazendas registram loot agrícola especializado;
5. fontes aparecem como interação normal do mundo;
6. uma fonte coletada não pode ser duplicada pelo mesmo save;
7. contadores de exploração persistem em save/reload;
8. agricultura, alimentação, veículos, construção, água e vestuário continuam disponíveis;
9. parser, smoke tests e exportação Android passam no CI.
