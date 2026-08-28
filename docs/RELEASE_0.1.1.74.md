# Release 0.1.1.74

## Escopo

Integração da nova playlist de menu e refinamento da apresentação exibida somente na primeira entrada de uma carreira.

## Música de menu

- remove dos assets e do catálogo a música anterior `football.mp3` e os antigos `menu_01.m4a` a `menu_05.m4a`;
- adiciona exclusivamente as 11 faixas OGG otimizadas fornecidas para esta etapa em `assets/audio/menu/`;
- mantém `AudioManager` como único player de música, sem serviço paralelo;
- expõe a faixa atual por `MenuPlaybackState`;
- permite avançar manualmente para a próxima música;
- permite selecionar qualquer faixa da playlist ativa;
- mantém shuffle, loop, pausa durante a partida, retomada ao sair e playlist personalizada do aparelho;
- usa títulos/artistas derivados dos nomes dos arquivos fornecidos, porque os OGG não possuem metadados embutidos;
- impede `tool/generate_audio_assets.py` de recriar a playlist M4A antiga.

## Interface de áudio

`audio_settings_screen.dart` continua responsável pelas preferências e passa a usar `menu_music_player_card.dart` para a interface navegável da playlist. O componente mostra "Tocando agora", próxima faixa e lista selecionável sem concentrar mais responsabilidades na tela principal.

## Apresentação da carreira

`career_arrival_screen.dart` foi reorganizada sem alterar a regra de onboarding:

- técnico/avatar, clube/escudo, competição, temporada e data continuam vindo do save;
- o cabeçalho editorial deixa de exibir um ícone de menu meramente decorativo;
- avatar e identidade do clube recebem mais presença dentro da matéria;
- a matéria fica integrada a uma moldura azul-grafite;
- o botão `Começar carreira` passa a ficar imediatamente após a apresentação, eliminando o grande vazio vertical observado em telas altas;
- a flag persistida que faz essa tela aparecer somente na primeira entrada permanece inalterada.

## Compatibilidade

- `CareerState` permanece no schema 11;
- SQLite permanece v2;
- IDs persistidos e saves existentes permanecem inalterados;
- `AudioSettings` não recebe campos obrigatórios novos;
- playlist personalizada existente continua suportada;
- Match Engine não conhece o player e não foi alterado;
- Flame continua somente como camada de apresentação da partida.

## Testes atualizados

- `audio_system_test.dart` passa a exigir as 11 faixas OGG, ausência dos assets antigos, API de faixa atual/seleção/próxima e proteção contra regeneração da playlist antiga;
- `career_onboarding_ui_test.dart` protege os elementos da apresentação reorganizada e a ausência do antigo ícone de menu decorativo.

## Validação obrigatória

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Somente etapas realmente executadas devem ser reportadas como aprovadas.
