# Terrain Manager — Alpha 0.4.0

## Objetivo

Centralizar as propriedades e as variações visuais dos terrenos da versão web.

## Propriedades

Cada terreno possui ID, nome, cor de fallback, estado caminhável, custo de movimento e lista de variantes visuais.

## Seleção por seed

O `TerrainManager` combina seed e coordenadas da célula para escolher uma variante. A mesma seed sempre produz a mesma variante na mesma posição.

Pesos iniciais da grama:

- base 001: 30%;
- base 002: 24%;
- base 003: 16%;
- flores: 10%;
- pedras: 9%;
- desgaste: 11%.

## Fallback

Se o PNG de uma variante estiver ausente, o tile continua sendo desenhado com a cor oficial do terreno.

## Regras dos PNGs

- 512 x 256 px;
- proporção isométrica 2:1;
- canal alfa real;
- sem fundo, texto ou marca d'água;
- sem laterais ou espessura de solo;
- mesmo alinhamento e escala entre variações.

## Produção visual

O pacote de grama foi produzido com geração de imagem integrada, seguindo `Catalogs/Art/ATLAS_ART_BIBLE.md`, `Catalogs/Nature/ATLAS_NATURE_LIBRARY.md` e `web/assets/terrain/README.md`. Os arquivos brutos foram gerados sobre chroma key magenta, convertidos para alfa real e normalizados para o formato final.
