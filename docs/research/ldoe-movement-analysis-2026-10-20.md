# Análise de movimentação — Last Day on Earth

Data: 20/10/2026. Base de comparação: Fim da Colheita Alpha 0.6.7, commit `70c72f7`.

## Resultado

A análise estática identificou as rotinas de entrada e movimento no APK oficial e ligou seus métodos aos endereços ARM64. Há evidência suficiente para orientar uma implementação própria no Godot. Ainda não há equivalência de jogabilidade demonstrada nem alteração no jogo.

## Procedimento reproduzido

- APK obtido pelo botão Download APK do site oficial da Kefir.
- Metadados Unity IL2CPP versão 39: 194 imagens, 38.926 tipos e 255.431 métodos.
- REA publicado no npm, versão 6.7.0, não possui `inspect-il2cpp-metadata`.
- Utilizado o leitor atual do código-fonte REA: `readIl2cppMetadataForLinking` e `linkIl2cppBinary`, executados diretamente com Node/tsx. Revisão exata e hashes constam no JSON adjacente.
- O leitor decodificou os metadados e produziu uma tabela de ligação nativa para 255.431 métodos. Essa quantidade inclui entradas sem corpo e desconhecidas; não significa que todos foram descompilados.
- Disassembly ARM64 direcionado com Capstone e pyelftools; o APK não foi executado. Nenhum motor Ghidra/Hopper disponível. O REA CLI também encontrou um erro de inspeção de processos `ps`; a leitura direta das bibliotecas não lança esses processos.

## Evidências verificadas

| Componente e endereço ARM64 | Observação | Limite |
| --- | --- | --- |
| `DpadController.CalculateSwipeData`, `0x50fb8fc` | Calcula deslocamento do toque, limita pelo raio igual à metade da largura do controle, normaliza direção e calcula intensidade por distância/raio. | A configuração de tamanho/posição em cada dispositivo não foi extraída. |
| `SingleDpadProducer.Add`, `0x50fd534` | Converte o vetor com rotação em Y de aproximadamente 45 graus. | Relação visual completa depende da câmera e das convenções de eixos. |
| `SingleDpadProducer.FillModelDirections`, `0x50fd4a8` | Atualiza direção, ângulo e intensidade em campos separados do modelo do controle. | Não estabelece sozinho velocidade final do personagem. |
| `SyncDpadProducer.Add`, `0x50fdf1c` | Limita intensidade entre 0 e 1 e multiplica o vetor convertido pela intensidade. | É o caminho sincronizado; não se deve presumir que todos os modos usam esse caminho. |
| `CharacterDescription.SetVelocityByDirection`, `0x8978ff8` | Normaliza o vetor e conserva magnitude limitada a 1: saída equivalente a `normalize(v) * min(length(v), 1)`, considerando o tratamento de zero do tipo vetorial. | É a velocidade normalizada do modelo, não unidades de mundo por segundo. |
| `MovementController`, métodos `Move`, `Translate`, `SetDirection` | Movimento, deslocamento e orientação têm rotinas separadas e dependências de navegação, velocidade e estado parado. | Ainda não foi reconstruída toda a resolução de obstáculos. |
| `PlayerNavGridMovement.Move`, `0x88a5b3c` | Encaminha para `NavGridMovement.InnerMove`; a classe-base possui raycaster e número de iterações. | Não equivale a conhecer a regra completa de deslizamento ou contorno. |
| `CharacterAnimatorController` | Metadados expõem `SetMoveSpeed`, `SetMoveRotation`, modos de movimento e parâmetros de velocidade/rotação. | Curvas, blend trees e valores ativos ainda não foram extraídos; os nomes não provam sincronização perfeita dos pés. |

## Diagnóstico do nosso código

Verificações estáticas na cadeia ativa da Alpha 0.6.7:

1. `mobile_controls_v0601.gd` suaviza o vetor com resposta exponencial 18/24. Depois, `player_3d_v058.gd` aplica outra rampa de aceleração/desaceleração 30/38. As duas camadas podem contribuir para resposta atrasada; o efeito percebido exige medição no aparelho.
2. `player_3d_v058.gd` zera a velocidade vertical antes de `move_and_slide`. `player_3d_v059.gd` força a altura global para 0,20 a cada tick. `player_3d_v066.gd` aplica uma correção posterior por raycast. As políticas de altura coexistem na herança e devem ser unificadas, com testes de chão, escada e borda.
3. `player_3d_v064.gd` escolhe caminhada ou corrida com base na velocidade, mas usa frequências fixas de animação de 9 e 13,5 FPS. A intensidade analógica varia continuamente; isso pode desalinhar passos e deslocamento.
4. O visual ativo possui oito direções. Isso limita a suavidade visual dos giros, mesmo com direção física contínua.

Esses achados são problemas candidatos, não uma reprodução em execução dos sintomas relatados.

## Implementação indicada

Criar uma versão de teste isolada a partir da 0.6.7, com implementação própria:

1. Entrada como direção normalizada + intensidade limitada; conversão baseada nos eixos da câmera, validada contra a referência de 45 graus.
2. Uma única política de resposta do controle, com soltura rápida e sem atraso duplicado.
3. Um único controlador de chão e colisões; remover correções de altura concorrentes apenas após testes de regressão.
4. Animação vinculada ao deslocamento efetivo, incluindo velocidade após colisão; preservar direção quando parado.
5. Validar transição entre andar, correr, atacar, interagir e retomar movimento.

Testes necessários: diagonal sem ganho de velocidade, intensidade parcial, soltar/inverter analógico, colisão frontal e lateral, chão irregular, câmera, toque simultâneo com ataque, 30/60 FPS e salvamento existente.

## Ainda não determinado

- Velocidades finais, aceleração e desaceleração exatas por estado/equipamento no Last Day.
- Amortecimento visual de giro e câmera em execução.
- Curvas de animação e comportamento completo em obstáculos.
- Paridade no celular: exige um protótipo jogável e comparação lado a lado.

O APK, bibliotecas, imagens, animações e código do Last Day não foram adicionados ao repositório do Fim da Colheita. Este registro contém apenas fatos da análise e especificações para implementação própria.
