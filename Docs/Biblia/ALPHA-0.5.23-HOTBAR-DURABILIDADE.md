# Alpha 0.5.23 — Hotbar, durabilidade e reparo de equipamento

## Decisão

A 0.5.23 inicia o bloco de **crafting/equipamentos** priorizado na Bíblia. O objetivo é tirar armas e consumíveis de um uso abstrato de inventário e fazê-los participar diretamente do loop de sobrevivência mobile.

## Regras implementadas

- hotbar com até **6 slots rápidos** no HUD mobile;
- armas possuídas entram primeiro na hotbar, seguidas por consumíveis disponíveis;
- tocar em uma arma equipa o item imediatamente;
- tocar em bandagem, água, comida ou antisséptico usa o item sem abrir a mochila;
- teclas 1–6 também ativam os slots em desktop/teste;
- armas e ferramentas passam a ter **durabilidade individual persistente**;
- facão, machadinha, lança, pistola e espingarda possuem durabilidades máximas e desgaste próprios;
- somente ataques efetivamente executados consomem durabilidade;
- armas quebradas podem continuar equipadas, mas não atacam até serem reparadas;
- HUD de equipamento mostra a durabilidade da arma ativa;
- a tela de mochila mostra durabilidade de cada arma;
- reparos de campo consomem recursos existentes (madeira, pedra e fibra) e recuperam uma fração da durabilidade;
- armas produzidas por craft recebem durabilidade cheia ao serem criadas;
- durabilidade é preservada no save existente e continua após morte/respawn;
- clima, sono, infecção, loot, casas, veículos e mundo procedural permanecem intactos.

## Critérios de aceite

- cena principal usa Player/World 0.5.23 e HotbarUI 0.5.23;
- existem seis botões de hotbar no mobile;
- hotbar apresenta apenas armas possuídas e consumíveis com quantidade maior que zero;
- ativar arma pela hotbar equipa a arma;
- ativar consumível reduz a pilha e aplica o efeito;
- ataque bem-sucedido reduz durabilidade da arma ativa;
- ataque bloqueado/falhado não desgasta arma;
- durabilidade zero bloqueia ataque;
- reparo consome recursos e aumenta durabilidade;
- craft de machadinha/lança registra durabilidade inicial;
- salvar/carregar preserva os valores de durabilidade;
- regressões críticas 0.5.16, 0.5.18, 0.5.19 e 0.5.22 continuam passando;
- parser Godot e exportação Android passam no CI.

## Relação com a Bíblia

Avança diretamente:

- Inventário, Itens e Crafting;
- Armas, Ferramentas e Combate;
- Interface e Experiência Mobile;
- Progressão baseada em recursos e manutenção.

Ainda ficam para versões seguintes: slots corporais/roupas, peso e volume, qualidade de itens, bancadas, receitas avançadas, componentes mecânicos e construção/base.
