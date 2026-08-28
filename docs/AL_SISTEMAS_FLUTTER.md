# Tática Manager 2 + AL Sistemas

## Diagnóstico

O problema original não era apenas o nome do ZIP. O pacote Flutter anterior não possuía uma fonte de metadados que o fluxo de publicação do AL Sistemas reconhecesse como manifesto canônico.

A análise do código do AL Sistemas mostrou que o módulo de publicação já procura explicitamente por `al-sistemas.json` tanto no repositório quanto dentro do ZIP. Quando encontra esse arquivo, usa `product`/`name` e `version` para identificar o projeto e a versão.

Por isso o Tática Manager 2 passou a incluir na raiz:

- `al-sistemas.json` — fonte oficial para AL Sistemas e outras ferramentas;
- `VERSION` — versão em texto simples;
- `app.json` — identidade externa;
- `pubspec.yaml` — manifesto oficial Flutter;
- `tool/versioning.py` — sincronização/validação automática.

## Manifesto canônico

A release atual declara:

```json
{
  "product": "Tática Manager",
  "name": "tatica_manager",
  "displayName": "Tática Manager",
  "version": "0.1.1.8",
  "projectType": "flutter",
  "framework": "Flutter",
  "language": "Dart"
}
```

O arquivo real contém também os metadados Android, Flutter e do repositório.

## Por que não criar `package.json` falso

Não foi criado um `package.json` apenas para satisfazer o detector. Isso faria o projeto Flutter parecer um projeto Node/npm e criaria uma segunda fonte de versão. A identificação correta deve vir do manifesto canônico e do `pubspec.yaml`.

## Observação sobre o detector de tipo do AL Sistemas

O fluxo atual do AL Sistemas já entende `al-sistemas.json` para **nome e versão**, mas o analisador geral de stack ainda detecta principalmente Node/React/Capacitor/Python/etc. e não interpreta `pubspec.yaml` como Flutter. O Tática Manager agora fornece `projectType: flutter`, `framework: Flutter` e `language: Dart`, porém o painel precisa consumir esses campos para exibir “Flutter” como tipo/framework em todas as telas.

Uma melhoria recomendada no AL Sistemas é dar prioridade aos campos do manifesto e, como fallback, reconhecer a presença de `pubspec.yaml`:

```js
if (manifest?.projectType === 'flutter' || rootNames.has('pubspec.yaml')) {
  tipo = 'Aplicação Flutter'
  add('Flutter')
  packageManager = 'pub'
}
```

Também é recomendável que o comparador de versões do AL Sistemas aceite quatro componentes (`A.B.C.D`) para comparar corretamente releases como `0.1.1.3` e `0.1.1.5`.

## Resultado esperado após publicar esta release

Na primeira publicação com o novo manifesto, o GitHub ainda pode aparecer sem versão anterior até o commit ser concluído. Após `al-sistemas.json` chegar à branch `main`, as próximas publicações passam a ter uma fonte canônica previsível para:

- produto: `Tática Manager`;
- versão no GitHub: `0.1.1.8`;
- versão do pacote: `0.1.1.8`;
- manifesto: `al-sistemas.json`;
- framework declarado: Flutter;
- linguagem declarada: Dart.

A partir daí, cada entrega deve atualizar primeiro `al-sistemas.json` e executar `python3 tool/versioning.py sync`.
