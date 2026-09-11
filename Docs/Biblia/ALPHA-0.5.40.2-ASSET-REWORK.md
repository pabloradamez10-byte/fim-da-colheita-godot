# Alpha 0.5.40.2 — Asset Rework

## Objetivo

Elevar a leitura visual dos elementos que ainda denunciavam a origem de protótipo, sem alterar o balanceamento ou remover sistemas consolidados nas versões anteriores.

## Personagem do jogador

- O corpo procedural de caixas/esferas deixa de ser a apresentação principal.
- O runtime Android passa a usar o conjunto detalhado `CHR_M_SURVIVOR_0001` já existente na biblioteca do projeto.
- São quatro vistas cardeais: N, E, S e W.
- A direção visual acompanha o yaw real do jogador.
- Movimento recebe bob/squash discreto para evitar aparência totalmente estática.
- Colisão, inventário, combate, caça, equipamento, progressão, sobrevivência e persistência continuam no `player_3d_v0538.gd` por herança.

## Zumbis

- Mantidos os cinco perfis de Zumbis 2.0: errante, corredor, robusto, rural e operário.
- Mantidos oito frames de animação por perfil; os oito frames continuam sendo **frames de animação**, não oito direções.
- Novo atlas vetorial com células de 96×128, aumentando definição e silhueta em relação ao atlas 64×96 anterior.
- Perfis recebem roupas, proporções, ferimentos e marcas visuais distintas.
- Hordas, migração, audição, perseguição, pressão em portas/janelas/base e persistência não mudam.

## Itens

- Novo atlas vetorial 4×4, com 16 ícones em células de 64×64.
- Cobertura inicial: facão, machado, lança, pistola, espingarda, bandagem, água, comida, antisséptico, carne crua de caça, carne assada, couro, penas, madeira, pedra e fibra.
- Os ícones são integrados à hotbar da 0.5.40.1 sem remover nomes, quantidades, durabilidade ou ativação por toque/teclas.

## Compatibilidade preservada

- HUD, controles mobile e hotbar-base da 0.5.40.1.
- Frota de 40 veículos × 8 direções.
- Fauna de 4 espécies × 8 direções.
- Zumbis 2.0 e suas quatro hordas.
- Animais & Caça.
- Sociedade Humana Inicial.
- Atlas Decision Engine 0.5.40.
- Missões, crafting, construção, agricultura, alimentação, vestuário, loot, veículos e save.

## Persistência

A versão de save passa para `0.5.40.2-alpha` e registra:

- `asset_rework_05402 = true`;
- `player_art_05402 = survivor-4dir-hd`;
- `zombie_art_05402 = 96x128x5x8-vector`;
- `item_art_05402 = 64x64x16-vector`.

## Critérios de aceite

1. Projeto importa no Godot sem `SCRIPT ERROR`, `Parse Error`, corrupção ou recurso ausente.
2. Jogador usa uma única apresentação visual detalhada e o corpo procedural antigo fica oculto.
3. Pelo menos dez zumbis instanciados usam o novo atlas, preservando 5 perfis × 8 frames.
4. Hotbar possui seis slots e acesso ao atlas com 16 ícones.
5. Veículos 40×8 e animais 4×8 continuam íntegros.
6. Decision Engine, sociedade e missões continuam disponíveis.
7. Save é gravado como `0.5.40.2-alpha`.
8. Suíte de regressão e exportação Android ficam verdes antes da entrega do APK.
