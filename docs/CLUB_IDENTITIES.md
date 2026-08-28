# Banco editável, clubes, uniformes e jogadores

## Objetivo

A partir da `0.1.1.14`, o Tática Manager separa os **IDs internos permanentes** da apresentação editável do banco. Os clubes base usam `br-club-001` até `br-club-020`; esses IDs não devem ser renomeados pelo editor ou por pacotes comunitários.

O editor pode alterar os dados-base usados para novas carreiras: nome/apelido/sigla do clube, estádio, três uniformes, ícone/escudo, elenco e jogadores livres. Cada jogador também mantém um `Player.id` permanente.

## Editor do banco

Na Central de Carreiras, **Editor do banco** modifica o pacote padrão das próximas carreiras. Em uma carreira existente, **Editar banco da carreira** permite alterar os dados visíveis/base, mas preserva a quantidade e os IDs dos jogadores daquele save para não quebrar histórico, contratos, partidas ou referências persistidas.

Por clube, o editor oferece:

- nome completo, apelido e sigla;
- estádio, capacidade e preço do ingresso;
- uniforme 1, 2 e 3;
- ícone/escudo local em PNG, JPG ou WebP, armazenado em Base64;
- elenco entre 20 e 30 jogadores.

O banco também possui um menu separado de **Jogadores livres**.

## Uniformes

Cada uniforme usa `ClubKit` e não depende de uma imagem pronta. Os campos são `primaryHex`, `secondaryHex`, `accentHex`, `shortsHex`, `socksHex` e `pattern`.

Padrões aceitos: `solid`, `verticalStripes`, `horizontalStripes`, `sash`, `halves` e `gradient`.

Essa estrutura mantém a identidade visual desacoplada do Match Engine. O motor da partida continua responsável pela lógica; Flame apenas representa os dados visuais. O uniforme 1 também alimenta as cores principais já consumidas pela representação atual, enquanto os três kits ficam persistidos para evolução visual futura.

## Jogadores

O editor de jogador permite alterar:

- nome, sobrenome e nome exibido;
- nascimento, idade e nacionalidade;
- número da camisa;
- posição principal e posições secundárias;
- pé preferido;
- altura e peso;
- overall e potencial;
- valor de mercado;
- salário e temporada final do contrato;
- atributos técnicos, físicos, mentais e de goleiro;
- perfil visual 2D.

Existe uma ação para recalcular o overall usando o `OverallCalculator` existente.

Os índices do perfil visual seguem os mesmos limites do gerador atual: `skinTone 0..5`, `hairStyle 0..7`, `hairColor 0..4`, `bodyType 0..3`, `bootStyle 0..5` e `visualHeight 0.5..1.5`.

A partir da `0.1.1.28`, os rostos 2D não adicionam novos campos persistidos. `skinTone`, `hairStyle` e `hairColor` continuam editáveis por esse perfil, enquanto formato do rosto, olhos, sobrancelhas, nariz, boca, barba, bigode e pequenos detalhes são derivados de forma determinística do `Player.id`. Assim, o mesmo atleta mantém a identidade entre telas e save/load sem aumentar o schema.

Lesão, cartões, condição, fadiga, moral, estatísticas e histórico são estado de carreira. Em um save existente, uma importação/edição de dados-base não apaga esses estados transitórios.

## Formato comunitário v3

O importador aceita `.json`, `.tmclubs`, `.tmpack` ou `.xml` no formato `tatica-manager-clubs`, atualmente na versão `3`. Pacotes das versões 1 e 2 continuam aceitos; a versão 3 acrescenta técnicos no mesmo pacote, sem trocar os IDs permanentes. A extensão `.tmpack` é uma forma amigável de selecionar o mesmo JSON validado pela Central de Edição.

Estrutura resumida:

```json
{
  "format": "tatica-manager-clubs",
  "version": 3,
  "name": "Minha liga",
  "author": "Comunidade",
  "clubs": [
    {
      "id": "br-club-001",
      "name": "Capital Paulista FC",
      "nickname": "Capital",
      "shortName": "CPT",
      "stadium": {
        "name": "Estádio da Capital",
        "capacity": 42000,
        "ticketPrice": 50
      },
      "homeKit": {
        "primaryHex": 4289724443,
        "secondaryHex": 4294967295,
        "accentHex": 4294967295,
        "shortsHex": 4289724443,
        "socksHex": 4294967295,
        "pattern": "solid"
      },
      "iconBase64": "...",
      "players": [
        {
          "id": "player-id-permanente",
          "firstName": "Rafael",
          "lastName": "Silva",
          "displayName": "Rafael Silva",
          "birthDate": "2001-05-12T00:00:00.000",
          "age": 25,
          "nationality": "Brasil",
          "primaryPosition": "MC",
          "secondaryPositions": ["MEI"],
          "preferredFoot": "right",
          "heightCm": 178,
          "weightKg": 74,
          "shirtNumber": 8,
          "overall": 76,
          "potential": 81,
          "technical": {"finishing": 65, "passing": 80, "crossing": 72, "control": 79, "dribbling": 74, "tackling": 67},
          "physical": {"speed": 72, "acceleration": 73, "strength": 68, "stamina": 82, "agility": 75},
          "mental": {"positioning": 76, "vision": 80, "decision": 77, "concentration": 74, "leadership": 71},
          "goalkeeper": {"reflexes": 20, "positioning": 20, "saving": 20, "rushingOut": 20, "aerial": 20},
          "marketValue": 9000000,
          "contract": {"salary": 180000, "endSeason": 2028},
          "visual": {"skinTone": 2, "hairStyle": 1, "hairColor": 0, "bodyType": 1, "visualHeight": 1.0, "bootStyle": 2}
        }
      ]
    }
  ],
  "freeAgents": []
}
```

