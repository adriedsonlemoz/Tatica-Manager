# Tática Manager 0.1.1.148

Android versionCode: **149**  
Flutter: **0.1.1+149**

## Correção

Esta release corrige a possibilidade de a narração dos eventos continuar usando a voz antiga do aparelho.

### Mudanças

- remove `flutter_tts` da locução da partida;
- elimina o fallback silencioso para TTS em todos os eventos oficiais;
- mantém 15 arquivos de locução pré-gravada, incluindo cartão amarelo, cartão vermelho/expulsão, gol do mandante e gol do visitante;
- converte todas as locuções para WAV PCM 16-bit, 48 kHz, estéreo;
- mantém os novos efeitos de ambiente/chute/trave/defesa/gol/pênalti defendido;
- não altera o Match Engine.

## Comportamento esperado

Quando **Narração** estiver ligada, os eventos suportados usam exclusivamente a voz oficial gravada. Se um asset falhar, nenhuma voz sintética do Android é executada.
