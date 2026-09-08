# Alpha 0.5.33 — Vestuário e Proteção Corporal

## Objetivo

Transformar equipamento em um sistema corporal funcional, conectando loot, inventário, ataques de zumbis, clima, peso e persistência sem romper os ciclos consolidados até a 0.5.32.1.

## Implementado

### Slots corporais

O sobrevivente passa a possuir seis slots independentes:

- cabeça;
- tronco;
- mãos;
- pernas;
- pés;
- costas.

A roupa inicial civil é composta por camiseta, jeans, tênis e mochila escolar. Cabeça e mãos começam livres.

### Peças disponíveis

- boné;
- capacete de moto;
- camiseta;
- moletom;
- jaqueta impermeável;
- luvas de trabalho;
- calça jeans;
- calça cargo;
- tênis;
- botas de trabalho;
- mochila escolar;
- mochila cargueira.

Cada peça define atributos próprios de proteção contra mordida, corte, frio e chuva, além de peso. Mochilas também possuem bônus de capacidade preparado para integração com a evolução do sistema de carga.

### Proteção contra zumbis

Ataques de zumbi passam pelo conjunto equipado antes de atingir o corpo. O tipo do ataque usa proteção de mordida ou corte conforme a variante do inimigo. A redução de dano também reduz, por consequência, a severidade de dor, sangramento e exposição à infecção já existentes no loop de saúde.

A proteção é limitada por teto de balanceamento para impedir invulnerabilidade.

### Clima

O vestuário foi conectado aos sistemas existentes da Alpha 0.5.21 e 0.5.22:

- isolamento térmico reduz a tendência de queda de temperatura corporal em ambiente frio;
- proteção contra chuva reduz a velocidade de acúmulo de umidade;
- abrigo continua funcionando normalmente e pode se somar ao vestuário.

### Peso

O peso total das peças equipadas é calculado continuamente. Conjuntos pesados acima do limiar inicial aumentam consumo de fôlego e cansaço durante deslocamento, criando troca real entre proteção e mobilidade.

### Loot de roupas

O sistema de loot contextual das casas agora também pode entregar vestuário:

- guarda-roupas: principal fonte de roupas e mochilas;
- quartos: roupas civis e mochilas menores;
- banheiro/armário de remédios: chance de luvas;
- sala: baixa chance de mochila.

O loot continua determinístico por seed/chave do mundo.

### Interface mobile

A mochila ganhou uma quarta coluna de VESTUÁRIO com:

- visualização dos seis slots;
- botão para equipar;
- botão para tirar;
- itens disponíveis na mochila;
- proteção acumulada contra mordida/corte;
- proteção contra frio/chuva;
- peso equipado;
- bônus de carga da mochila.

O painel usa escala responsiva para caber em telas mobile e preserva a correção de aspect ratio da 0.5.32.1.

### HUD

O resumo do equipamento corporal aparece junto ao equipamento ativo, exibindo proteção e peso sem aumentar novamente a altura do HUD superior compactado na 0.5.32.1.

### Persistência

O save 0.5.33 registra:

- seis slots corporais;
- peças soltas no inventário;
- trocas de roupa;
- dano bloqueado;
- contador de ataques protegidos;
- loot de vestuário encontrado.

Saves anteriores são migrados adicionando apenas os campos ausentes.

## Critérios de aceite automatizados

O smoke test 0.5.33 valida:

1. Player e World 0.5.33 carregam na cena principal;
2. a interface de vestuário existe no inventário;
3. equipamento inicial é criado corretamente;
4. trocar uma peça devolve a peça anterior para a mochila;
5. proteção de chuva aumenta ao equipar jaqueta apropriada;
6. o mesmo ataque causa menos dano com conjunto protetor;
7. dano bloqueado é contabilizado;
8. isolamento e impermeabilidade afetam os hooks reais de clima;
9. peso elevado cobra fôlego/cansaço;
10. guarda-roupas entregam vestuário;
11. slots e contadores sobrevivem ao save/reload;
12. regressões das Alphas anteriores continuam verdes.

## Lacunas deixadas para evolução

- durabilidade e rasgos individuais das roupas;
- sujeira e sangue nas peças;
- camadas simultâneas no mesmo segmento corporal;
- temperatura/calor excessivo por roupa pesada;
- capacidade de carga realmente variável por mochila;
- representação visual das roupas no sprite do personagem;
- reparo, costura e fabricação de vestuário;
- proteção localizada por membro e ferimento corporal específico.

Essas lacunas não bloqueiam a Alpha 0.5.33: o ciclo mínimo de encontrar roupa → equipar → sofrer efeito em combate/clima/peso → salvar está completo.
