# Alpha 0.5.40.4 — Feedback & Áudio

## Objetivo

A 0.5.40.4 adiciona uma camada de resposta sensorial ao jogo sem substituir os sistemas funcionais anteriores. O foco é tornar ações mobile mais legíveis e satisfatórias por meio de áudio local, feedback visual breve e vibração curta em dispositivos compatíveis.

## Implementado

- Banco procedural local com 7 cues: ataque, ação, coleta, alerta, troca de arma, corrida e ação negada.
- Áudio sintetizado em runtime a 22.050 Hz, sem dependência de download, internet ou pacote externo.
- Pool de quatro `AudioStreamPlayer` para permitir respostas próximas sem cortar imediatamente o evento anterior.
- Flash de tela contextual por categoria de evento.
- Texto curto de confirmação para ações relevantes.
- Vibração Android/mobile com duração e intensidade diferentes conforme o tipo de evento.
- Controles mobile conectados à camada de feedback para ataque, ação, troca de arma, corrida e entrada em veículo.
- Interações reais do mundo retornam feedback de sucesso ou de ausência de alvo.
- Coleta de recursos de caça gera confirmação específica.
- Disparos originados pelo jogador podem reforçar o feedback de ataque pelo runtime de ruído.
- Persistência da versão e metadados de Feedback & Áudio no save.

## Preservado

A camada 0.5.40.4 herda integralmente:

- World Rework 0.5.40.3;
- Asset Rework 0.5.40.2;
- HUD/UI e frota/fauna 0.5.40.1;
- Atlas Decision Engine 0.5.40;
- sociedade humana 0.5.39;
- fauna e caça 0.5.38;
- Zumbis 2.0 0.5.37;
- missões, progressão, sobrevivência, construção, agricultura, veículos e persistência anteriores.

## Restrições desta etapa

- Não é ainda uma trilha sonora completa.
- Não há biblioteca gravada de armas, motores ou ambiente realista; os cues atuais são sintetizados localmente.
- Não há mixagem espacial 3D completa por fonte sonora.
- Não há sistema final de opções de volume por categoria.
- A vibração depende do suporte do dispositivo e do sistema operacional.

## Critério de aceite

A versão é considerada válida quando:

1. a cena principal instancia a camada de áudio e a camada visual;
2. os 7 cues estão disponíveis localmente;
3. eventos emitidos chegam tanto ao mixer quanto à UI;
4. os controles mobile permanecem funcionais;
5. World Rework e todos os pacotes críticos anteriores passam na suíte de regressão;
6. o save final é gravado como `0.5.40.4-alpha`;
7. o APK Android é exportado com sucesso.
