# Auditoria web — Alpha 0.2.6

## Escopo

Auditoria e estabilização da versão web existente, preservando mapa por seed, movimentação, personagem direcional, coleta, inventário resumido, fogueira automática, save local e controles móveis.

## Problemas encontrados

- `index.html` carregava `app-clean.js`, uma cópia comprimida, enquanto `app.js` continha outra versão legível e desatualizada.
- `app-clean.js` e `app.js` duplicavam quase toda a lógica do jogo.
- Os PNGs eram buscados por URLs absolutas de `raw.githubusercontent.com`, desnecessárias no GitHub Pages.
- O carregamento inicial gerava e salvava um mundo antes de tentar restaurar o save existente, sobrescrevendo o progresso.
- Erros de `localStorage` eram ignorados ou não informados ao jogador.
- O save não validava a posição do jogador nem a lista de objetos.
- O spawn podia avançar para fora da linha do mapa ao procurar terreno caminhável.
- O CSS estava comprimido em uma única linha, dificultando manutenção.
- O documento de upload do personagem descreve um spritesheet único antigo, mas a implementação atual utiliza quatro PNGs direcionais.
- `objects.png`, `player_walk.png` e `tileset.png` permanecem no repositório, porém não são carregados pela versão ativa.

## Correções desta etapa

- `app.js` passa a ser a única entrada JavaScript ativa.
- Assets ativos usam caminhos relativos compatíveis com GitHub Pages.
- Falhas de PNG mantêm os fallbacks vetoriais e ficam visíveis no status.
- O tile real de grama continua recortado dentro do losango isométrico.
- O fluxo de inicialização preserva saves válidos existentes.
- Save e carregamento receberam tratamento de erro e validação básica.
- A busca de spawn caminhável ficou limitada ao mapa.
- A versão visível foi atualizada para `0.2.6`.

## Legado preservado

`app-clean.js` e os PNGs antigos não foram apagados nesta etapa. Eles deixaram de participar do carregamento ativo e poderão ser removidos somente após validação da versão estabilizada.

## Pendências planejadas

- Centralizar todo carregamento no `AssetManager` da Etapa 3.
- Modularizar a versão web na Etapa 2.
- Atualizar a documentação antiga do spritesheet direcional.
- Implementar culling de tiles visíveis e outras melhorias de desempenho na etapa correspondente.
- Validar visualmente o projeto Godot em ambiente com Godot 4.3 ou superior.
