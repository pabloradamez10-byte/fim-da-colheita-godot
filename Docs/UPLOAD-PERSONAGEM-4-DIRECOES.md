# Upload do personagem completo — Alpha web

O código do Alpha já está preparado para carregar um único PNG com quatro direções.

## Nome obrigatório

`CHR_M_SURVIVOR_0001_IDLE_4DIR.png`

## Caminho obrigatório

`web/assets/characters/CHR_M_SURVIVOR_0001_IDLE_4DIR.png`

## Organização horizontal dos quadros

Da esquerda para a direita:

1. Frente / Sul (`down`)
2. Direita / Leste (`right`)
3. Costas / Norte (`up`)
4. Esquerda / Oeste (`left`)

Todos os quadros devem ter exatamente a mesma largura.

## Requisitos visuais

- corpo inteiro, incluindo cabeça e pés;
- fundo PNG realmente transparente;
- sem textos, títulos, linhas ou molduras;
- mesma escala em todos os quadros;
- pés alinhados na mesma linha de chão;
- personagem centralizado em cada quadro;
- roupas e acessórios idênticos nas quatro direções;
- nenhuma parte cortada nas bordas;
- mochila e facão coerentes ao girar o personagem.

## Comportamento do Alpha

O arquivo `web/app.js` detecta automaticamente o PNG. Enquanto ele não existir, o jogo usa o personagem vetorial antigo como fallback e mostra `aguardando PNG 4-dir` no status.

Quando o PNG for enviado corretamente, o status muda para `sprite 4-dir ativo`, e a direção exibida acompanha o movimento do jogador.