# Alpha 0.5.40.3 — World Rework

## Objetivo

A 0.5.40.3 amplia o Asset Rework iniciado na 0.5.40.2 para o cenário jogável. O foco é eliminar a leitura visual excessivamente simples de blocos urbanos e rurais sem substituir ou quebrar as interações, colisões, portas, loot, veículos, fauna, zumbis, missões ou persistência já existentes.

## Escopo implementado

### Casas urbanas

- duas janelas frontais com vidro escuro, peitoril e molduras;
- marquise de entrada;
- luminária de varanda;
- rodapé externo;
- medidor lateral;
- chaminé vinculada ao nó de telhado e ao sistema de cutaway existente;
- variação de cores da marquise derivada do lote.

### Ruas

- grelhas de drenagem nas vias periféricas dos superblocos;
- placas com ranhuras visuais;
- remendos de asfalto;
- vegetação rasteira surgindo junto ao desgaste urbano;
- nenhuma alteração nas colisões ou navegação das ruas.

### Lotes e props

- caixas de correio residenciais;
- pequenos agrupamentos de arbustos;
- distribuição determinística a partir da seed e do marcador do lote.

### POIs

O sistema existente de Posto Médico, Mercado, Oficina, Delegacia e Fazenda é preservado e recebe identidade visual adicional:

- Posto Médico: cruz frontal;
- Mercado: marquise listrada;
- Oficina: cabeçalho e ripas de fachada;
- Delegacia: cabeçalho e sinalizador;
- Fazenda: tanque metálico contextual.

### Zona rural

- caixa d'água elevada com estrutura de madeira;
- varal com tecido;
- detalhes adicionais sem colisão para preservar a circulação.

## Compatibilidade preservada

A 0.5.40.3 continua utilizando e validando:

- personagem HD em quatro direções da 0.5.40.2;
- cinco perfis de zumbis com oito frames por perfil;
- 16 ícones de itens;
- 40 variantes de veículos × oito direções;
- quatro espécies animais × oito direções;
- Sociedade Humana 0.5.39;
- Atlas Decision Engine 0.5.40;
- HUD/UI 0.5.40.1;
- portas funcionais, cutaway de telhado, loot por POI, construção, agricultura, clima e saves existentes.

## Arquitetura

- `scripts/world/city_chunk_streamer_3d_v05403.gd` estende a cadeia anterior e acrescenta somente camadas visuais não destrutivas;
- `scripts/world/world_runtime_3d_v05403.gd` mantém o runtime da 0.5.40.2 e versiona o save como `0.5.40.3-alpha`;
- `scripts/core/alpha_0_5_40_3_smoke_test.gd` valida o World Rework e as regressões principais;
- a cena principal utiliza o runtime e o streamer 0.5.40.3.

## Persistência

O save recebe:

- `version = 0.5.40.3-alpha`;
- `world_rework_05403 = true`;
- `world_rework_scope_05403 = houses-roads-poi-rural-props`.

Os detalhes visuais são reconstruídos deterministicamente pela seed e não exigem serialização individual de cada mesh.

## Critérios de aceite

A versão é considerada válida quando:

1. o projeto importa sem `SCRIPT ERROR`, `Parse Error`, recurso corrompido ou falha de carregamento;
2. casas recebem o pacote visual 0.5.40.3 sem perder a porta funcional;
3. ruas recebem drenagem e desgaste sem alterar colisão/navegação;
4. o sistema de props gera elementos residenciais deterministicamente;
5. o Asset Rework 0.5.40.2 permanece ativo;
6. zumbis permanecem em cinco perfis × oito frames;
7. itens, veículos, fauna e Decision Engine permanecem ativos;
8. o save é gravado como `0.5.40.3-alpha` com marcador do World Rework;
9. a suíte histórica de regressão continua verde;
10. o APK Android é exportado e publicado pelo CI.

## Limites desta versão

Esta versão é um rework visual do mundo já gerado. Ela não introduz ainda novos biomas, expansão regional do mapa, prédios de múltiplos andares, interiores adicionais, rios procedurais ou simulação maciça off-screen. Esses itens permanecem pertencentes à evolução do World Generator/World Simulator.
