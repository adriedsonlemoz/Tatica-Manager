# Release 0.1.1.135 — Transmissão legível e disciplina integrada

## Objetivo

Melhorar a leitura e a sensação de movimento da partida ao vivo, manter todos os comandos essenciais na mesma tela e tornar cartões e suspensões visíveis nos módulos de gestão do elenco.

## Transmissão sem rolagem

- Placar, rodada, campo, timeline, controles, estatísticas e narração formam uma composição fixa.
- A composição usa redução proporcional em alturas menores, sem esconder comandos nem criar rolagem vertical.
- Intervalo e fim de jogo usam o espaço reservado à narração, evitando deslocar o campo.
- O placar reduz escudos e pontuação, aceita nomes em duas linhas e preserva os cartões já apresentados.
- Modais de simulação, tática, substituição, rodada e histórico usam a superfície azul-grafite do aplicativo.

## Campo e apresentação visual

- A posição-base continua vindo das formações reais dos dois clubes.
- Blocos acompanham bola e posse, com separação adicional quando jogadores convergem para o mesmo ponto.
- Micro movimentos dão vida aos atletas sem substituir os deslocamentos definidos pelos eventos.
- Durante o jogo, aparecem os nomes do jogador ativo, envolvidos no lance e atletas próximos da bola; na pausa, todos são identificados.
- A bola deixa de oscilar quando está parada.
- A câmera mantém aproximação discreta apenas em chutes, defesas, trave, pênaltis, gols e replay, com reenquadramento controlado.
- Eventos principais foram compactados e movidos para a parte superior do campo.
- A timeline mostra apenas ocorrências relevantes.

## Cartões e suspensões

- `PlayerDiscipline` centraliza o limite de três amarelos e expõe os estados suspenso e pendurado.
- Escalação mostra indicadores no campo, banco e resumo, usando a competição da próxima partida.
- Elenco inclui uma coluna de cartões e considera pendurados no filtro Atenção.
- Perfil do jogador apresenta amarelos atuais, total do torneio, vermelhos e situação disciplinar.
- Estatísticas ao vivo separam cartões de mandante e visitante e usam as cores dos uniformes para identificação.

## Compatibilidade e regras

- Nenhuma probabilidade, força, placar, calendário ou resultado do Match Engine foi modificado.
- Flame continua apenas representando a timeline calculada previamente.
- O formato de persistência não foi alterado.

## Validação

- Testes estruturais foram atualizados para proteger a composição sem rolagem, etiquetas contextuais, separação de jogadores e integração disciplinar.
- O ambiente de edição não possui Flutter/Dart instalado; `flutter analyze`, `flutter test` e a geração do APK permanecem sob responsabilidade do workflow versionado do projeto.
