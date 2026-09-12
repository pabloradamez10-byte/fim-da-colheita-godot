# Alpha 0.5.40.5 — Character Sprite Pack

## Objetivo

Integrar ao runtime Android o novo sobrevivente visual aprovado, preservando os sistemas da 0.5.40.4.

## Entrega

- personagem em 8 direções;
- idle direcional;
- caminhada com 6 frames por direção;
- ações com 5 frames por direção;
- folhas para melee 1H/2H, arma de fogo 1H/2H, arco e coleta de animal;
- transparência real e atlas normalizado para Sprite3D;
- ataque melee ligado ao novo atlas;
- pacote restaurável por `tools/restore_character_sprite_pack_05405.py`;
- build Android dedicado e smoke test 0.5.40.5.

## Compatibilidade

A 0.5.40.5 herda o World Rework 0.5.40.3 e o Feedback & Audio 0.5.40.4. O corpo procedural continua oculto quando o Sprite3D do personagem está ativo.

## Teste esperado

No APK, validar principalmente escala do personagem, orientação nas oito direções, fluidez da caminhada e transição visual do ataque corpo a corpo.
