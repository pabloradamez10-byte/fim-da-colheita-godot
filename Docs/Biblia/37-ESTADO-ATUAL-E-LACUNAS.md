# 37 — Estado Atual da Bíblia e Lacunas

## 1. Situação consolidada

A Bíblia possui uma estrutura oficial abrangente, dividida em fundação, mundo, personagens, natureza, gameplay, Atlas World Engine e produção. A estrutura conceitual já cobre o escopo de um jogo de sobrevivência sistêmico de longo prazo.

O projeto jogável atual já demonstra partes importantes dessa visão:

- geração procedural por seed;
- terrenos com variações estáveis;
- água e objetos naturais;
- câmera isométrica e ordenação de profundidade;
- movimentação;
- inventário;
- coleta;
- fogueira;
- persistência de save;
- controles para celular;
- pipeline inicial de personagens e assets.

## 2. Adendos incorporados

Foram incorporados à estrutura oficial:

- Atlas Forge;
- pipeline de geração, validação, otimização e integração;
- Asset Registry;
- estados de aprovação de assets;
- pacotes oficiais de produção;
- governança documental;
- necessidade de ADRs;
- distinção entre asset gerado, aprovado, otimizado e integrado.

## 3. Lacunas prioritárias da Bíblia

### Prioridade crítica

1. **Loop principal do jogo**
   - início de partida;
   - objetivos imediatos, médios e longos;
   - risco, recompensa e progressão;
   - condições de fracasso, morte e continuidade.

2. **Escopo da primeira versão jogável**
   - o que pertence à Alpha, Demo, Early Access e versão 1.0;
   - sistemas obrigatórios e sistemas adiados;
   - critérios de pronto para cada marco.

3. **Combate**
   - controles;
   - tipos de ataque;
   - stamina;
   - dano, proteção e ferimentos;
   - armas corpo a corpo e à distância;
   - comportamento dos inimigos;
   - morte e loot.

4. **Sobrevivência e saúde**
   - fome, sede, sono e temperatura;
   - dor, sangramento, infecção e doenças;
   - recuperação;
   - morte permanente ou sucessão.

5. **Zumbis e ameaças**
   - origem e regras;
   - percepção, audição e visão;
   - variações;
   - densidade e migração;
   - interação com clima, ruído e horário.

### Prioridade alta

6. **Mundo procedural**
   - biomas oficiais;
   - estradas, rios e relevo;
   - cidades, propriedades e pontos de interesse;
   - regras de distribuição;
   - persistência de alterações no mundo.

7. **Construção e base**
   - peças construíveis;
   - estabilidade estrutural;
   - reparo e deterioração;
   - energia, água e armazenamento;
   - invasões e defesa.

8. **Crafting e produção**
   - categorias de receitas;
   - ferramentas e bancadas;
   - qualidade de itens;
   - tempo e habilidade;
   - produção agrícola e industrial.

9. **Personagens e progressão**
   - atributos;
   - perícias;
   - profissões;
   - vantagens e limitações;
   - memória, personalidade e relações.

10. **Inventário e equipamentos**
    - peso e volume;
    - slots corporais;
    - recipientes;
    - durabilidade;
    - atalhos e interface mobile.

### Prioridade média

11. **Animais e agricultura**
12. **Clima, estações e calendário**
13. **Facções e comunidades**
14. **Economia e comércio**
15. **Veículos e logística**
16. **Eventos e narrativa emergente**
17. **Áudio, música e identidade sonora**
18. **Interface, acessibilidade e controles**
19. **Multiplayer, caso permaneça no escopo futuro**
20. **Monetização, distribuição e suporte pós-lançamento**

## 4. Lacunas técnicas

- contrato entre Godot e AWE;
- esquema versionado do Atlas DataCore;
- política de migração de saves;
- testes automatizados;
- orçamento de desempenho para celular e desktop;
- limites de memória, draw calls e polígonos;
- convenção de cenas, scripts e recursos;
- pipeline de animações e rig compartilhado;
- política de licenças e autoria de assets;
- backup e recuperação dos projetos Atlas Forge e AWE;
- processo de release e rollback.

## 5. Próxima ordem recomendada

1. Fechar o loop principal.
2. Definir o escopo da primeira demo.
3. Documentar combate, zumbis e sobrevivência.
4. Consolidar a geração procedural e os pontos de interesse.
5. Fechar o pipeline de personagens, rig e animações.
6. Criar o Asset Registry real.
7. Atualizar o roadmap com versões e critérios de aceite.
8. Transformar decisões arquiteturais em ADRs.

## 6. Regra de atualização

Nenhum sistema deve ser considerado concluído apenas porque existe no código. Para receber o estado **IMPLEMENTADO**, ele deve:

- estar documentado;
- funcionar no jogo;
- possuir critério de aceite;
- ter sido validado em desktop e celular quando aplicável;
- não quebrar save ou integração existente;
- estar registrado no roadmap ou changelog.
