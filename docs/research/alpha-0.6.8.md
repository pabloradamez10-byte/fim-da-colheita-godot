# Alpha 0.6.8 — controle e arte de sobrevivência

Base: Alpha 0.6.7, `70c72f7`. Data: 20/10/2026.

## O que mudou

- Entrada analógica linear, com zona morta de 8%, intensidade limitada a 1 e sem a suavização duplicada da 0.6.7.
- Direção de deslocamento relativa à câmera; velocidade diagonal limitada pelo controlador existente.
- Resposta planar direta; a parada não mantém uma cauda de aceleração.
- Gravidade, colisão e floor snap no controlador ativo. As políticas antigas de altura fixa e adesão por teletransporte são desativadas apenas para o novo personagem.
- Passos do jogador avançam pela distância efetivamente percorrida; ao pressionar contra uma parede o personagem para de caminhar visualmente.
- Mantidos os métodos de combate, equipamento, interação, veículos, necessidades, streaming, scheduler de IA e salvamento.
- Pack próprio de 16 ícones de inventário e cinco infectados com oito frames de caminhada por perfil.

## Arte e origem

Arquivos consumidos pelo jogo:

- `assets/items/fdc_item_atlas_068.png`: grade 4×4, fundo transparente. Madeira, pedra, fibra, comida, água, bandagem, antisséptico, munição 9 mm, cartuchos, tábuas, corda, lâmina de pedra, kit de reparo, gasolina, machadinha e facão.
- `assets/zombies/fdc_infected_atlas_068.png`: grade 8×5, fundo transparente. Errante, corredora, robusto, rural e operário.

Criados com a ferramenta integrada de geração de imagens. Para os infectados, uma imagem do APK oficial foi inspecionada e usada exclusivamente como referência de legibilidade, materiais e qualidade visual. O prompt exigiu personagens próprios, outras roupas e silhuetas, sem reproduzir máscara/suit da referência. Nenhum asset extraído do Last Day foi integrado ou incluído neste repositório.

Prompt do atlas de itens: criar uma grade transparente 4×4 de ícones originais de sobrevivência, um objeto por célula, vista elevada em três quartos, materiais naturais com desgaste e iluminação uniforme; objetos na ordem registrada acima; sem texto, marcas, molduras ou cenário.

Prompt do atlas de infectados: criar uma grade transparente 8×5 de personagens originais, cada linha com um ciclo de caminhada de oito frames, mesma câmera elevada em três quartos e pés alinhados; errante de jaqueta escura, corredora de conjunto bordô, robusto de colete marrom, trabalhador rural de camisa verde-azulada e operário de capacete amarelo/macacão azul; sem copiar o personagem de referência e sem violência gráfica.

## Verificação

Executado no Godot 4.3, em modo headless:

```sh
godot --headless --editor --import --path .
godot --headless --path . --script res://scripts/core/alpha_0_6_8_survival_test.gd
```

O teste cobre: contato com o chão, direção da câmera, distância equivalente a 30/60 ticks, intensidade parcial, parada, parede, animação bloqueada, plataforma elevada e queda, cena principal, ícones, infectados, preservação das interfaces de combate/performance e igualdade de estado após exportar/importar o salvamento.

Os 40 quadros dos infectados e as 16 células dos itens contêm pixels visíveis, com canal alfa preservado. A geração visual foi inspecionada.

O renderer dummy do Godot emitiu mensagens de mesh nulo e transformação fora da árvore no código herdado; não houve falha de script ou de asserção no teste. Isso não substitui QA visual em execução.

## Limites da versão

- É uma reconstrução própria orientada por evidências estáticas. Não demonstra paridade com Last Day em aparelho e não importa seu código.
- Os valores de velocidade, zona morta e passada são parâmetros do Fim da Colheita, não números alegadamente recuperados do Last Day.
- O pack de infectados tem uma vista em três quartos, espelhada horizontalmente. Não é um conjunto de oito direções nem inclui animações novas de ataque/morte.
- A arte e as animações do jogador continuam no pack anterior. A diferença de resolução em relação aos infectados ainda requer revisão visual.
- Os ícones são aplicados nas linhas de itens reconhecidos e nas armas machadinha/facão. Linhas adicionais criadas pelos módulos antigos (como gasolina) ainda podem aparecer apenas como texto.
- A IA permanece a do Fim da Colheita 0.6.7; a IA do Last Day não foi reconstruída nesta entrega.
- Teste no celular e APK Android devem ser conferidos separadamente pelo workflow 0.6.8.
