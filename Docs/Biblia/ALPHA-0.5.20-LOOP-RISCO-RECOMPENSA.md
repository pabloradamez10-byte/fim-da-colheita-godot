# Alpha 0.5.20 — Loop de risco, recompensa e continuidade

## Decisão

A 0.5.20 liga as lacunas críticas de **loop principal**, **combate**, **sobrevivência/saúde** e **zumbis/ameaças** em um ciclo jogável único:

1. explorar e enfrentar ameaças;
2. sofrer risco físico real (dor, sangramento e contaminação/infeção);
3. eliminar zumbis e receber recompensa saqueável;
4. morrer com consequência, sem apagar a partida;
5. voltar ao mundo e recuperar parte dos recursos perdidos.

## Regras implementadas

- zumbis mortos permanecem mortos no mesmo seed após salvar/carregar;
- cada morte de zumbi cria um cadáver saqueável com loot determinístico pelo seed/nome/variante;
- existem quatro arquétipos iniciais derivados das variantes atuais: errante, agitado, robusto e infectado;
- golpes de zumbi aumentam contaminação/infeção de ferimentos;
- infecção alta aumenta dor, reduz fôlego e, em estágio crítico, afeta vida e sede;
- antisséptico é item utilizável e reduz infecção, sangramento e dor;
- morte do jogador derruba aproximadamente 35% das pilhas com quantidade suficiente;
- a mochila perdida permanece no mundo e pode ser recuperada com INTERAGIR;
- morte não apaga armas desbloqueadas nem o mundo; o jogador retorna debilitado à área inicial;
- cadáveres, mochilas perdidas, abates e mortes são persistidos no save existente de forma retrocompatível.

## Critérios de aceite 0.5.20

A versão só é considerada válida quando:

- a cena principal usa os runtimes 0.5.20;
- um zumbi morto cria cadáver registrado e deixa de renascer no mesmo save;
- interagir com o cadáver transfere o loot e remove o marcador;
- dano de zumbi aumenta infecção;
- usar antisséptico reduz infecção;
- morrer cria mochila recuperável quando há recursos elegíveis para perda;
- save/carregamento preserva os registros do loop;
- água bloqueada, portas/casas e orientação dos veículos continuam funcionando;
- parser Godot e exportação Android passam no CI.

## Relação com a Bíblia

Esta entrega avança diretamente as prioridades críticas registradas em `37-ESTADO-ATUAL-E-LACUNAS.md`, principalmente o loop principal, combate, sobrevivência/saúde e zumbis. Ela não encerra esses capítulos: sono, temperatura, doenças mais profundas, migração de hordas, proteção corporal e sucessão permanecem para versões posteriores.
