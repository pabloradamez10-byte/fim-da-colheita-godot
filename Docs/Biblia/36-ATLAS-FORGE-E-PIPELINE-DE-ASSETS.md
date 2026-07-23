# 36 — Atlas Forge e Pipeline de Assets

## 1. Finalidade

O **Atlas Forge** é a plataforma de produção, preparação, validação, otimização e catalogação de assets do ecossistema Atlas. Seu primeiro projeto atendido é o **Fim da Colheita**, mas sua arquitetura deve permanecer reutilizável por futuros jogos construídos sobre a Atlas World Engine.

O objetivo não é apenas gerar um arquivo 3D. O objetivo é produzir um **Asset Certificado**, tecnicamente válido, artisticamente coerente e pronto para integração no Godot.

## 2. Pipeline oficial

```text
Referência visual
  ↓
Pré-processamento
  ↓
Forge Engine
  ↓
Correção automática
  ↓
Validador Técnico
  ↓
Validador Artístico
  ↓
Optimizer
  ↓
Asset Registry
  ↓
Biblioteca oficial
  ↓
Integração Godot
  ↓
Teste no jogo
```

## 3. Módulos previstos

### 3.1 Forge Engine

Responsável por:

- receber imagens de referência;
- remover ou normalizar fundo;
- centralizar e enquadrar o objeto;
- gerar o modelo ou asset-base;
- corrigir orientação inicial;
- preparar materiais e texturas;
- exportar para formato compatível com o pipeline.

### 3.2 Forge Validator

Responsável por verificar:

- abertura correta do GLB;
- presença de malha;
- materiais válidos;
- textura incorporada ou corretamente vinculada;
- orientação e escala;
- posição em relação à origem;
- quantidade de polígonos;
- tamanho do arquivo;
- compatibilidade com Godot;
- ausência de falhas graves de renderização.

Resultado possível:

- **APROVADO**;
- **APROVADO COM RESSALVAS**;
- **REPROVADO**.

### 3.3 Forge Optimizer

Responsável por:

- reduzir polígonos sem comprometer silhueta;
- consolidar materiais;
- ajustar resolução de texturas;
- gerar LODs quando aplicável;
- remover dados desnecessários;
- preparar colisores ou pontos de referência quando previstos.

### 3.4 Forge Library

Responsável por:

- registrar cada asset;
- manter versão e histórico;
- armazenar origem e prompt-base;
- registrar autoria e licença;
- guardar parecer técnico e artístico;
- indicar estado de integração;
- impedir duplicidade e perda de assets.

## 4. Estados de um asset

```text
RASCUNHO
GERADO
EM VALIDAÇÃO
APROVADO COM RESSALVAS
APROVADO
OTIMIZADO
INTEGRADO
DEPRECADO
REPROVADO
```

Somente assets **APROVADOS** ou **APROVADOS COM RESSALVAS** autorizados podem avançar para integração.

## 5. Critérios artísticos do Fim da Colheita

O validador artístico deve considerar:

- coerência com a Bíblia Visual;
- ambientação rural do Rio Grande do Sul;
- estilo 3D estilizado, low-poly e semi-realista;
- cores naturais moderadamente dessaturadas;
- desgaste coerente com o mundo pós-colapso;
- proporções compatíveis entre personagens, estruturas e objetos;
- leitura clara em câmera isométrica;
- ausência de texto, logotipo ou marca d'água;
- consistência com assets já aprovados.

## 6. Padrões de integração

Cada asset integrado deve possuir, quando aplicável:

- identificador único;
- nome de arquivo padronizado;
- categoria e subcategoria;
- versão;
- escala de referência;
- pivô correto;
- material e textura;
- colisão;
- ponto de interação;
- metadados no Asset Registry;
- registro no Atlas DataCore;
- teste em cena isolada;
- teste no mapa real.

## 7. Nomenclatura

Exemplos:

```text
TERRAIN_GRASS_001
NATURE_TREE_001
PROP_CRATE_WOOD_001
BUILDING_FARMHOUSE_001
CHAR_SURVIVOR_M_001
ZOMBIE_RURAL_M_001
TOOL_MACHETE_001
```

A nomenclatura deve evitar nomes vagos, datas soltas e arquivos como `final`, `final2` ou `novo`.

## 8. Pacotes de produção

- PACK 001 — Terrain
- PACK 002 — Vegetation
- PACK 003 — Buildings
- PACK 004 — Props
- PACK 005 — Tools
- PACK 006 — Characters
- PACK 007 — Zombies
- PACK 008 — Animals

Cada pacote deve ter escopo, checklist, versão e relatório de integração.

## 9. Governança

A aprovação final artística continua sob supervisão humana de Pablo. A aprovação automática não substitui avaliação visual no jogo.

O Atlas Forge deve ser mantido em repositório próprio, com código-fonte completo, documentação, versões, testes e instruções de restauração. O site publicado não pode ser a única cópia do projeto.
