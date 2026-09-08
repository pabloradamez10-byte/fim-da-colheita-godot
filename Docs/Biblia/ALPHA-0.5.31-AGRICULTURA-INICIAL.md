# Alpha 0.5.31 — Agricultura inicial

## Decisão

A 0.5.31 abre o capítulo 19 da Bíblia com um primeiro ciclo persistente de agricultura ligado ao relógio e ao clima já existentes:

**preparar solo → plantar → manter umidade → crescer com passagem de tempo → colher → replantar.**

## Regras implementadas

- seis canteiros iniciais próximos à fazenda;
- preparo permanente do solo até novo mundo;
- batata como primeira cultura;
- sementes de batata entram no inventário com migração retrocompatível;
- chuva aumenta e mantém a umidade do canteiro;
- rega manual consome água potável;
- solo seco reduz a velocidade de crescimento, em vez de congelar completamente a cultura;
- crescimento usa o mesmo relógio de mundo da 0.5.21;
- quatro estados visuais: preparado, broto, crescimento e pronto para colher;
- colheita entrega alimento e novas sementes;
- canteiro colhido permanece preparado para novo plantio;
- estado, umidade, crescimento e contadores persistem em save/load;
- save anterior 0.5.30 continua carregável.

## Continuidade

A 0.5.31 não encerra agricultura. Ficaram para versões posteriores diversidade de culturas, seleção de sementes, alimentos crus/cozidos, validade, fertilidade, ferramentas agrícolas, doenças/pragas, estações e produção animal.
