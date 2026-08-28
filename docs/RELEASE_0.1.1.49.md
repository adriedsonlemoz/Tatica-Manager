# Release 0.1.1.49 — Áudio, feedback e acabamento da carreira

**Android versionCode:** 51  
**pubspec:** `0.1.1+51`  
**CareerState schema:** 9

## Alterações

- `Football.mp3` substitui a playlist padrão e toca em volume inicial baixo; `somdenavegamenu.mp3` atende toque e navegação.
- Narração inicia desligada e a velocidade padrão da partida passa a 1x.
- Feedback tátil fica centralizado na apresentação e reage a trave, gol, pênalti, cartões, falta e lesão, respeitando a preferência do usuário.
- Avisos de validação da criação de carreira passam a diálogo temático centralizado.
- A bola recebe quatro estilos persistentes e movimento ocioso discreto, sem alterar a timeline ou o Match Engine.
- O editor do técnico mantém o avatar visível e importa foto com validação, recorte quadrado e limite já utilizados para jogadores.
- Clubes usa a navegação País > Campeonato > Série > Clubes.
- Contratos exibe foto/overall e renovação direta; a proposta oferece -10%, valor pedido, +10% e +20%, mantendo slider e contraproposta.
- As três zonas da classificação ficam compactas no rodapé.

## Compatibilidade

O schema permanece em 9. `matchBallStyle` e `customPhotoPath` possuem defaults opcionais, portanto saves anteriores continuam válidos. IDs persistentes, TransferEngine, ContractEngine e Match Engine não foram substituídos.

## Testes

Foram atualizados os testes de defaults/serialização do áudio, velocidade e bola, integridade dos novos assets e persistência da foto do técnico. Flutter analyzer, testes e APK dependem da disponibilidade real do SDK e não devem ser considerados aprovados sem execução.
