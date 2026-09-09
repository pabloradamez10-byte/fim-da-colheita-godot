# Alpha 0.5.36 — Objetivos de Sobrevivência

## Objetivo da versão

A 0.5.36 conecta sistemas já existentes em um conjunto inicial de missões sem introduzir NPCs artificiais antes do capítulo social da Bíblia. O jogador recebe objetivos que são concluídos pelas mesmas ações que já fazem parte da sobrevivência: explorar, cultivar, tratar ferimentos, manter veículos e combater.

## Regra central

Missão não substitui gameplay. O progresso deve nascer de ações reais do mundo e nunca de um botão separado de “concluir tarefa”.

## Objetivos iniciais

1. **Rota de Suprimentos** — vasculhar 2 pontos de interesse especializados.
2. **Do Chão à Mesa** — colher uma cultura madura.
3. **Primeiros Socorros** — usar 2 tratamentos médicos.
4. **De Volta à Estrada** — reparar um veículo danificado.
5. **Limpeza da Área** — acertar zumbis 8 vezes.

## Integração com a 0.5.35

Os eventos das missões usam os mesmos sinais de progressão das perícias:

- loot de POI → Vasculhamento;
- colheita → Agricultura;
- bandagem/antisséptico → Medicina;
- reparo de veículo → Mecânica;
- acerto em zumbi → Combate.

A recompensa de uma missão pode conceder itens e XP, porém XP de recompensa usa um motivo reservado para não gerar eventos recursivos de missão.

## Recompensas iniciais

- Rota de Suprimentos: água, bandagem e XP de Vasculhamento;
- Do Chão à Mesa: sementes das três culturas e XP de Agricultura;
- Primeiros Socorros: bandagens, antisséptico e XP de Medicina;
- De Volta à Estrada: gasolina, kit de reparo e XP de Mecânica;
- Limpeza da Área: munição 9 mm, cartuchos e XP de Combate.

Toda recompensa é entregue automaticamente uma única vez quando o objetivo chega ao alvo.

## Interface mobile

A mochila passa a incorporar **OBJETIVOS DE SOBREVIVÊNCIA** abaixo da progressão do personagem. Cada missão mostra título, descrição, progresso, barra e recompensa. Nenhum botão permanente novo é colocado sobre a área principal do jogo.

## Persistência

O save 0.5.36 registra:

- progresso de cada missão;
- estado concluído;
- estado de recompensa entregue;
- número de eventos registrados;
- total de missões concluídas;
- último evento e última missão concluída.

## Limites desta etapa

A 0.5.36 não implementa contratantes, diálogos, facções, reputação, missões procedurais ou cadeias narrativas. Esses elementos dependem dos capítulos futuros de sociedade, NPCs, facções e Atlas Decision Engine.

## Critério de aceite

A versão é aceita quando os cinco objetivos podem ser avançados por eventos reais, suas recompensas são únicas, o diário aparece na interface mobile, o estado persiste após reload e os sistemas anteriores continuam presentes.
