# Alpha 0.5.24 — Bancada, produção e materiais processados

## Decisão

A 0.5.24 aprofunda o capítulo **23 — Crafting, Produção e Manufatura** e conecta o crafting ao mundo físico. Nem toda receita pode mais ser executada diretamente da mochila: surge a primeira **estação de produção**, a bancada de trabalho.

A propriedade inicial recebe uma bancada antiga funcional para que o jogador consiga experimentar o sistema sem depender de um POI raro. A construção de bancadas próprias fica reservada ao bloco de Construção e Engenharia.

## Loop implementado

1. coletar matérias-primas;
2. fazer craft simples de campo quando permitido;
3. localizar e interagir com a bancada;
4. processar recursos brutos;
5. combinar materiais processados em componentes úteis;
6. usar componentes para manutenção avançada do equipamento.

## Materiais processados iniciais

- **Corda improvisada** — feita em campo a partir de fibra;
- **Tábuas preparadas** — produzidas na bancada a partir de madeira;
- **Lâmina de pedra** — produzida na bancada a partir de pedra e fibra;
- **Kit de reparo** — produzido na bancada combinando tábuas, corda e lâmina de pedra.

## Reparo

A regra da 0.5.23 é preservada:

- **reparo de campo** continua possível com materiais simples e recupera aproximadamente 45% da durabilidade máxima;
- **revisão na bancada** exige um kit de reparo e restaura a arma/ferramenta para 100%.

Isso cria uma diferença funcional entre sobreviver longe da base e voltar a um ponto de manutenção adequado.

## Interface mobile

- INTERAGIR próximo à bancada abre a mochila diretamente em modo de estação;
- receitas identificam **CAMPO** ou **BANCADA**;
- receitas de bancada ficam visíveis, porém bloqueadas fora do alcance da estação;
- a coluna de crafting passa a ter rolagem para suportar a expansão futura do catálogo;
- materiais processados aparecem na mochila;
- o botão de reparo muda para **REVISÃO** quando a manutenção completa está disponível na bancada.

## Persistência e morte

- materiais processados usam o mesmo inventário persistente;
- contadores de crafting e revisão são salvos;
- materiais processados em pilhas relevantes entram na perda parcial recuperável após a morte;
- saves anteriores recebem os novos itens com quantidade zero sem migração destrutiva.

## Critérios de aceite 0.5.24

A versão só é válida quando:

- a cena principal usa Player/World 0.5.24 e Inventory UI 0.5.24;
- existe pelo menos uma bancada funcional e identificável no mundo;
- INTERAGIR na bancada abre a interface de crafting;
- receita de bancada falha fora do alcance da estação;
- madeira pode ser processada em tábuas na bancada;
- fibra pode ser processada em corda em campo;
- pedra pode ser transformada em lâmina na bancada;
- os materiais processados permitem fabricar kit de reparo;
- reparo de campo permanece funcional;
- revisão de bancada consome um kit e restaura 100% da durabilidade;
- materiais e durabilidade continuam persistindo no save;
- hotbar, clima, casas, água, veículos e IA dos zumbis não regridem;
- parser Godot, smoke tests e exportação Android passam no CI.

## Continuidade

A 0.5.24 ainda não implementa bancada construída pelo jogador, tempo real de fabricação, ferramentas obrigatórias por receita, qualidade de produção, energia ou máquinas. Esses elementos permanecem para as próximas etapas de Crafting/Produção e Construção/Engenharia.
