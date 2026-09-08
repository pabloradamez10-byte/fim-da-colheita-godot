# Alpha 0.5.22 — Clima, chuva, neblina e umidade

## Decisão

A 0.5.22 amplia o sistema de tempo da 0.5.21 para clima sistêmico. Chuva, neblina e céu nublado passam a alterar a leitura visual, a temperatura, a condição física do personagem e a percepção dos zumbis.

## Regras implementadas

- clima determinístico por seed, dia e janela de três horas;
- estados iniciais: aberto, nublado, chuva e neblina;
- manhã/madrugada têm chance maior de neblina;
- chuva e tempo fechado reduzem a temperatura externa;
- chuva possui efeito visual por partículas no entorno do jogador;
- neblina e chuva ativam fog ambiental com intensidades distintas;
- céu, luz ambiente e intensidade solar reagem ao clima;
- o personagem passa a ter variável persistente de **umidade/molhado**;
- chuva aumenta umidade somente quando o personagem está exposto;
- casas reconhecidas como abrigo interrompem a chuva sobre o jogador e aceleram a secagem;
- tempo aberto seca lentamente o personagem mesmo fora de abrigo;
- umidade elevada aumenta cansaço, prejudica fôlego e acelera queda da temperatura corporal em ambiente frio;
- dormir em abrigo acelera a secagem;
- chuva reduz visão dos zumbis e mascara ruídos, reduzindo o alcance auditivo;
- neblina reduz fortemente a visão dos zumbis sem mascarar tanto o som;
- HUD passa a exibir clima atual e nível de molhado quando relevante;
- umidade é preservada no save junto com relógio, sono, infecção e continuidade da 0.5.20/0.5.21.

## Critérios de aceite

- cena principal usa o runtime 0.5.22;
- player e zumbis são instanciados com scripts 0.5.22;
- o clima pode ser resolvido de forma determinística e também forçado pelos testes;
- chuva ativa partículas e fog apropriado;
- chuva em área aberta aumenta umidade;
- abrigo impede novo acúmulo e seca o personagem;
- umidade alta em clima frio impacta temperatura/fôlego;
- chuva e neblina alteram os multiplicadores de visão/audição dos zumbis;
- HUD apresenta clima e molhado;
- save contém wetness_0522;
- regressões de casas, água, veículos, IA, infecção, morte, sono e relógio continuam passando;
- parser Godot, smoke tests e export Android passam no CI.

## Relação com a Bíblia

Esta versão avança especialmente os capítulos de Clima e Estações, Sobrevivência, Saúde, Exploração e Zumbis/Ameaças. Permanecem para versões seguintes: chuva com poças e superfícies molhadas, vento, tempestades, relâmpagos, roupas/isolamento térmico, estações completas, iluminação portátil e eventos meteorológicos raros.
