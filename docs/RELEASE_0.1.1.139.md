# Release 0.1.1.139 — Correção do provider de recompensas

## Erro do workflow 92

O workflow concluiu a validação da versão, preparação da plataforma Android, verificação dos ícones e resolução das dependências. O `flutter analyze` encontrou um único erro em `lib/app/state/providers.dart`:

```text
return_of_invalid_type_from_closure
The returned type 'CareerRepository' isn't returnable from a 'RewardRepository' function
```

O erro ocorreu porque o analyzer não promoveu o tipo estático `CareerRepository` para a interface paralela `RewardRepository` no retorno da closure, mesmo após a checagem de tipo em tempo de execução.

## Correção

O provider mantém a checagem `careers is RewardRepository` e retorna o mesmo objeto por meio de conversão explícita para `RewardRepository`. A conversão só é executada dentro do ramo já validado e não altera a instância.

Esse desenho preserva os dois caminhos necessários:

- produção: `SqliteCareerRepository` implementa as duas interfaces e continua garantindo o commit atômico de carreira e PM;
- testes com override: quando o repositório substituído implementa apenas `CareerRepository`, o provider continua criando `MemoryRewardRepository`.

Foi adicionado um teste estrutural para impedir que a checagem, a conversão explícita ou o fallback sejam removidos acidentalmente.

## Escopo preservado

Não houve mudança nos valores de PM, carteira, histórico, notificações, desafios, IDs idempotentes, migração SQLite, Match Engine, partidas, temporadas, objetivos, saves, finanças, estádio, transferências, contratos ou salários.

O workflow 92 parou no analyzer e, por isso, ainda não executou a suíte de testes nem a geração do APK. A próxima execução deve validar essas etapas.
