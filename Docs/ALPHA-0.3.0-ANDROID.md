# Fim da Colheita — Alpha Android 0.3.0

## Objetivo

Transformar o primeiro mundo técnico Godot/AWE em uma fatia jogável offline para Android sem descartar a arquitetura existente.

## Loop jogável desta etapa

1. O mundo procedural é criado ou restaurado pela seed salva.
2. O jogador explora usando teclado ou joystick virtual.
3. Recursos naturais próximos podem ser coletados pelo botão **PEGAR**.
4. Madeira, pedra e fibra entram no inventário básico e persistem no save.
5. Zumbis surgem em terreno caminhável, percebem o jogador e perseguem quando ele entra no raio de detecção.
6. O jogador usa ataque corpo a corpo pelo botão **ATACAR**.
7. Corrida consome fôlego e o sistema de fome/sede continua simulando sobrevivência.
8. O jogo salva automaticamente e também quando recursos são coletados.

## Sistemas incluídos

- controles touch em tela;
- suporte simultâneo a teclado para desenvolvimento;
- vida, fome, sede e stamina;
- corrida;
- ataque corpo a corpo;
- zumbi básico com detecção, perseguição, ataque, dano e morte;
- coleta contextual simples;
- inventário inicial de madeira, pedra e fibra;
- persistência de seed, posição, necessidades, inventário e recursos já coletados;
- autosave a cada 20 segundos;
- export preset Android Debug;
- workflow de CI para gerar APK debug da branch da Alpha 0.3.0.

## Fora desta etapa

Ainda não estão sendo marcados como concluídos: armas equipáveis, armas de fogo, ferimentos por parte do corpo, loot de casas, construção, crafting completo, veículos, NPCs, migração de zumbis, cidades e pontos de interesse complexos.

Esses sistemas entram por cima deste loop após a validação de jogabilidade e desempenho no aparelho real.

## Critérios de aceite da 0.3.0

- projeto abre e importa no Godot 4.3 sem erro fatal;
- personagem se move por teclado e por touch;
- botão de corrida altera velocidade e consome stamina;
- botão de ataque pode matar um zumbi próximo;
- zumbi detecta, persegue e causa dano;
- botão de coleta remove um recurso próximo e incrementa inventário;
- fechar/reabrir preserva posição, seed, necessidades, inventário e recursos coletados;
- APK debug é produzido pelo pipeline Android;
- jogo permanece offline, sem backend obrigatório.
