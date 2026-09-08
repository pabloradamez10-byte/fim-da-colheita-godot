# Alpha 0.5.30 — Veículos, transporte e logística

## Decisão

A 0.5.30 transforma os veículos que já existiam visualmente no mapa em um primeiro sistema funcional de **transporte e logística**, avançando o capítulo 29 da Bíblia sem descartar os assets e a geração procedural já aprovados.

O objetivo desta entrega é fechar o primeiro ciclo utilizável:

**encontrar veículo → inspecionar → abastecer/reparar → guardar carga → dirigir → sofrer risco de colisão → estacionar → persistir o estado.**

## Regras implementadas

- veículos urbanos e rurais passam a ser entidades físicas dirigíveis;
- os sprites 0.5.17 e a correção de orientação 0.5.18 continuam sendo utilizados;
- carcaça queimada permanece não dirigível, mas pode ter porta-malas;
- ao INTERAGIR perto de um veículo abre-se um painel próprio;
- painel mostra tipo, combustível, integridade e capacidade do porta-malas;
- o jogador pode entrar usando `DIRIGIR`;
- joystick mobile passa a controlar aceleração/recuo e esterço;
- durante condução, botões de ataque, arma e corrida são ocultados e INTERAGIR vira `SAIR`;
- a câmera continua seguindo o jogador porque sua posição é sincronizada com o veículo;
- cada classe tem velocidade, tanque, resistência e porta-malas diferentes;
- combustível é consumido pela distância percorrida;
- veículos encontrados começam com combustível e condição determinísticos pelo seed/chave;
- o item `gasoline` representa litros transportáveis na mochila ou porta-malas;
- abastecer consome 1 unidade de gasolina e adiciona 1 litro ao tanque;
- 1 kit de reparo recupera inicialmente 30% da integridade máxima;
- colisões em velocidade relevante causam dano ao veículo e produzem ruído;
- atropelar zumbis causa dano ao zumbi, também desgasta o veículo e produz ruído;
- veículo com integridade zero fica imobilizado;
- veículo sem combustível não acelera;
- veículos ativos protegem parcialmente o ocupante da exposição direta ao clima;
- porta-malas possui capacidade variável conforme o veículo;
- itens podem ser transferidos entre mochila e porta-malas;
- veículos ativados saem do ciclo de descarte do chunk e passam a existir como entidades persistentes do mundo;
- ao salvar, persistem posição, rotação, combustível, integridade e conteúdo do porta-malas;
- ao recarregar, o veículo reaparece na posição onde foi deixado, não no ponto procedural original;
- se o jogo for salvo durante condução, o sistema tenta restaurar o jogador dentro do mesmo veículo quando o save é carregado.

## Classes iniciais

- hatch;
- sedã;
- perua/utilitário;
- picape;
- furgão;
- caminhão baú;
- SUV;
- trator;
- carcaça queimada não dirigível.

Os valores de velocidade, tanque, resistência e porta-malas ainda são parâmetros de Alpha e serão balanceados em versões posteriores.

## Critérios de aceite 0.5.30

A versão só é considerada válida quando:

- a cena principal usa World, Player e Chunk Streamer 0.5.30;
- veículos antigos ainda exibem os sprites e orientação aprovados;
- um veículo pode ser convertido de objeto procedural em entidade persistente sem duplicar ao recarregar o chunk;
- painel mobile de veículo abre por INTERAGIR;
- entrar/esvaziar o veículo altera corretamente os controles mobile;
- joystick movimenta o veículo e reduz combustível;
- sair coloca o personagem ao lado do veículo e restaura colisão/visual/controles;
- porta-malas transfere itens nos dois sentidos respeitando capacidade;
- abastecimento consome gasolina da mochila;
- reparo consome kit e aumenta integridade;
- colisão reduz integridade;
- atropelamento usa o sistema de dano dos zumbis existente;
- posição, combustível, integridade e porta-malas sobrevivem a save/load;
- save anterior 0.5.29 continua carregável;
- regressões de casas, água, veículos visuais, clima, IA, crafting, construção, fogueira e sobrevivência hídrica continuam válidas;
- parser Godot, smoke tests e exportação Android passam no CI.

## Continuidade

Ficam para versões posteriores: partida/ignição detalhada, bateria, pneus, peças mecânicas individuais, mecânica avançada, portas e vidros do veículo, bancos/passagens, reboques, carga por peso/volume, postos/galões físicos, terreno influenciando tração, manutenção por componente e danos visuais no sprite.
