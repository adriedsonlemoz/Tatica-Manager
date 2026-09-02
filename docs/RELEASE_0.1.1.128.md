# Release 0.1.1.128 — Notícias ampliadas e perfis de técnicos

**Release visível:** `0.1.1.128`  
**Android versionCode:** `129`

## Notícias

- adiciona prévia dois dias antes da próxima partida, com adversário, competição e posições reais quando a tabela estiver disponível;
- adiciona panorama semanal baseado em posição, pontos, jogos e saldo reais;
- cria reportagem após cada partida do usuário e destaque individual somente quando o atleta participou diretamente de ao menos dois gols;
- mantém as notícias conectadas à carreira, calendário, tabela e Match Engine, sem placares ou acontecimentos fictícios.

## Técnicos

- substitui os 20 perfis genéricos `Técnico CPU` por técnicos fictícios, realistas e determinísticos, um para cada clube;
- cada perfil traz nome, local de nascimento, idade, contrato, experiência, estilo, formação e mentalidade;
- repara automaticamente o banco padrão antigo que ainda tenha somente os 20 técnicos genéricos;
- melhora a escolha e a tela de perfil com nome completo, origem, contrato, tempo no cargo e situação real na tabela.

## Jogadores

- a geração atual já usa nomes brasileiros fictícios, posições, idade, atributos, potencial, contrato, valor e visual com seed estável;
- esta release aplica a mesma lógica de identidade consistente aos técnicos, sem alterar a geração, atributos ou regras dos jogadores.
