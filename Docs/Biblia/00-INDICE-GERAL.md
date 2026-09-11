# Fim da Colheita — Bíblia Oficial

Este diretório é a fonte oficial de verdade do projeto **Fim da Colheita**. Ele consolida a estrutura conceitual da Bíblia anterior com a documentação técnica e de produção do repositório Godot.

## Status usados

- **DEFINIDO** — conceito aprovado e documentado.
- **EM DESENVOLVIMENTO** — conceito definido, mas ainda sendo detalhado ou implementado.
- **IMPLEMENTADO** — existe no jogo ou na infraestrutura atual.
- **IMPLEMENTADO / EM EXPANSÃO** — já possui ciclo funcional, mas ainda está abaixo da profundidade final da Bíblia.
- **PRECISA DE REVISÃO** — conteúdo existente que precisa ser sincronizado com o projeto atual.
- **PLANEJADO** — tema reservado, ainda sem especificação completa.

## Parte I — Fundação do Projeto

- 00 — Visão Geral — **DEFINIDO**
- 01 — Constituição do Projeto — **DEFINIDO**
- 02 — Roadmap — **PRECISA DE REVISÃO**
- 03 — Gameplay — **EM DESENVOLVIMENTO**
- 04 — Arquitetura Inicial — **PRECISA DE REVISÃO**

## Parte II — Mundo e Sociedade

- 05 — O Mundo — **DEFINIDO**
- 06 — Ecossistema Vivo — **IMPLEMENTADO / EM EXPANSÃO**
- 07 — World Simulator — **EM DESENVOLVIMENTO**
- 08 — Mundo Físico — **IMPLEMENTADO / EM EXPANSÃO**
- 09 — Sociedade Humana — **PLANEJADO**
- 10 — Facções — **PLANEJADO**
- 11 — Economia Mundial — **PLANEJADO**

## Parte III — Personagens

- 12 — Personagens, Atributos e Evolução — **IMPLEMENTADO / EM EXPANSÃO**
- 13 — Saúde — **IMPLEMENTADO / EM EXPANSÃO**
- 14 — Necessidades Humanas — **IMPLEMENTADO / EM EXPANSÃO**
- 15 — Relacionamentos — **PLANEJADO**
- 16 — Sucessão e Legado — **PLANEJADO**
- 17 — Personalidade e Memória — **PLANEJADO**

## Parte IV — Natureza e Estruturas

- 18 — Animais — **IMPLEMENTADO / EM EXPANSÃO**
- 19 — Agricultura — **IMPLEMENTADO / EM EXPANSÃO**
- 20 — Clima e Estações — **EM DESENVOLVIMENTO**
- 21 — Estruturas e Pontos de Interesse — **IMPLEMENTADO / EM EXPANSÃO**

## Parte V — Gameplay

- 22 — Construção e Engenharia — **IMPLEMENTADO / EM EXPANSÃO**
- 23 — Crafting, Produção e Manufatura — **IMPLEMENTADO / EM EXPANSÃO**
- 24 — Exploração e Expedições — **IMPLEMENTADO / EM EXPANSÃO**
- 25 — Sistema Modular de Personagens — **IMPLEMENTADO / EM EXPANSÃO**
- 26 — Inventário, Equipamentos e Carga — **IMPLEMENTADO / EM EXPANSÃO**
- 27 — Sobrevivência, Necessidades e Condição Física — **IMPLEMENTADO / EM EXPANSÃO**
- 28 — Combate, Armas e Táticas — **IMPLEMENTADO / EM EXPANSÃO**
- 29 — Veículos, Transporte e Logística — **IMPLEMENTADO / EM EXPANSÃO**

## Parte VI — Atlas World Engine

- 30 — Arquitetura da Atlas World Engine — **EM DESENVOLVIMENTO**
- 31 — Atlas DataCore — **EM DESENVOLVIMENTO**
- 32 — Decision Engine — **PLANEJADO**
- 33 — World Simulator — **PLANEJADO**
- 34 — World Generator — **IMPLEMENTADO / EM EXPANSÃO**
- 35 — Simulation Scheduler — **PLANEJADO**

## Parte VII — Produção e Ferramentas

- 36 — Atlas Forge e Pipeline de Assets — **EM DESENVOLVIMENTO**
- 37 — Biblioteca de Assets e Asset Registry — **EM DESENVOLVIMENTO**
- 38 — Validação Técnica e Artística — **EM DESENVOLVIMENTO**
- 39 — Integração Godot e Critérios de Aceite — **IMPLEMENTADO / EM EXPANSÃO**
- 40 — Versionamento, ADRs e Registro de Decisões — **PLANEJADO**

## Linha técnica atual da Alpha Android

- 0.5.20 — loop risco/recompensa, morte, cadáveres e infecção;
- 0.5.21 — tempo, sono e abrigo;
- 0.5.22 — clima, chuva e umidade/exposição;
- 0.5.23 — hotbar e durabilidade;
- 0.5.24 — bancada e produção;
- 0.5.25 — fila de produção;
- 0.5.26 — construção, base e armazenamento;
- 0.5.27 — manutenção e defesa da base;
- 0.5.28 — fogueira e barricadas;
- 0.5.29 — sobrevivência hídrica;
- 0.5.30 — veículos dirigíveis, combustível, dano e logística;
- 0.5.31 — agricultura inicial;
- 0.5.32 — agricultura e alimentação 2.0;
- 0.5.32.1 — estabilização de tela ultrawide, HUD e interações mobile;
- 0.5.33 — vestuário, slots corporais, proteção, clima e peso;
- 0.5.34 — pontos de interesse e loot especializado por localização;
- 0.5.35 — progressão do sobrevivente, atributos e perícias integradas às ações reais;
- 0.5.36 — objetivos de sobrevivência, recompensas e diário de missões integrado à mochila;
- 0.5.36.2 — frota expandida para 40 veículos com oito direções e distribuição urbana, rural e de serviço;
- 0.5.37 — Zumbis 2.0: quatro hordas, migração, atração por ruído, pressão sobre portas/janelas/base e cinco perfis visuais de infectados;
- 0.5.38 — Animais & Caça: quatro espécies, fauna persistente, fuga por ameaça/ruído, carcaças, carne, couro, penas e alimentação de caça.

## Documentação técnica associada

- AWE Architecture
- Atlas Art Bible
- Atlas Character Pipeline
- Atlas Nature Library
- Atlas Building Library
- Catálogos JSON do Atlas DataCore
- Terrain Manager
- Asset Manager
- Save e persistência
- Pipeline de exportação web/mobile

## Regra de governança

Toda decisão nova que afete gameplay, arte, arquitetura, geração procedural, assets, persistência ou integração deve ser registrada nesta Bíblia ou em um ADR vinculado a ela.
