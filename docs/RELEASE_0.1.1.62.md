# Tática Manager 0.1.1.62

## Escopo

Esta release adiciona importação de múltiplos escudos na Central de Edição sem alterar a lógica esportiva, o Match Engine ou o schema dos saves.

## Pack de escudos

- novo formato `tatica-manager-logos` versão 1;
- extensões aceitas: `.tmlogos` e `.json`;
- de 1 até a quantidade de clubes do banco atual por pack (20 na base distribuída hoje);
- associação exclusivamente por `Club.id` permanente (`br-club-001` ... `br-club-020` na base atual);
- `label` opcional apenas para conferência humana, sem participar da associação;
- packs parciais preservam os clubes que não aparecem no arquivo;
- IDs desconhecidos/duplicados são rejeitados;
- cada imagem reutiliza `ClubIconValidator`: PNG/JPG/WebP, 32–1024 px, até 256 KiB e proporção máxima 2:1;
- limite de 8 MiB para o arquivo selecionado;
- prévia mostra escudo atual → novo, nome atual e ID antes da confirmação;
- aplicação modifica somente `iconBase64`; nomes, siglas, estádio, kits, jogadores, técnicos e demais dados permanecem intactos;
- o usuário ainda precisa tocar em **Salvar alterações**, preservando o fluxo do editor existente.

## Compatibilidade

`CareerState.currentSchemaVersion` permanece 11. Não há migração nova: os escudos já eram persistidos por `iconBase64` em `ClubIdentity`/`Club`. Packs podem ser aplicados ao banco padrão ou a uma carreira existente sem trocar IDs.

## Testes

Foram adicionados testes para round-trip do novo formato, atualização parcial por ID, rejeição de IDs desconhecidos/duplicados, reutilização da validação de imagem e presença do fluxo na Central de Edição.

## Arquivos principais

- `lib/domain/club/club_logo_pack.dart`
- `lib/game/club/club_logo_pack_importer.dart`
- `lib/game/club/club_logo_pack_engine.dart`
- `lib/features/career/club_editor_screen.dart`
- `test/club_logo_pack_test.dart`
- `test/club_editor_ui_test.dart`
- `docs/CLUB_IDENTITIES.md`
- `docs/EXEMPLO_PACK_ESCUDOS.json`

O Match Engine e o workflow de GitHub Actions não são alterados por esta release.
