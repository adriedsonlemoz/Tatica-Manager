import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../live_match_playback.dart';

extension LiveMatchSimulationOptionX on LiveMatchSimulationOption {
  String get label => switch (this) {
        LiveMatchSimulationOption.nextImportant => 'Próximo lance importante',
        LiveMatchSimulationOption.tenMinutes => 'Avançar 10 minutos',
        LiveMatchSimulationOption.halftime => 'Até o intervalo',
        LiveMatchSimulationOption.fulltime => 'Até o fim da partida',
      };

  String get description => switch (this) {
        LiveMatchSimulationOption.nextImportant =>
          'Avança até a próxima chance, defesa, gol, cartão ou ocorrência relevante.',
        LiveMatchSimulationOption.tenMinutes =>
          'Atualiza a transmissão, o placar e os outros jogos em dez minutos.',
        LiveMatchSimulationOption.halftime =>
          'Vai até o próximo intervalo disponível.',
        LiveMatchSimulationOption.fulltime =>
          'Conclui os 90 minutos. Uma confirmação será solicitada.',
      };

  IconData get icon => switch (this) {
        LiveMatchSimulationOption.nextImportant => Icons.bolt_rounded,
        LiveMatchSimulationOption.tenMinutes => Icons.forward_10_rounded,
        LiveMatchSimulationOption.halftime => Icons.pause_circle_outline_rounded,
        LiveMatchSimulationOption.fulltime => Icons.sports_score_rounded,
      };
}

class LiveMatchSimulationSheet extends StatelessWidget {
  const LiveMatchSimulationSheet({super.key, required this.minute});

  final int minute;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.fast_forward_rounded, color: AppColors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'SIMULAR PARTIDA',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    "$minute'",
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'A simulação percorre a timeline já calculada e não altera o equilíbrio do Match Engine.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 10),
              for (final option in LiveMatchSimulationOption.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(option.icon, color: AppColors.green),
                  ),
                  title: Text(
                    option.label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(option.description),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ),
      );
}

Future<LiveMatchSimulationOption?> showLiveMatchSimulationOptions(
  BuildContext context, {
  required int minute,
}) async {
  final option = await showModalBottomSheet<LiveMatchSimulationOption>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    barrierColor: Colors.black.withValues(alpha: .72),
    builder: (context) => LiveMatchSimulationSheet(minute: minute),
  );
  if (!context.mounted || option != LiveMatchSimulationOption.fulltime) {
    return option;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Simular até o fim?'),
      content: const Text(
        'A transmissão avançará até os 90 minutos. O resultado continuará sendo o já calculado pelo Match Engine.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Simular até o fim'),
        ),
      ],
    ),
  );
  return confirmed == true ? option : null;
}
