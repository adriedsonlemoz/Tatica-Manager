# Release 0.1.1.125 — Escalação integrada ao novo design

**Release visível:** `0.1.1.125`  
**Android versionCode:** `126`

## Alterações

- redesenha a aba principal **Escalação** com a mesma linguagem visual e o mesmo campo compacto usados em Táticas;
- remove o antigo título interno de grandes dimensões e usa apenas o cabeçalho padrão da navegação;
- preserva formação, autoescalação, substituição de titulares, abertura de perfis, OVR efetivo e disponibilidade por competição;
- apresenta todos os reservas e indisponíveis em páginas de cinco atletas, sem rolagem vertical na tela principal;
- extrai o campo para `CompactFormationPitch`, compartilhado por Escalação e Táticas sem duplicação visual;
- não altera o Match Engine, resultados, regras de escalação, dados persistidos ou saves.

## Validação

- `python3 tool/versioning.py verify`;
- teste estrutural cobre ausência de rolagem, campo compartilhado, seletor de substituição e banco paginado.
