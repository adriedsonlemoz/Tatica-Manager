# Release 0.1.1.117 — Refinamento da Home compacta

## Escopo

Esta release refina exclusivamente a Home clara e a navegação para aproximar a implementação do mockup aprovado. Não altera regras de carreira, Match Engine, renderer libGDX, movimentação, schema de save ou IDs persistidos.

## Home

- mantém os seis atalhos na mesma faixa em larguras normais de telefone, reduzindo altura e ícones;
- usa `FittedBox` somente no rótulo dos atalhos para preservar nomes longos, principalmente `TRANSFERÊNCIAS`, sem quebrar o card;
- reduz a ação principal para 50 px, mantém o texto centralizado e posiciona o ícone de 28 px no extremo direito;
- distribui Jogos, Vitórias, Empates, Derrotas, Gols marcados e Gols sofridos em uma única linha no Resumo da Temporada;
- aumenta de forma discreta o espaçamento entre competição, data e estádio na Próxima Partida;
- normaliza os escudos da Próxima Partida para 58 px, alinhando-os com outros contextos compactos do aplicativo;
- amplia a separação entre o Resumo e os cards Classificação/Artilharia, além do espaço entre os dois rankings.

## Navegação

- `MoreScreen` recebe `showBackButton`, desativado por padrão para preservar o comportamento da aba raiz;
- a Home abre `MoreScreen(showBackButton: true)`, exibindo AppBar com `Voltar` e `Navigator.maybePop()`;
- não cria nova pilha ou arquitetura de navegação paralela.

## Testes

- adiciona `home_layout_refinement_test.dart` cobrindo proporções da ação, atalhos, Resumo, espaçamento, escudos e retorno no menu Mais;
- atualiza a regressão estrutural existente da Home para exigir o modo de retorno explícito ao abrir o menu pela barra superior.

## Compatibilidade

Permanecem preservados tema claro/escuro persistente, renderer Android libGDX, Flame fallback, movimentação da 0.1.1.113, `CareerState` schema 13, saves, IDs e fundação multi-competição.