Os campos de estado (`morale`, `condition`, `fatigue`, `injury`, `discipline`, `stats`, `history`, `listed`) podem aparecer no JSON serializado, mas em uma carreira existente os dados transitórios atuais do save têm precedência.

## Validação e segurança lógica

Um pacote precisa conter exatamente os 20 IDs permanentes de clube, uma vez cada. O importador rejeita IDs de clube desconhecidos/duplicados, IDs de jogador duplicados, campos fora dos limites, nomes/siglas duplicados, elencos menores que 20 ou maiores que 30 e bancos com mais de 150 jogadores livres.

Ícones aceitos são PNG, JPG/JPEG ou WebP, com até **256 KiB por clube**, dimensões entre **32 × 32 e 1024 × 1024 px** e proporção máxima **2:1** em qualquer orientação. A assinatura/dimensões são verificadas tanto ao escolher a imagem no editor quanto na normalização do engine. Se um bitmap não puder ser renderizado, `ClubBadge` mantém a sigla como fallback. O arquivo comunitário tem limite de 8 MiB no seletor e não contém código executável. Uma string vazia de `iconBase64` representa remoção explícita do escudo e é preservada no JSON de importação/exportação.

Para **novas carreiras**, o banco padrão pode adicionar/remover jogadores e definir a estrutura completa dos elencos. Para **carreiras existentes**, o conjunto global de `Player.id` precisa permanecer exatamente o mesmo; os jogadores podem ser editados e reorganizados sem invalidar referências históricas.

## Arquivos de exemplo

- `docs/EXEMPLO_PACOTE_CLUBES.json`: pacote mínimo fictício compatível com o importador atual e versões anteriores.
- `docs/BANCO_TESTE_NOMES_REAIS.json`: pacote local de desenvolvimento com nomes de clubes/estádios reais para testes. Ele não é parte do banco distribuído pelo jogo e não inventa elencos reais; jogadores omitidos são mantidos pelo fallback do editor.

### Pacote separado de jogadores

O menu de elenco também aceita `.json`, `.tmplayers` ou `.xml` no formato `tatica-manager-players` versão `1`, útil para comunidades compartilharem somente um elenco ou uma lista de livres. O arquivo é validado dentro do banco atual antes de ser aplicado:

```json
{
  "format": "tatica-manager-players",
  "version": 1,
  "name": "Elenco comunitário",
  "author": "Comunidade",
  "players": [
    { "id": "player-id-permanente", "...": "demais campos de Player" }
  ]
}
```

Para um clube, a lista precisa resultar em 20 a 30 atletas. Em uma carreira existente, os IDs precisam continuar exatamente iguais aos atuais daquele elenco/lista; no banco padrão é permitido montar uma estrutura nova antes de criar a carreira.

## Seleção na nova carreira — 0.1.1.15

O mesmo `iconBase64` validado pelo editor é consumido por `ClubBadge` na seleção da nova carreira. Os cards são organizados em duas colunas e mostram nome, overall/estrelas e orçamento. A identidade é aplicada por `ClubIdentityEngine.applyIdentityToClub`, evitando uma segunda regra para estádio, cores, escudo ou uniformes.


## Melhorias do editor — 0.1.1.17

A navegação do editor usa o mesmo catálogo da criação de carreira: **País > Campeonato > Série > Clubes**. O catálogo fica em `lib/data/competition_catalog.dart`; a UI apenas navega pelos níveis e não duplica IDs de competição/clube.

As cores dos três uniformes podem ser escolhidas visualmente por canais RGB ou digitadas manualmente. O campo manual recebe `RRGGBB`, remove `#` quando informado, ignora caracteres inválidos e normaliza em maiúsculas antes de persistir o valor ARGB já usado por `ClubKit`.

O editor de jogador usa calendário para nascimento e formatação monetária brasileira para salário (`R$ 1.234.567`) durante a digitação. A persistência continua usando `DateTime`/inteiro; a formatação pertence somente à camada de entrada.

A seleção de escudo é iniciada por um `AlertDialog` central. Depois de escolher **Escolher imagem**, o seletor nativo de arquivos do sistema operacional é aberto; sua posição/aparência final é controlada pelo Android/iOS, não pelo Flutter.

### XML e codificação

