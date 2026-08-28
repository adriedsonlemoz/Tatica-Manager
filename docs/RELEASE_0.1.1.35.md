# Release 0.1.1.35 — Última camada visual antes do áudio

## Escopo

Esta release fecha a etapa visual anterior ao áudio, preservando a separação Match Engine → apresentação → Flame.

## Alterações

- replay usa a câmera normal como referência, com zoom mais discreto, pan/interpolação mais suave e retorno progressivo;
- identidade de jogador continua determinística por `Player.id`, ganha leitura de idade aparente e mantém cabeça/ombros sem imagens externas por atleta;
- novo `PlayerCard` reutilizável possui variantes compacta, média e detalhada, compartilhando a mesma fonte de dados;
- nova área **Clubes** permite consultar os clubes da carreira, estádio, informações básicas, elenco e perfil reutilizado de qualquer jogador;
- perfil do jogador agora resolve o clube proprietário e só mostra ações de renovar/vender para o clube do usuário;
- confirmação global deixou o topo da Home e passa a aparecer na região inferior da área útil, sem cobrir cabeçalho ou Notícias e eventos;
- CI passa a exigir keystore release persistente reconstruída por GitHub Secrets; o APK deixa de usar `signingConfigs.debug`;
- documentação da assinatura em `docs/APK_SIGNING.md` explica a possível última reinstalação ao trocar da chave debug antiga para a chave persistente.

## Compatibilidade

- `applicationId` preservado;
- nenhum ID de clube/jogador alterado;
- nenhum schema de save alterado;
- SQLite e payload de carreira permanecem compatíveis;
- nenhuma lógica de resultado foi movida para Flame;
- áudio não foi implementado.

## GitHub Secrets necessários

`TATICA_KEYSTORE_BASE64`, `TATICA_KEYSTORE_PASSWORD`, `TATICA_KEY_ALIAS` e `TATICA_KEY_PASSWORD`.

## Versionamento

- release/versionName: `0.1.1.35`;
- pubspec: `0.1.1+37`;
- Android versionCode: `37`.

## Validação

Os comandos de versionamento e Flutter devem ser executados após a sincronização. O resultado efetivamente executado é registrado na entrega, sem presumir sucesso do GitHub Actions.
