# Release 0.1.1.41 — Elenco, escalação e identidade dos jogadores

## Objetivo

Esta release concentra a reformulação de Elenco/Escalação e pequenas correções da partida, preservando o Match Engine como fonte das regras e mantendo o aplicativo em orientação retrato.

## Alterações

- adiciona mute/reativação rápida na barra da partida usando a mesma chave master `GameSettings.sound` das Configurações;
- reorganiza os cinco grupos de tática ao vivo em três opções lado a lado, mostrando a explicação apenas da escolha ativa;
- preserva a ordem de `starterIds` como associação jogador → slot da formação, evitando redistribuição silenciosa após uma troca manual;
- mantém a penalidade de posição centralizada em `LineupEngine.effectiveOverall()` e consumida pelo Match Engine;
- adiciona Autoescalação visível reaproveitando `GameController.autoSelectLineup()` e `LineupEngine.autoSelect()`;
- ordena candidatos de troca/substituição pelo OVR efetivo na função, adequação de posição e condição;
- transforma o campo da Escalação em representação horizontal 105:68 dentro da tela retrato;
- mostra avatar, função e OVR efetivo no campo, com alerta visual quando o atleta está improvisado;
- reorganiza o Elenco por Goleiros, Zagueiros, Laterais, Meio-campistas e Atacantes;
- amplia os cards com condição, fadiga, forma recente, cartões, lesão/suspensão e contexto Titular/Banco/Fora;
- registra as últimas cinco notas de cada atleta como forma recente, sem remover a média da temporada;
- adiciona suporte opcional a foto personalizada do jogador, com fallback para o avatar procedural existente;
- importa PNG/JPG/WebP no editor de banco, valida tamanho/dimensões, recorta o centro em formato quadrado, normaliza e salva cópia privada do app;
- mantém edição de foto fora do fluxo normal da carreira: ela pertence ao editor do banco de jogadores;
- cria componentes compartilhados de status/avaliação preparados para futura reutilização em Categoria de Base, Centro Médico e Centro de Treino.

## Persistência e compatibilidade

Os novos campos `customAvatarPath` e `recentRatings` são opcionais no JSON de `Player`. Saves antigos continuam válidos e usam avatar procedural/forma vazia quando esses campos não existem. Não há alteração de IDs persistidos nem criação de uma arquitetura paralela.

A ordem de `starterIds` passa a ter significado explícito de slot. Saves atuais já gravam uma lista ordenada; ao trocar de formação, `GameController.setFormation()` continua gerando uma nova Autoescalação compatível com os slots da formação escolhida.

## Testes adicionados

- preservação da ordem jogador → slot;
- Autoescalação excluindo indisponíveis;
- redução de OVR fora de posição e reflexo real em `MatchStrengthCalculator`;
- priorização de candidatos pela função;
- serialização de foto personalizada e forma recente;
- retrocompatibilidade de JSON antigo sem os novos campos.

## Validação necessária

Executar antes da publicação:

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

No aparelho, conferir especialmente campo horizontal em telas pequenas, importação de fotos pelo seletor Android, atualização da imagem em todos os cards, mute durante a partida, tática em três colunas, Autoescalação, substituições e save/load.