Além de JSON/`.tmclubs`/`.tmplayers`, a importação aceita `.xml` com raízes:

- `<tatica-manager-clubs version="3">` para banco completo atual (versões 1/2 continuam aceitas);
- `<tatica-manager-players version="1">` para pacote separado de atletas.

O conteúdo XML espelha a estrutura dos objetos JSON. O decoder reconhece BOM UTF-8/UTF-16, declaração `encoding`, UTF-8 estrito e fallback para Windows-1252/Latin-1. Isso preserva acentos e símbolos como `‰`, `~`, aspas tipográficas e travessões. Caracteres reservados do próprio XML, como `&`, continuam precisando ser escapados de acordo com o padrão XML.


## Renderização de escudo personalizado — 0.1.1.46

Quando `iconBase64` existe e passa pela validação, `ClubBadge` e o preview do editor usam `Image.memory` com `BoxFit.contain`, padding interno e fundo neutro. A cor primária do clube deixa de ser desenhada atrás do bitmap importado; áreas transparentes permanecem visualmente neutras e a proporção original é preservada sem esticar o escudo. O fallback por sigla/cores continua válido quando não há imagem renderizável.


## Técnicos no pacote v3 — 0.1.1.56

O formato continua sendo `tatica-manager-clubs`; a versão 3 apenas acrescenta a coleção opcional `managers` (também aceita `coaches` na leitura por compatibilidade de importação). Não existe um segundo formato exclusivo para técnicos. O mesmo pacote pode transportar clubes, elencos, jogadores livres e técnicos.

Cada técnico usa `ManagerProfile` e deve manter `id` estável. `currentClubId` referencia um `Club.id` existente ou fica ausente para técnico livre. A validação rejeita IDs duplicados, clubes desconhecidos e mais de um técnico associado ao mesmo clube. Nome, foto e atributos profissionais podem mudar sem alterar o ID. Arquivos exportados pela Central de Edição podem ser reimportados pelo próprio aplicativo.

## Pack separado de escudos — 0.1.1.62

A Central de Edição aceita também um arquivo dedicado apenas a escudos, sem importar ou sobrescrever nomes, elencos, técnicos, estádio, uniformes ou outros dados do clube.

O formato é `tatica-manager-logos` versão `1`, aceito em `.tmlogos` ou `.json`. A associação é feita **exclusivamente pelo ID permanente do clube**, nunca pelo nome exibido. Isso permite trocar o nome de um clube ou importar um banco comunitário sem perder o vínculo do escudo.

O pack pode ser parcial: de 1 até a quantidade de clubes do banco atual (20 na base distribuída hoje). Clubes que não aparecem no arquivo permanecem exatamente como estavam. IDs desconhecidos ou repetidos fazem a importação ser rejeitada antes de qualquer alteração.

Estrutura:

```json
{
  "format": "tatica-manager-logos",
  "version": 1,
  "name": "Escudos Brasil 2026",
  "author": "Comunidade",
  "logos": [
    {
      "clubId": "br-club-001",
      "label": "Nome apenas para conferência humana",
      "iconBase64": "..."
    }
  ]
}
```

`label` é opcional e serve somente para ajudar a pessoa a conferir o conteúdo do pack. O jogo **não usa esse nome para localizar o clube**. A chave real continua sendo `clubId`.

Cada imagem reutiliza a mesma validação do editor individual: PNG, JPG/JPEG ou WebP, até 256 KiB, de 32 × 32 a 1024 × 1024 px e proporção máxima 2:1. O arquivo completo possui limite de 8 MiB.

Ao importar, a Central de Edição apresenta uma prévia `escudo atual → escudo novo`, junto do nome atual do clube e de seu ID. Somente depois da confirmação os escudos entram no banco em edição; a persistência definitiva continua ocorrendo pelo botão **Salvar alterações**. Isso funciona tanto no banco padrão quanto no banco de uma carreira existente, sem alterar o schema do save, porque `iconBase64` já fazia parte de `ClubIdentity`/`Club`.

Um exemplo importável com dois escudos está em `docs/EXEMPLO_PACK_ESCUDOS.json`.


## Pacote completo e técnicos — 0.1.1.63

A Central de Edição apresenta o formato `tatica-manager-clubs` v3 como **pacote completo**. O mesmo conteúdo pode ser selecionado com extensão `.tmclubs`, `.json` ou `.tmpack`; `.tmpack` é apenas uma extensão amigável para o JSON validado existente, não cria um schema paralelo.

Antes de carregar, a interface resume quantos **clubes, jogadores, técnicos e escudos** serão importados. Técnicos continuam em `managers` (ou `coaches` na leitura) e cada escudo continua no `iconBase64` do clube. Todas as associações importantes usam IDs permanentes. Em carreiras existentes, a proteção dos `Player.id` continua ativa.

Para quem deseja alterar somente imagens, `tatica-manager-logos` v1 permanece disponível em **Importar somente escudos**. Assim um pack completo pode atualizar nomes/elencos/técnicos/escudos de uma vez, enquanto um pack visual não toca nos demais dados.
