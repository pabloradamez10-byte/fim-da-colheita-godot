# Alpha 0.6.1 — Jogabilidade fluida

Atualização incremental baseada na Alpha 0.6.0, sem remover sistemas existentes.

## Alterações

- Analógico virtual com filtro exponencial independente da taxa de quadros.
- Zona morta reduzida de 12% para 10% e soltura rápida para preservar precisão.
- Câmera com avanço proporcional à velocidade e transição suavizada.
- Streaming de mundo parcelado: no máximo um chunk novo por frame.
- Física em 60 Hz com interpolação e limite de passos para evitar espirais após picos.
- APK separado da Alpha 0.6.0 para teste lado a lado.
- Formato de save mantido no schema 600 para compatibilidade.

## Roteiro de teste no aparelho

1. Caminhar lentamente em círculos pequenos usando metade do curso do analógico.
2. Alternar caminhada e corrida e soltar o analógico de repente.
3. Cruzar várias bordas de chunk, especialmente na entrada da cidade.
4. Confirmar que a câmera não dá trancos ao iniciar, parar ou mudar de direção.
5. Testar pistola, portas, veículo e salvar/carregar para detectar regressões.
