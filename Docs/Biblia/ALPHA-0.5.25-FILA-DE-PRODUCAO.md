# Alpha 0.5.25 — Fila de produção, tempo e ferramentas

## Decisão

A 0.5.25 aprofunda o capítulo **23 — Crafting, Produção e Manufatura**. A fabricação deixa de ser instantânea e passa a representar trabalho: receitas entram em uma fila, levam tempo real para terminar e algumas dependem de uma ferramenta funcional.

O objetivo é transformar a bancada e o craft de campo em decisões de preparação, e não em simples conversão imediata de números no inventário.

## Fila de produção

- capacidade inicial: **4 trabalhos**;
- o jogador adiciona receitas à fila pela interface de crafting;
- a ordem da fila é FIFO: o primeiro trabalho é processado primeiro;
- materiais de trabalhos aguardando são considerados reservados para impedir sobrealocação;
- os materiais **não são debitados ao clicar** em adicionar;
- o débito ocorre apenas quando o trabalho chega à frente e realmente inicia;
- trabalhos iniciados permanecem persistidos com o tempo restante.

## Tempos iniciais

- Bandagem: 3 s;
- Corda improvisada: 4 s;
- Lança: 6 s;
- Lâmina de pedra: 6 s;
- Machadinha: 8 s;
- Tábuas preparadas: 8 s;
- Kit de reparo: 12 s;
- Revisão completa de equipamento: 10 s.

Esses valores são parâmetros de alpha e poderão ser balanceados posteriormente.

## Ferramentas obrigatórias

Algumas receitas passam a exigir uma ferramenta existente e não quebrada:

- Lança: Facão;
- Corda improvisada: Facão;
- Tábuas preparadas: Machadinha;
- Lâmina de pedra: Facão;
- Kit de reparo: Machadinha.

A ferramenta não é consumida, mas recebe desgaste leve ao concluir o trabalho. Uma ferramenta quebrada não atende ao requisito.

## Bancada e pausa

- trabalhos de campo continuam progredindo fora da bancada;
- trabalhos marcados como **BANCADA** exigem que o personagem permaneça próximo à estação;
- se o jogador se afasta, o trabalho iniciado é pausado sem perder o progresso;
- ao retornar, a produção continua do ponto em que parou;
- a bancada mostra um indicador 3D simples com o trabalho atual e o tempo restante.

## Revisão de equipamento

A revisão completa da 0.5.24 entra na mesma lógica de produção:

- exige bancada;
- reserva e depois consome 1 kit de reparo quando o trabalho começa;
- dura 10 segundos;
- restaura a arma/ferramenta a 100% apenas ao término.

O reparo de campo da 0.5.23 continua disponível de forma imediata e parcial.

## Interface mobile

- botão de craft passa a indicar **ADICIONAR À FILA**;
- cada receita mostra tempo de produção;
- receitas que exigem ferramenta mostram qual ferramenta é necessária;
- ferramenta ausente ou quebrada bloqueia a entrada na fila;
- a interface mostra tamanho da fila, trabalho atual, estado e segundos restantes;
- estados possíveis incluem produzindo, aguardando bancada, aguardando ferramenta e aguardando materiais.

## Persistência

São persistidos:

- trabalhos enfileirados;
- trabalhos já iniciados;
- tempo restante;
- estado da fila;
- contador de trabalhos concluídos;
- serial interno da fila.

Saves anteriores continuam válidos e recebem fila vazia por padrão.

## Critérios de aceite 0.5.25

A versão só é considerada válida quando:

- a cena principal usa Player/World/Inventory UI 0.5.25;
- existe uma fila com capacidade de quatro trabalhos;
- adicionar uma receita não consome os materiais imediatamente;
- o primeiro avanço da produção consome os materiais apenas ao iniciar o trabalho;
- um trabalho não entrega o resultado antes do tempo terminar;
- trabalhos de bancada pausam ao sair do alcance e retomam ao voltar;
- ferramentas obrigatórias bloqueiam receita quando ausentes ou quebradas;
- a ferramenta recebe desgaste leve após concluir a produção;
- reservas da fila impedem que o mesmo material seja prometido para trabalhos incompatíveis;
- revisão completa entra na fila e só restaura 100% ao concluir;
- fila iniciada e tempo restante persistem no save;
- hotbar, durabilidade, clima, casas, água, veículos e IA dos zumbis continuam sem regressão;
- parser Godot, smoke tests e exportação Android passam no CI.

## Continuidade

Ainda ficam para versões posteriores: cancelamento com regras de reembolso, múltiplas bancadas independentes, qualidade de fabricação, níveis de habilidade, ferramentas especializadas, energia, máquinas, receitas aprendidas e construção de estações pelo jogador.
