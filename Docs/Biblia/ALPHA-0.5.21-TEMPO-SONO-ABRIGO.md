# Alpha 0.5.21 — Tempo, sono, abrigo e temperatura

## Decisão

A 0.5.21 continua a prioridade crítica de **sobrevivência e saúde** da Bíblia e dá função sistêmica às casas já implementadas. O mundo deixa de ser iluminado e fisiologicamente estático: o tempo passa, a noite chega, o personagem se cansa, precisa dormir e o abrigo interfere na exposição térmica.

## Regras implementadas

- relógio mundial persistente com **dia + hora**;
- 1 segundo real corresponde inicialmente a 1 minuto no mundo;
- iluminação, cor ambiente e intensidade solar mudam ao longo do ciclo;
- temperatura externa varia com o horário, com mínima na madrugada e máxima à tarde;
- casas residenciais e rurais são reconhecidas como **abrigo**;
- abrigo aproxima a temperatura efetiva de uma faixa interna mais segura;
- o personagem passa a acumular **cansaço** enquanto permanece acordado;
- corrida, dor e infecção aceleram o cansaço;
- cansaço elevado reduz o teto de recuperação de fôlego;
- temperatura corporal reage gradualmente à temperatura efetiva;
- frio ou calor extremos passam a afetar fôlego, sede e, em condições críticas, vida;
- camas das casas residenciais são interativas;
- usar **INTERAGIR** junto à cama permite dormir e avançar o relógio;
- durante o sono, cansaço e fôlego se recuperam, dor reduz parcialmente e fome/sede continuam consumindo recursos;
- à noite, zumbis enxergam a uma distância menor, mas ganham alcance de audição e memória de investigação maiores;
- dia, horário, cansaço e temperatura corporal são persistidos no save existente sem quebrar os dados da 0.5.20.

## Critérios de aceite 0.5.21

A versão só recebe estado de implementada quando:

- a cena principal usa World/Player/Zombie 0.5.21 e o streamer 0.5.21;
- relógio avança e atravessa a meia-noite incrementando o dia;
- salvar/carregar preserva dia, hora, cansaço e temperatura corporal;
- o HUD exibe dia, horário, período, temperatura externa, cansaço e temperatura corporal;
- casas registradas são reconhecidas como abrigo;
- camas são registradas como superfícies de sono e permanecem reutilizáveis;
- dormir reduz cansaço e avança o horário;
- o ambiente interno reduz exposição ao frio noturno;
- zumbis apresentam perfil sensorial distinto entre dia e noite;
- regressões de água, portas, veículos e loop de morte/loot da 0.5.20 continuam passando;
- parser Godot, smoke tests e exportação Android passam no CI.

## Relação com a Bíblia

Esta entrega avança diretamente:

- Parte III — Saúde e Necessidades Humanas;
- Parte IV — Clima e Estações, no primeiro nível de tempo/temperatura;
- Parte V — Sobrevivência, Necessidades e Condição Física;
- Parte V — Exploração, porque horário e abrigo passam a alterar decisões de rota;
- Zumbis e ameaças, porque percepção agora depende do período.

Ainda ficam para versões posteriores: sono interrompido por ameaça, chuva, umidade, roupas/isolamento térmico, estações, doenças específicas, iluminação portátil, energia elétrica e eventos noturnos.
