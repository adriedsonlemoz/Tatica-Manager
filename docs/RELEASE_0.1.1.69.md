# Release 0.1.1.69

## Escopo

Reformulação do fluxo de criação de carreira e da identidade visual do Tática Manager, com foco em reduzir a sensação de aplicativo excessivamente escuro, melhorar proporções e hierarquia dos cards e integrar o primeiro acesso da carreira às telas legais e de apresentação.

## Identidade visual

- substitui a base quase preta por azul-grafite em camadas (`background`, `surface`, `surfaceRaised` e `surfaceSoft`);
- mantém o verde como cor principal de ação/seleção, em vez de usá-lo como preenchimento dominante;
- ajusta bordas, textos secundários, navegação e dourado de destaque;
- remove cores quase pretas hardcoded da composição principal da Home para que a nova paleta também apareça após entrar na carreira.

## Criação de carreira

- formações continuam em três colunas, agora com cards menores e campo compacto;
- seleção de clubes mantém duas colunas, reduz a altura dos cards e aumenta a presença visual do escudo;
- seleção de técnicos remove pesquisa e filtros e passa a usar lista direta compacta com avatar, reputação, nacionalidade, clube e estilo;
- perfil e editor de aparência usam densidade menor e grupos reutilizáveis para rosto/pele, cabelo, traços, barba/bigode e expressão;
- duração visual da partida pode ser escolhida na última etapa da criação.

## Assinatura e primeira entrada

- assinatura do contrato deixa o papel branco provisório e usa superfícies azul-grafite, escudo, clube, treinador e temporada reais;
- após a assinatura, novas carreiras recebem uma apresentação editorial com técnico, avatar/foto, clube, escudo, competição, temporada e data disponíveis no save;
- a apresentação é controlada por uma chave em `app_meta` e removida ao tocar em **Começar carreira**, portanto aparece somente uma vez por nova carreira;
- saves antigos não recebem apresentação retroativa.

## Termos, privacidade e informações

- primeira abertura do aplicativo exige aceite da versão atual dos Termos de Uso;
- Termos de Uso e Política de Privacidade abrem em telas internas do jogo;
- Central de Carreiras recebe links discretos para Sobre o jogo, Como funciona, Termos de Uso, Privacidade, Edição e Configurações;
- configurações antes da carreira armazenam defaults no `app_meta` existente e não substituem preferências de saves já criados.

## Duração das partidas e compatibilidade

A apresentação passa a trabalhar em minutos reais **por tempo**:

- Rápida: 1 minuto por tempo;
- Normal: 2 minutos por tempo;
- Completa: 3 minutos por tempo.

A leitura de saves antigos converte os presets anteriores preservando a intenção de cada opção: 4 → 1, 6 → 2 e 8 → 3 minutos por tempo. O valor altera somente a cadência de apresentação dos 90 minutos já simulados.

## Arquitetura e persistência

- Match Engine não recebe regra nova e continua responsável pelo resultado/timeline da partida;
- Flame continua somente como camada de representação;
- `CareerState` permanece no schema 11;
- banco SQLite permanece na versão 2; as novas preferências reutilizam a tabela `app_meta` já existente;
- IDs de clubes, jogadores, técnicos, fixtures e saves não são modificados;
- componentes novos de assinatura, links da Central de Carreiras e aparência foram separados para evitar crescimento desnecessário das telas principais.

## Testes atualizados/adicionados

- `career_creation_ui_test.dart`: novas dimensões de formação/clubes, remoção de filtros e seleção de duração;
- `audio_system_test.dart`: default atual e conversão retrocompatível de 4/6/8 para 1/2/3;
- `career_onboarding_ui_test.dart`: paleta, aceite legal, links iniciais, apresentação única e duração por tempo;
- `_MemoryCareerRepository` de `controller_refactor_test.dart` acompanha as novas operações genéricas de `app_meta`.

## Validação

- `python3 tool/versioning.py verify` deve permanecer limpo antes da entrega;
- este ambiente precisa de Flutter/Dart SDK para executar `dart format`, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release`; quando o SDK não estiver disponível, essas etapas devem ser validadas pelo GitHub Actions antes de considerar o APK final aprovado.
