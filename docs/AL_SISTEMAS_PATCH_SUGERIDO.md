# Ajuste recomendado no detector do AL Sistemas

O Tática Manager 2 já publica metadados suficientes em `al-sistemas.json`. Este ajuste é opcional no projeto do jogo, mas recomendado no AL Sistemas para que a interface classifique Flutter/Dart corretamente e compare quatro componentes de versão.

## 1. Comparador A.B.C.D

O comparador atual de `backend/src/routes/github.js` considera no máximo três componentes. Uma forma compatível de aceitar tanto `1.0.161` quanto `0.1.1.3` é:

```js
function versaoPartes(value = '') {
  const match = String(value || '').trim().match(
    /^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:[-+].*)?$/
  )
  return match
    ? [
        Number(match[1] || 0),
        Number(match[2] || 0),
        Number(match[3] || 0),
        Number(match[4] || 0),
      ]
    : null
}

function compararVersoes(a, b) {
  const av = versaoPartes(a), bv = versaoPartes(b)
  if (!av || !bv) return null
  for (let i = 0; i < 4; i++) {
    if (av[i] !== bv[i]) return av[i] > bv[i] ? 1 : -1
  }
  return 0
}
```

## 2. Reconhecer Flutter no insight do repositório

Na função que já lê `al-sistemas.json`, dar prioridade ao manifesto e usar `pubspec.yaml` como fallback:

```js
const flutterDetected = Boolean(
  manifest?.projectType === 'flutter' ||
  String(manifest?.framework || '').toLowerCase() === 'flutter' ||
  rootNames.has('pubspec.yaml')
)

if (flutterDetected) add('Flutter')

const androidDetected = Boolean(
  rootNames.has('android') ||
  rootNames.has('build.gradle') ||
  rootNames.has('build.gradle.kts') ||
  frameworks.includes('Capacitor') ||
  flutterDetected
)

let tipo = 'Repositório de código'
if (flutterDetected) tipo = 'Aplicação Flutter'
else if (frontendDetected && backendDetected) tipo = 'Aplicação Full-stack'
else if (frontendDetected) tipo = 'Aplicação Frontend'
else if (backendDetected) tipo = 'Serviço Backend'

if (flutterDetected) packageManager = 'pub'
```

## 3. ZIP

O analisador de ZIP do AL Sistemas já procura `al-sistemas.json` e já usa `product`/`name` e `version`. O pacote do Tática Manager 2 inclui esse arquivo na raiz lógica do projeto, então não é necessário criar `package.json` artificial.
