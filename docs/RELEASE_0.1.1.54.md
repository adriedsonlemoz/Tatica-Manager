# Release 0.1.1.54 — Áudio estável e Central de Diagnóstico

**Android versionCode:** `56`  
**pubspec:** `0.1.1+56`  
**CareerState schema:** `10`

## Correções de áudio

- A seleção múltipla continua disponível.
- Cada música é importada sequencialmente usando `XFile.openRead()` e escrita por stream em arquivo temporário `.part`.
- O arquivo temporário só é renomeado após a cópia concluir; em falha, o parcial é removido.
- Nenhuma lista de bytes com os arquivos completos é mantida em memória.
- Playlist, remoção, reprodução, liga/desliga, volumes, troca de faixa e persistência continuam usando o mesmo `AudioSettings` retrocompatível.
- `AudioSettingsScreen` guarda a referência do `GameController` em `initState` e não consulta `ref` durante `dispose`.

## Central de Diagnóstico

- Acesso discreto por pressionar e segurar **Sobre / Novidades** em Configurações.
- Registra de forma persistente erros Flutter, erros Dart assíncronos e checkpoints recentes.
- Android fornece fabricante, modelo, versão, SDK, ABIs e, em Android 11+, a última saída do processo via `ApplicationExitInfo`.
- Crash nativo/Java/Kotlin não tratado é gravado antes de delegar ao handler padrão.
- O relatório distingue quando disponível `CRASH`, `CRASH_NATIVE`, `ANR`, `LOW_MEMORY` e outros motivos retornados pelo Android.
- Os registros Dart são limitados a 80 entradas e o arquivo é protegido por limite de tamanho para evitar crescimento indefinido.
- A tela permite Atualizar, Copiar, Exportar TXT e Limpar.
- No Android 10+, exporta via MediaStore para `Downloads/TaticaManager/`; versões anteriores usam a pasta pública Downloads com permissão limitada até API 28.

## Compatibilidade

Não altera Match Engine, Flame, schema 10, IDs persistidos ou estrutura de saves. O diagnóstico usa persistência própria na área de suporte do aplicativo.

## Testes

Foram adicionadas regressões estruturais para cópia sequencial em stream, ausência de `ref` no `dispose`, captura global, limites do log, ações da Central e ponte Android. A serialização existente da playlist continua coberta por `audio_system_test.dart`.
