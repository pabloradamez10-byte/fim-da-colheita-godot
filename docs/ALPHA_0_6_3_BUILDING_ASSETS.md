# Alpha 0.6.3 — Construções completas e estabelecimentos

A Alpha 0.6.3 adiciona construções autorais completas, com teto, paredes, laterais, entrada e janelas, sem substituir sua estrutura 3D funcional.

## Categorias

- casas urbanas de dois andares;
- casas rurais coloniais de dois andares;
- casas fortificadas de dois andares;
- hospitais;
- mercados;
- bares;
- laticínios;
- farmácias;
- oficinas;
- postos de combustível.

As casas possuem três arquiteturas completas e distintas, não apenas variações de cor. Cada sobrado mantém uma planta ampla de `14,6 × 12,4` unidades e passa a ter aproximadamente `362 m²` de área útil nos dois pisos.

Os demais estabelecimentos possuem prédio completo transparente próprio, símbolo reconhecível e acabamento envelhecido coerente com o mundo de **Fim da Colheita**. Não são placas, pórticos ou recortes isolados de fachada. Cada categoria agora reconstrói uma planta 3D dedicada, em vez de apenas reutilizar os cômodos de uma casa.

| Local | Planta explorável | Pisos | Loot interno | Identidade funcional |
|---|---:|---:|---:|---|
| Hospital | `18 × 16` | 2 | 8 | recepção, tratamento, enfermaria e suprimentos |
| Mercado | `18 × 14` | 1 | 5 | quatro corredores e caixa |
| Bar | `13 × 11` | 1 | 4 | balcão e três mesas |
| Laticínio | `20 × 16` | 1 | 5 | tanques, processamento e câmara fria |
| Farmácia | `12 × 10` | 1 | 5 | prateleiras, balcão e armário médico |
| Oficina | `18 × 14` | 1 | 4 | bancada, estantes de peças e baú |
| Posto | loja `11 × 9` + pátio | 1 | 5 | loja, cobertura e duas bombas de combustível |

## Exploração e loot

- segundo piso real com quatro ambientes e vão de escada;
- interação para subir e descer, compatível com os controles mobile atuais;
- caixa, guarda-roupa, armário, baú e armário de remédios com loot contextual no piso superior;
- hospital de dois pisos com escada, enfermaria e loot médico nos dois andares;
- loot especializado por estabelecimento: comida, água, remédios, peças e combustível;
- geladeira, despensa, cômodas, estante e móveis de loot do térreo preservados;
- filtro vertical impede interagir com loot através do piso ou teto.

## Integração segura

- o exterior completo acompanha o nó de telhado e desaparece quando o jogador entra;
- no térreo, o segundo piso também é ocultado para permitir leitura dos cômodos;
- no andar superior, somente o telhado/exterior é ocultado;
- interiores, portas e recorte de telhado permanecem ativos;
- casas preservam suas colisões e interiores existentes;
- estabelecimentos recebem paredes, porta principal, divisória interna, móveis e colisões próprias;
- fluidez da Alpha 0.6.1 e natureza da Alpha 0.6.2 são preservadas;
- schema de save permanece em `600`.
