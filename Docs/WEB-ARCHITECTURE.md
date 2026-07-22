# Arquitetura web — Alpha 0.3.1

## Entrada

`web/js/main.js` é a única entrada ativa da versão web. Ele cria as dependências do jogo e inicia a aplicação.

## Módulos atuais

- `core/`: orquestração, eventos, inputs, assets e persistência.
- `world/`: geração determinística do mundo.
- `entities/`: entidades com estado próprio, iniciando pelo jogador.
- `systems/`: regras de inventário e interação.
- `rendering/`: projeção e desenho isométricos.
- `data/`: catálogos declarativos de terrenos e assets.

## Fluxo

1. `main.js` cria os gerenciadores.
2. `Game` gera o mundo pela seed e restaura um save válido.
3. `AssetManager` carrega os PNGs cadastrados.
4. `InputManager` converte teclado e botões móveis em comandos.
5. Os sistemas atualizam o estado.
6. `Renderer` desenha o estado no canvas.
7. `SaveManager` persiste mudanças relevantes.

## Compatibilidade

Os módulos usam JavaScript nativo do navegador, sem biblioteca externa e com caminhos relativos compatíveis com GitHub Pages.

`web/app.js` e `web/app-clean.js` foram preservados como legado inativo até que a versão modular seja validada visualmente.

## Asset Manager

Os assets são registrados por ID em `data/assetCatalog.js`. O gerenciador:

- aceita imagens e está preparado para JSON e áudio;
- evita solicitações duplicadas durante e depois do carregamento;
- informa progresso pelo `EventBus`;
- registra falhas sem impedir a inicialização;
- aplica cache busting centralizado e controlado;
- expõe `getImage(assetId)` para a renderização;
- mantém caminhos relativos compatíveis com GitHub Pages.

Quando um PNG não carrega, o renderizador mantém o fallback vetorial do personagem ou a cor do terreno.
