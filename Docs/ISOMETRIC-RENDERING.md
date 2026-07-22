# Renderização isométrica — Alpha 0.5.0

## Câmera

A câmera centraliza o jogador imediatamente no primeiro quadro. Depois de uma movimentação, ela alcança a nova posição de forma suave.

## Projeção

`IsometricMath.js` concentra as funções reutilizáveis:

- `worldToScreen()`;
- `screenToWorld()`;
- `drawIsometricTile()`;
- `drawSpriteWithPivot()`;
- `isTileVisible()`;
- `sortByDepth()`.

## Visibilidade

O renderizador percorre a grade lógica, mas envia ao canvas apenas tiles dentro da área visível com uma margem pequena. Objetos distantes também deixam de ser desenhados.

## Profundidade

Jogador e objetos são ordenados pela soma das coordenadas do chão. O pivô visual do personagem usa a base dos pés, preparando a passagem correta diante e atrás de vegetação e construções.

## Compatibilidade futura

A câmera está separada do renderizador para receber zoom e limites de mundo futuramente, sem adicionar essa complexidade ao Alpha atual.
