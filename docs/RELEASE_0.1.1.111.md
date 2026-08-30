# Release 0.1.1.111 — músicas do menu mais leves

**Android versionCode:** `112`  
**pubspec:** `0.1.1+112`

## Objetivo

Reduzir novamente o espaço ocupado pelas cinco músicas atuais do menu sem trocar faixas, sem cortar trechos e sem alterar o comportamento do player.

## Alteração aplicada

- mantém as cinco músicas atuais e os mesmos nomes/caminhos `.ogg`;
- recomprime somente os cinco assets de música de menu de Vorbis para **Opus em contêiner OGG**;
- mantém áudio estéreo e duração completa;
- usa VBR em torno de 64 kbps, priorizando qualidade perceptível para reprodução de fundo em Android;
- não altera `AudioCatalog`, `AudioManager`, shuffle, loop, seleção manual ou playlist personalizada.

## Resultado de tamanho

| Faixas do menu | Antes | Depois |
|---|---:|---:|
| 5 músicas | 10.386.273 bytes | 8.852.371 bytes |

Economia total: **1.533.902 bytes (~14,8%)**.

## Compatibilidade

O projeto usa `just_audio` no Android com backend baseado em ExoPlayer. O contêiner OGG com áudio Opus é suportado no pipeline Android/ExoPlayer moderno. Os caminhos dos assets permanecem iguais, portanto nenhuma referência de código precisou ser alterada.

## Preservado

- as mesmas cinco músicas;
- nomes e ordem do catálogo;
- efeitos de interface e partida;
- Match Engine;
- saves, IDs, regras e resultados;
- `al-sistemas.json` continua removido.
