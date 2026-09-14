# Alpha 0.6.0 — Estabilização

## Objetivo

Interromper temporariamente a expansão de funcionalidades e transformar a 0.5.40.5 em uma base Android recuperável, testável e apta a receber refatoração gradual.

## Correções desta etapa

- versão do projeto e do pacote Android alinhadas em 0.6.0;
- `versionCode` elevado para 600;
- saída de build renomeada corretamente;
- jogador 0.6.0 com animação específica para facão, pistola e espingarda;
- save final validado como JSON;
- schema de save 600;
- troca protegida do save com arquivo de backup;
- teste de regressão para versão, armas, portas e salvamento;
- workflow Android dedicado à estabilização;
- suporte a keystore persistente por secrets, com keystore padrão de desenvolvimento como fallback temporário.

## Compatibilidade

A leitura dos saves anteriores continua usando o carregamento herdado da 0.5.40.5. Ao salvar, o conteúdo preservado recebe a versão `0.6.0-alpha` e o schema 600.

## Limite conhecido

A cadeia histórica de runtimes e jogadores ainda existe. A consolidação arquitetural será feita de forma gradual depois que esta versão passar no aparelho real, para evitar perda de sistemas e saves.
