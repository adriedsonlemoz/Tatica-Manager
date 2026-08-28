# Release 0.1.1.13 — Clubes fictícios, editor e importação

## Alterações

- Substitui os 20 clubes padrão por identidades fictícias.
- Adota IDs internos neutros e permanentes `br-club-001` a `br-club-020`.
- Adiciona `nickname` ao modelo `Club` com fallback para saves anteriores.
- Adiciona editor de nome, apelido e sigla na Central de Carreiras.
- Permite editar o padrão usado por novas carreiras e, separadamente, cada save existente.
- Adiciona importação de pacotes comunitários JSON/`.tmclubs` no formato `tatica-manager-clubs` v1.
- Restringe o pacote importado à identidade dos 20 IDs esperados; dados esportivos e financeiros não fazem parte do formato.
- Migra automaticamente IDs legados ao listar, abrir ou editar saves antigos, preservando IDs dos jogadores.
- Atualiza classificação, histórico do jogador, descrições financeiras, notícias e textos históricos de partidas quando a identidade é alterada.
- Mantém a política do GitHub Actions de publicar somente o APK versionado.

## Persistência

Não houve alteração da versão do SQLite nem do schema do `CareerState`. O pacote padrão personalizado é salvo em `app_meta`. O novo `Club.nickname` usa `name` como fallback ao carregar payload antigo.

## Testes adicionados/atualizados

- IDs neutros e únicos dos clubes base;
- compatibilidade de `Club` sem `nickname`;
- encode/decode e validação de pacote comunitário;
- rejeição de IDs desconhecidos, ausentes e duplicados;
- preservação de dinheiro, orçamento, reputação, jogadores e IDs ao renomear;
- criação de carreira usando pacote padrão personalizado;
- isolamento da edição entre saves;
- migração idempotente de save legado, incluindo referências de partidas e histórico;
- save/load após personalização;
- presença do editor e do fluxo de importação na Central de Carreiras.

## Validação pendente

Executar no ambiente Flutter/CI:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Também validar em aparelho Android o seletor de arquivos do importador e o fluxo de edição em telas pequenas.
