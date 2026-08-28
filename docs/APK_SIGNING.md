# Assinatura persistente do APK

O projeto está preparado para usar uma única chave release persistente. O `applicationId` permanece `com.taticamanager.tatica_manager` e o `versionCode` continua crescente.

## Estado temporário

Enquanto a keystore ainda não estiver configurada no GitHub, o CI pode continuar gerando APK para testes usando a chave debug do runner. Isso mantém o desenvolvimento funcionando, porém essa chave não é garantida entre builds e o Android pode exigir desinstalar o APK anterior.

Quando os quatro Secrets forem cadastrados, o mesmo workflow passa automaticamente a usar `signingConfigs.release` persistente.

## Secrets da assinatura persistente

- `TATICA_KEYSTORE_BASE64`: conteúdo Base64 da keystore `.jks` única;
- `TATICA_KEYSTORE_PASSWORD`: senha da keystore;
- `TATICA_KEY_ALIAS`: alias da chave;
- `TATICA_KEY_PASSWORD`: senha da chave.

A keystore não deve ser adicionada ao repositório. O workflow a reconstrói em `$RUNNER_TEMP` quando `TATICA_KEYSTORE_BASE64` está presente e o Gradle configura `signingConfigs.release` somente quando as quatro credenciais estão disponíveis.

Configuração parcial é tratada como erro: use os quatro Secrets ou nenhum enquanto estiver na fase temporária.

## Primeira instalação após a troca

APKs produzidos antes da chave persistente podem ter assinatura diferente. Por isso, a primeira migração para a assinatura definitiva pode exigir uma última desinstalação/reinstalação. Isso remove dados locais do aplicativo; faça backup/exportação da carreira quando aplicável.

Depois que uma versão assinada pela chave persistente estiver instalada, as próximas versões assinadas pela mesma chave e com `versionCode` maior poderão atualizar por cima, preservando banco SQLite e saves.

O Artifact do CI continua contendo somente `tatica-manager-<versão>.apk`; `pubspec.lock` não é publicado.
