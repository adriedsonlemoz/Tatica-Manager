# Release 0.1.1.66

## Escopo

Esta release audita a consistência visual dos módulos remodelados na 0.1.1.65. O foco é contraste, combinação de superfícies e coerência entre aparência e interação, conectando somente módulos que já existem no jogo.

## Alterações

- **Tema e contraste:** `AppBar` usa o mesmo fundo estrutural das telas e cores de clube muito escuras passam por um acento legível quando usadas sobre superfícies escuras.
- **Dia de Jogo:** cards de posição, forma, moral, condição, pressão e formação agora levam a Classificação, Calendário, Elenco, Departamento Médico, Táticas e Escalação; Agenda e estádio do confronto também passam a ser ações reais.
- **Contratos:** os indicadores do resumo passam a aplicar os filtros já existentes, em vez de parecerem botões sem resposta.
- **Categoria de Base:** todo o card do jovem abre seu perfil; a ação separada de promoção continua preservada.
- **Finanças:** categorias acionáveis conectam Estádio, Contratos e Mercado; Patrocínios deixa de empilhar `SectionCard` dentro de outro card, reduzindo excesso de bordas e fundos.
- **Mercado:** ganha retorno opcional quando é aberto como módulo secundário, sem mudar seu uso normal na navegação principal.
- **Estádio:** remove ação de edição duplicada, corrige contraste do rótulo sobre a cena e usa o menor valor entre orçamento do estádio e caixa do clube para habilitar melhorias, evitando botão aparentemente disponível que falharia na confirmação.
- **Escudos sem imagem:** gradientes muito escuros recebem ajuste de contraste para não desaparecerem no fundo.

## Arquitetura e compatibilidade

- Nenhum sistema novo de gameplay foi criado.
- Nenhuma regra da partida foi movida para widgets ou Flame.
- `CareerState` permanece no schema 11.
- Saves, IDs persistentes, controllers e engines existentes permanecem compatíveis.

## Testes e validação

- Adicionado `test/visual_navigation_consistency_test.dart` para proteger navegação visual, contraste e disponibilidade coerente das obras do estádio.
- Mantidos os testes estruturais e de regressão da 0.1.1.65, incluindo o limite de cinco substituições.
- A validação Flutter local depende da disponibilidade do SDK no ambiente de entrega.
