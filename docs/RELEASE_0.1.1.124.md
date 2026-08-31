# Release 0.1.1.124 — Calendário, Táticas e Configurações redesenhados

**pubspec:** `0.1.1+125`  
**Android versionCode:** `125`

## Calendário

- Adota o cabeçalho compacto do clube e as abas **Mês**, **Agenda** e **Resultados**.
- Usa somente partidas, resultados e `CareerEvent` persistidos na carreira.
- Diferencia partida, treino registrado e outros eventos sem preencher dias com dados fictícios.
- Pagina listas maiores e mantém a página principal sem rolagem.

## Táticas

- Exibe formação, titulares e cinco reservas reais em campo vertical.
- Mantém somente Mentalidade, Pressão, Linha defensiva, Ritmo e Construção, que já alimentam o Match Engine.
- Formação, autoescalação e alterações táticas continuam salvas pelo `GameController`.
- Não adiciona as abas Instruções/Bolas paradas nem cria largura ou marcação sem suporte no domínio.

## Configurações

- Reorganiza áudio, vibração, partida, perfil, carreira e informações em cartões compactos sem rolagem principal.
- Mantém áudio avançado, playlist, sons personalizados, aparência, novidades, contato, Pix, saída e exclusão da carreira.
- Preserva duração e as quatro bolas já desenhadas por código.
- Reativa 1x/2x/4x e conecta `matchSpeed` ao relógio visual, sem alterar resultado, estatísticas ou eventos simulados.

## Validação adicionada

- Inclui testes estruturais para impedir o retorno de rolagem nas três páginas principais, opções táticas inventadas ou velocidade sem efeito.
- Mantém os testes anteriores de Calendário, diagnóstico, áudio, bola e versionamento.
