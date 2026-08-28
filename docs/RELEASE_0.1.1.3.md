# Release 0.1.1.3

## Objetivo

Esta release consolida correções visuais e de fluxo encontradas no primeiro uso real do APK e estabelece um versionamento previsível para o Tática Manager 2.

## Nova carreira

- O rodapé do assistente não fica mais sobre o conteúdo da etapa 3.
- O `PremiumScaffold` não estende o corpo por baixo do `bottomNavigationBar` por padrão.
- Após criar a carreira, existe uma transição em Flutter simulando a assinatura do contrato do técnico.
- A assinatura usa `CustomPainter` e animação de caminho; não existe imagem conceitual nova nem screenshot usado como tela.

## Home / navegação inferior

- O `GameShell` não desenha mais o conteúdo por trás da navegação inferior.
- A navegação é protegida por `SafeArea` para evitar conflito com a área de gestos/botões do Android.

## Fullscreen Android

- O aplicativo aplica `SystemUiMode.immersiveSticky`.
- Status bar e navigation bar recebem configuração transparente/imersiva.
- A orientação permanece portrait.
- O modo imersivo é reaplicado ao retornar ao aplicativo.
- Também é reaplicado após mudanças de métricas, pois o teclado Android pode reexibir temporariamente as barras do sistema.
- O configurador nativo aplica fullscreen, cutout/edge-to-edge e contraste adequado nos estilos Android.

## Mercado e negociação

- A proposta inicial para jogador com clube parte do mínimo estimado de venda, em vez de começar propositalmente abaixo do valor aceito.
- Contraofertas são retornadas de forma estruturada.
- Valores exibidos na interface usam formatação monetária (`R$ 5,3 mi`, etc.) em vez de inteiros crus.
- O usuário pode aceitar diretamente a contraproposta.
- A tela mostra orçamento e saldo projetados após a taxa.
- A taxa da transferência é descontada imediatamente uma única vez.
- O salário entra na folha mensal; não é descontado antecipadamente como dois meses de salário.
- A compra gera movimentação financeira explícita e persiste a carreira atualizada.

## Versionamento

Versão canônica visível: `0.1.1.3`.

Mapeamento desta release:

| Local | Valor |
| --- | --- |
| `al-sistemas.json` | `0.1.1.3` |
| `VERSION` | `0.1.1.3` |
| `app.json` | `0.1.1.3` |
| Android `versionName` | `0.1.1.3` |
| Android `versionCode` | `5` |
| Flutter `pubspec.yaml` | `0.1.1+5` |
| Artifact | `tatica-manager-0.1.1.3-apk` |
| APK final | `tatica-manager-0.1.1.3.apk` |

O `pubspec.yaml` usa a forma SemVer aceita pelo ecossistema Dart/Flutter. A versão de quatro partes permanece a identificação pública/canônica da release.

## Proteção contra APK antigo

O GitHub Actions:

1. valida o manifesto canônico;
2. cria Android/iOS quando ausentes;
3. sincroniza as versões nativas;
4. executa `flutter clean` para evitar build antigo;
5. analisa e testa;
6. gera o APK release;
7. lê `output-metadata.json` do Android;
8. compara `versionName` e `versionCode` com `al-sistemas.json`;
9. falha o workflow se houver divergência;
10. publica o APK com a versão no próprio nome.

Assim um Artifact não pode ser considerado aprovado se tiver sido compilado com a versão anterior.
