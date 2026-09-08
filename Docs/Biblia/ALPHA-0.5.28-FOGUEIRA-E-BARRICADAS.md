# Alpha 0.5.28 — Fogueira, iluminação e barricadas

## Decisão

A 0.5.28 continua o capítulo **22 — Construção e Engenharia** e conecta a base ao capítulo de sobrevivência. A construção passa a oferecer duas novas utilidades sistêmicas: **defesa passiva** e **calor/luz controlados por combustível**.

## Novas peças

- **Barricada de espigões** — 5 madeiras + 1 corda;
- **Fogueira** — 4 pedras + 2 madeiras.

As seis peças da 0.5.27 continuam disponíveis: piso, parede, porta, cerca, portão e caixa.

## Barricada

A barricada é uma peça defensiva de baixa altura e grande resistência:

- integridade máxima: 220;
- colisão física;
- pode bloquear avanço dos zumbis;
- zumbis continuam causando dano à barricada quando tentam atravessá-la;
- cada ataque contra os espigões devolve dano ao zumbi agressor;
- pode ser reparada e desmontada pelas mesmas regras da 0.5.27;
- posição, rotação e integridade são persistidas.

A barricada não substitui paredes ou portões: ela é uma defesa de desgaste, capaz de ferir ameaças enquanto também perde integridade.

## Fogueira

A fogueira é uma estrutura utilitária persistente:

- integridade máxima: 80;
- não cria degrau físico bloqueante;
- INTERAGIR próximo abre um painel próprio;
- 1 madeira adiciona 60 minutos de combustível;
- capacidade máxima inicial: 360 minutos;
- pode ser acesa ou apagada sem perder o combustível restante;
- quando o combustível termina, apaga automaticamente;
- chuva aumenta o consumo de uma fogueira exposta em aproximadamente 35%;
- combustível e estado aceso/apagado ficam no save.

## Calor e iluminação

Quando acesa, a fogueira:

- cria iluminação quente local no mundo 3D;
- torna a área da base legível durante a noite;
- aumenta a temperatura efetiva do personagem num raio inicial de 7,5 m;
- o bônus térmico é maior perto do fogo e diminui com a distância;
- interage com o sistema de temperatura corporal já existente.

Assim, uma noite fria ou chuvosa passa a poder ser enfrentada usando recursos da própria base.

## Risco da luz/fogo

A fogueira não é benefício gratuito. Em intervalos regulares o fogo gera um evento sonoro leve (`campfire`) no sistema de ruído da 0.5.19. Zumbis próximos podem investigar a área.

A intenção é criar a decisão: **calor e visibilidade em troca de combustível e maior exposição**.

## Interface mobile

O painel CONSTRUIR passa de seis para oito peças e usa duas linhas para manter legibilidade no celular.

A fogueira possui painel próprio com:

- estado ACESA/APAGADA;
- combustível restante em minutos;
- botão ACENDER/APAGAR;
- botão +1 LENHA;
- bloqueio de acendimento sem combustível;
- bloqueio de abastecimento ao atingir a capacidade máxima.

## Critérios de aceite 0.5.28

A versão só é considerada válida quando:

- World/Player/Zombie 0.5.28 são utilizados pela cena principal;
- painel de construção apresenta oito peças;
- barricada possui colisão, 220 de integridade e integração com reparo/desmontagem;
- zumbis 0.5.28 possuem retaliação registrada para ataques contra barricadas;
- fogueira pode ser construída sem criar bloqueio alto no chão;
- INTERAGIR abre o painel da fogueira;
- madeira adiciona combustível e é descontada da mochila;
- acender torna chama e OmniLight visíveis;
- apagar preserva combustível;
- passar do tempo reduz combustível e zero apaga o fogo;
- chuva acelera consumo de fogo exposto;
- fogueira acesa aumenta a temperatura efetiva nas proximidades;
- fogo produz evento de ruído capaz de entrar no sistema de audição dos zumbis;
- combustível e estado da fogueira sobrevivem a salvar/carregar;
- sistemas de porta/portão, integridade, reparo, desmontagem, armazenamento, crafting, clima, água e veículos não regridem;
- parser Godot, smoke tests e exportação Android passam no CI.

## Continuidade

Ficam para as próximas versões: barricadas aplicadas diretamente em portas/janelas, telhados construíveis, captação de água da chuva, bancada construível pelo jogador, iluminação elétrica, gerador/bateria, armadilhas avançadas e fortificações pesadas.
