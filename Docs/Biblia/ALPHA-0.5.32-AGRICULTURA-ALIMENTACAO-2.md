# Alpha 0.5.32 — Agricultura e Alimentação 2.0

## Decisão

A 0.5.32 deixa de tratar agricultura como sistema isolado e conecta **plantio, colheita, fome, validade e fogueira** em um mesmo ciclo de sobrevivência.

O ciclo passa a ser:

**escolher cultura → plantar → irrigar/esperar chuva → colher → comer cru ou cozinhar → consumir antes de estragar.**

## Culturas

A agricultura passa a trabalhar com três culturas distintas:

- batata;
- milho;
- cenoura.

Cada cultura possui:

- semente própria;
- tempo de crescimento próprio;
- rendimento próprio;
- retorno de sementes após a colheita;
- visual próprio no canteiro;
- alimento correspondente no inventário.

O jogador seleciona a cultura ativa pela mochila. Ao interagir com um canteiro preparado, o sistema usa a semente da cultura selecionada; se ela estiver indisponível, procura automaticamente outra cultura com semente disponível para evitar travamento do fluxo no mobile.

## Alimentação

Os produtos agrícolas passam a ser consumíveis diretamente.

Alimentos crus atuais:

- batata;
- milho;
- cenoura.

A quantidade recuperada de fome varia por alimento e pelo estado de conservação.

Cenoura também recupera pequena quantidade de hidratação e ensopado recupera fome e água.

## Cozinha na fogueira

A fogueira existente também passa a ser estação de cozinha, sem criar uma bancada paralela.

Receitas iniciais:

- **Batata assada** — 1 batata, 8 min de combustível;
- **Milho assado** — 1 milho, 8 min de combustível;
- **Ensopado de legumes** — 1 batata + 1 milho + 1 cenoura + 1 água, 18 min de combustível, produz 2 porções.

A receita só pode ser executada quando:

- o jogador está próximo da fogueira;
- a fogueira está acesa;
- existe combustível suficiente;
- todos os ingredientes estão disponíveis.

A cozinha consome o combustível real da mesma fogueira usada para calor, iluminação, ruído e purificação de água.

## Frescor e validade

Os alimentos agrícolas e preparados passam a possuir frescor de 0 a 100%.

Tempos iniciais de validade em tempo de jogo:

- batata crua: 3 dias;
- milho cru: 2 dias;
- cenoura crua: 2,5 dias;
- batata assada: 1 dia;
- milho assado: 18 horas;
- ensopado: 12 horas.

Ao atingir zero de frescor, a pilha é convertida em **comida estragada**.

Comer alimento muito velho aumenta risco de mal-estar. Comer comida estragada provoca forte intoxicação alimentar, que pode reduzir fôlego, fome, sede e vida conforme a gravidade.

## Mobile/UI

- a mochila passa a mostrar sementes das três culturas;
- o jogador pode selecionar qual cultura deseja plantar;
- alimentos mostram quantidade e frescor;
- alimentos podem ser consumidos diretamente pela mochila;
- a lista de itens passa a ser rolável para acomodar a expansão do inventário;
- o painel da fogueira passa a exibir as três receitas de cozinha e bloqueia automaticamente receitas sem ingredientes/fogo/combustível.

## Persistência

O save 0.5.32 preserva:

- cultura selecionada;
- cultura de cada canteiro;
- crescimento e umidade;
- totais colhidos por cultura;
- alimentos e sementes;
- frescor das pilhas;
- intoxicação alimentar;
- refeições consumidas;
- refeições preparadas;
- quantidade de alimentos estragados;
- quantidade de lotes cozidos na fogueira.

Saves anteriores 0.5.31 são migrados tratando cultivos antigos em andamento como batata.

## Continuidade

Ficam para versões posteriores:

- fertilidade e qualidade do solo;
- ferramentas agrícolas específicas;
- fertilizantes;
- pragas e doenças de cultura;
- estações do ano afetando plantio;
- mais culturas;
- conservação por sal, lata e desidratação;
- geladeira/freezer e energia elétrica;
- receitas complexas e utensílios;
- caça, pesca e criação animal.

## Critérios de aceite

A 0.5.32 só é válida quando:

- milho e cenoura podem ser selecionados, plantados, amadurecidos e colhidos;
- os tempos de crescimento diferem por cultura;
- alimentos crus recuperam fome;
- a fogueira cozinha pelo menos batata assada, consumindo combustível;
- frescor diminui com tempo de jogo;
- alimento vencido vira comida estragada;
- save/load preserva agricultura, seleção de cultura, alimentos, frescor e contadores;
- veículos, água, clima, casas, crafting, construção e demais regressões continuam válidos;
- parser Godot, smoke tests e exportação Android passam no CI.
