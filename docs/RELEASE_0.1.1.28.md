# Release 0.1.1.28

## Identidade visual dos jogadores

Esta release inicia a evolução gráfica do Tática Manager 2 com uma primeira camada reutilizável de rostos/avatares 2D para os jogadores, mantendo a lógica do jogo, o mercado e a partida desacoplados da apresentação.

## Abordagem adotada

O projeto já possuía `VisualProfile` persistido com campos pequenos para tom de pele, cabelo, cor do cabelo, tipo corporal, altura visual e chuteira. Esse contrato foi preservado.

A nova classe pura `PlayerAvatarIdentity` usa:

- `Player.id` como origem de uma seed FNV-1a definida pelo próprio projeto;
- `VisualProfile.skinTone`, `hairStyle` e `hairColor` como opções editáveis já existentes;
- a seed do ID para derivar formato do rosto, olhos, cor dos olhos, sobrancelhas, nariz, boca, barba, bigode e pequenos detalhes.

Nenhum novo campo foi adicionado ao save ou ao SQLite. Idade, overall, condição, moral e outras mudanças de carreira não alteram o rosto.

## Renderização

`PlayerAvatar` é um widget reutilizável com `CustomPainter` dedicado, gradiente discreto, rosto em camadas e variações visuais. A pintura fica dentro de `RepaintBoundary`, usa `willChange: false` e não carrega imagens individuais por jogador, evitando custo de I/O e crescimento do save em listas grandes.

A identidade foi separada da pintura para permitir que, futuramente, os mesmos índices sejam mapeados para sprites/PNG/SVG de maior fidelidade sem alterar saves nem telas consumidoras.

## Integrações visuais

- **Elenco:** avatar compacto, overall, nome, posição, idade e condição no mesmo card, mantendo boa densidade.
- **Perfil:** remove o grande placeholder genérico de personagem e cria cabeçalho compacto com rosto em destaque, clube, posição, idade, nacionalidade, overall, potencial, altura, peso e pé dominante.
- **Mercado:** rosto nas listas sem alterar filtros, janela ou regras de transferência.
- **Negociação de compra:** rosto aparece no cabeçalho do atleta negociado.
- **Proposta recebida:** rosto do atleta do usuário aparece no diálogo quando disponível.
- **Notícias:** eventos que possuem `playerId` exibem o avatar de forma discreta; os demais mantêm o ícone por tipo de notícia.

## Arquitetura preservada

Não houve alteração em:

- `GameController`;
- `LiveMatchController`;
- Match Engine;
- Flame;
- `TransferEngine`;
- regras do mercado CPU;
- schema do `CareerState`;
- schema SQLite;
- IDs persistidos.

## Testes adicionados

`test/player_avatar_identity_test.dart` cobre:

- estabilidade da identidade para o mesmo `Player.id`;
- estabilidade após serialização/save-load;
- independência de idade, overall, condição e moral;
- reaproveitamento dos campos visuais editáveis existentes;
- variedade para 600 IDs distintos;
- presença do avatar nas telas previstas e ausência do antigo placeholder do perfil.

## Validação obrigatória

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

A validação visual final dos rostos, tamanhos e densidade dos cards ainda precisa ser feita em aparelho físico. O GitHub Actions deve continuar publicando somente `tatica-manager-0.1.1.28.apk`, sem `pubspec.lock` como Artifact.
