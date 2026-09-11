# Alpha Android 0.5.39 — Sociedade Humana Inicial

## Objetivo

A 0.5.39 inaugura a presença de sobreviventes humanos persistentes no mundo de **Fim da Colheita**. Esta etapa não implementa facções completas; ela cria a base sistêmica para a Parte II da Bíblia — Sociedade Humana — e prepara as versões seguintes de relações, comunidades, facções e decisões autônomas.

## Ciclo funcional

**Encontrar sobrevivente → interagir → conhecer → perceber necessidade → ajudar com recurso real → aumentar confiança → receber resposta social → persistir a relação.**

O sistema usa os mesmos recursos e ameaças do mundo já existente. Não existe inventário paralelo artificial para o jogador.

## Sobreviventes iniciais

A primeira população humana é composta por três identidades persistentes:

- **Helena — Socorrista**: associada a cuidados e suprimentos médicos;
- **Davi — Mecânico**: associado a combustível e logística;
- **Mauro — Catador**: associado a exploração e suprimentos básicos.

Cada sobrevivente possui posição, papel, saúde, fome, sede, confiança, estado de encontro, histórico de ajuda, compartilhamento de suprimento e estado de vida/morte persistidos no save.

## Necessidades e vulnerabilidade

Os sobreviventes possuem necessidades próprias de fome e sede. A falta prolongada de recursos afeta a saúde. Zumbis próximos provocam fuga e contato direto pode causar dano. Morte humana é persistente.

O jogador pode ajudar usando recursos que realmente existem em sua mochila:

- água para sede;
- comida para fome;
- bandagem para ferimentos.

A ajuda consome o item do jogador e aumenta a confiança do NPC.

## Relação inicial

A 0.5.39 introduz uma escala de confiança simples, preparando o capítulo de Relacionamentos:

- estranho;
- conhecido;
- amigável;
- confiável.

O primeiro contato cria reconhecimento. Ajuda material aumenta confiança. Conversas posteriores mantêm a relação. Com confiança suficiente, cada sobrevivente pode compartilhar uma vez um recurso coerente com seu papel.

Esta mecânica é deliberadamente simples: não substitui o futuro sistema de personalidade, memória social, reputação ou facções.

## Integração com o mundo vivo

Sobreviventes reagem a:

- zumbis próximos;
- tiros;
- veículos e outros eventos de ruído herdados do sistema 0.5.19/0.5.37;
- necessidades fisiológicas próprias.

A 0.5.39 preserva e integra:

- 18 animais / 4 espécies da 0.5.38;
- quatro hordas e cinco perfis de infectados da 0.5.37;
- missões da 0.5.36;
- frota de 40 veículos × 8 direções da 0.5.36.2;
- sobrevivência, agricultura, construção, clima e persistência anteriores.

## Persistência

O save `0.5.39-alpha` registra:

- os três sobreviventes;
- posição e necessidades;
- saúde e morte;
- confiança;
- primeiro contato;
- ajuda recebida;
- compartilhamento único de suprimento;
- estado/último evento social;
- métricas de interação e fuga por ruído.

## Limites desta etapa

Ainda ficam para versões posteriores:

- diálogo ramificado;
- inventário individual completo de NPC;
- combate armado autônomo de sobreviventes;
- recrutamento e grupo do jogador;
- comunidades e assentamentos;
- reputação coletiva;
- facções, alianças e conflitos;
- memória social profunda;
- Atlas Decision Engine para decisões complexas.

## Critério de aceite

A 0.5.39 é considerada válida quando:

1. três sobreviventes com papéis distintos surgem e persistem;
2. primeiro contato e confiança funcionam;
3. necessidades podem ser atendidas com itens reais do jogador;
4. ajuda consome recursos e altera a relação;
5. compartilhamento social não duplica recompensa;
6. ruído e zumbis afetam o comportamento humano;
7. dano humano e estado social persistem no save;
8. sistemas 0.5.16–0.5.38 permanecem funcionais;
9. o APK Android passa parser, regressões e smoke test 0.5.39.
