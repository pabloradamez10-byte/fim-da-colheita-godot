# Fim da Colheita — Alpha 0.1

## Estado atual

Esta entrega inaugura a primeira versão executável do projeto Godot e conecta a camada visual inicial à Atlas World Engine.

## Conteúdo implementado

- Projeto configurado para Godot 4.3 ou superior.
- Cena principal executável.
- Mapa isométrico procedural de 42 x 42 células.
- Geração determinística por seed.
- Sete tipos provisórios de terreno: água profunda, água rasa, área alagada, grama, solo fértil, solo seco e rocha.
- Distribuição procedural provisória de árvores, arbustos, rochas e troncos caídos.
- Carregamento dos arquivos JSON principais da AWE.
- Personagem provisório controlável.
- Câmera com acompanhamento suave.
- HUD com seed, quantidade de terrenos e quantidade de objetos.
- Regeneração do mundo durante o teste.

## Controles

- `WASD` ou setas: movimentação.
- `R`: gera novamente o mundo usando a seed seguinte.

## Objetivo técnico

Validar o ciclo mínimo:

1. Godot inicia o projeto.
2. A AWE carrega seus dados.
3. O gerador cria um mundo determinístico.
4. O mundo é desenhado em projeção isométrica.
5. O jogador consegue navegar pelo mapa.

## Limitações conhecidas

- Os gráficos são marcadores provisórios desenhados por código.
- Árvores, pedras e água ainda não possuem colisões funcionais.
- Não há coleta, inventário, construção, sobrevivência ou salvamento nesta entrega.
- A seleção de terreno ainda usa parâmetros internos do protótipo; a próxima etapa ligará integralmente as propriedades do DataCore.
- O projeto ainda precisa ser aberto em uma instalação Godot para validação visual e correção de eventuais diferenças de versão.

## Próximas etapas do Alpha 0.1

### Marco 2 — Interação

- colisão de terreno e objetos;
- sistema de interação;
- coleta de madeira e pedra;
- inventário simples;
- mensagens de ação.

### Marco 3 — Sobrevivência básica

- receita da fogueira;
- construção da fogueira;
- ciclo de tempo inicial;
- salvamento e carregamento do mundo;
- tela simples de início.

## Critério para declarar Alpha 0.1 concluído

O Alpha 0.1 será considerado concluído quando o jogador puder entrar em um mundo gerado por seed, caminhar, coletar madeira e pedra, fabricar uma fogueira e salvar o progresso.
