# AWE Preview 0.5.5 — Versão Web

Primeiro protótipo web jogável de **Fim da Colheita**, criado para validação no navegador do celular antes da disponibilidade de um computador com Godot.

## Recursos atuais

- mapa isométrico procedural por seed;
- seis tipos de terreno;
- árvores, pedras e arbustos procedurais;
- movimentação por teclado e controles móveis;
- bloqueio de passagem pela água;
- coleta de madeira e pedra;
- crafting automático da primeira fogueira;
- salvamento local no navegador;
- interface responsiva para celular.
- seis variações oficiais de grama escolhidas de forma determinística pela seed;
- propriedades de terreno centralizadas no Terrain Manager.
- câmera centralizada e suavizada;
- renderização limitada aos tiles e objetos próximos da área visível;
- ordenação de profundidade e pivô de sprites baseados no chão.
- onze pisos adicionais: solos, lama, cascalho, rocha, areia, vias e duas profundidades de água;
- árvore, arbusto e pedras oficiais com transparência real e fallback vetorial.
- mundo ampliado para 64 x 64 tiles com biomas interpolados em manchas contínuas.
- bordas de bioma suavizadas e variações de piso mais discretas;
- bosques, clareiras, arbustos e pedras distribuídos por zonas ecológicas.
- grade visual removida para unir os tiles e suavizar as formas do terreno;
- saves antigos migrados e objetos validados para impedir árvores ou pedras dentro da água.
- sobrevivente-base redesenhado em quatro direções conforme a Bíblia de Arte, sem mochila ou equipamento fixo.

## Arquitetura

A versão ativa utiliza módulos JavaScript nativos em `web/js/`. A entrada única é `web/js/main.js`; os antigos `app.js` e `app-clean.js` permanecem apenas como legado inativo durante a validação.

Consulte `Docs/WEB-ARCHITECTURE.md` para conhecer a divisão de responsabilidades.

## Como executar

Abra `web/index.html` através de um servidor estático ou publique a pasta `web` em GitHub Pages, Vercel ou Netlify.

## Controles

- Celular: botões direcionais e botão **COLETAR**.
- Computador: WASD/setas para mover; E ou Espaço para coletar.

## Escopo do próximo marco

- colisão com objetos sólidos;
- indicador visual do alvo de coleta;
- inventário expansível;
- fogueira posicionada no mapa;
- ciclo simples de tempo;
- primeiros zumbis e animais.
