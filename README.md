# Fim da Colheita

Jogo de sobrevivência em Godot 4.3 com foco em Android e funcionamento offline.

## Estado atual

A Alpha 0.6.0 é uma etapa de estabilização criada sobre a 0.5.40.5. Ela preserva os sistemas existentes e corrige a identificação do APK, as animações de combate, o salvamento recuperável e os testes mínimos de regressão.

Branch de trabalho: `fix/android-alpha-0.6.0-stabilization`.

## Validação obrigatória

Antes do merge na `main`:

- build Android deve concluir;
- smoke test 0.6.0 deve passar;
- instalação sobre uma versão anterior deve ser testada;
- portas, interiores, água, armas, veículos e save/load devem ser validados em aparelho real.
