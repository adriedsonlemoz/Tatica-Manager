# Tática Manager 0.1.1.56

## Escopo

Esta release concentra seis melhorias sem alterar a lógica do Match Engine: feedback tátil, inicialização da música, Finanças, criação de carreira, sistema de técnicos e Central de Edição.

## Vibração

O feedback háptico foi centralizado para não vibrar em botões, cards, navegação, listas, menus, editor, replay ou eventos normais da partida. A única apresentação que solicita vibração é gol/contra, usando impacto curto e respeitando `GameSettings.haptics`.

## Música

O `AudioManager` continua singleton. As preferências da última carreira são consultadas durante o splash e a preparação da playlist é serializada para impedir cargas concorrentes no mesmo player. Música desligada e volumes persistidos continuam respeitados.

## Finanças

A tela passa a ter cabeçalho financeiro, cards de saldo/orçamento/receitas/despesas/resultado, gráfico simples de receitas x despesas, evolução recente do saldo e seções expansíveis para visão geral, orçamentos, receitas, despesas, salários, patrocínios, estádio e histórico. Todos os valores são derivados dos dados financeiros já existentes.

## Técnicos e criação de carreira

A criação de carreira inicia em `Escolha seu técnico`, oferecendo técnico existente ou criação própria. Cidade e estado deixam de ser exigidos no fluxo inicial. O perfil de técnico foi ampliado com ID estável, data de nascimento opcional, clube, contrato, reputação, estilo, formação e mentalidade preferidas, experiência e nível geral.

O banco de técnicos usa o mesmo `ClubIdentityPack` da Central de Edição, agora em formato v3. A seção Técnicos permite pesquisar, criar, editar, importar, exportar, restaurar dados padrão e excluir somente técnicos personalizados. Aparência e foto reutilizam o editor já existente, incluindo olhos, sobrancelhas, nariz e boca já suportados pelo modelo, além de reposicionamento/zoom antes de normalizar a imagem. A exportação de técnicos usa a ponte Android já existente para salvar em Downloads/TaticaManager/.

## Compatibilidade de saves

`CareerState` evolui do schema 10 para o schema 11 para persistir a base de técnicos. Saves anteriores geram automaticamente referências de técnicos a partir dos clubes existentes e preservam o técnico do usuário, sem alterar IDs de clubes, jogadores, partidas ou negociações. O técnico escolhido para a carreira mantém seu ID e não é duplicado no banco.

## Match Engine e CI

Nenhuma regra do Match Engine foi modificada. O workflow GitHub Actions permanece inalterado e deve continuar publicando somente o APK versionado nos Artifacts.
