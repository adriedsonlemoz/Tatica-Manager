import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';
import '../../game/youth/youth_academy_engine.dart';
import '../player/player_profile_screen.dart';

class YouthAcademyScreen extends ConsumerWidget {
  const YouthAcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final players = [...career.youthAcademy]
      ..sort((a, b) {
        final potential = b.potential.compareTo(a.potential);
        return potential != 0 ? potential : b.overall.compareTo(a.overall);
      });
    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: 'Categoria de base',
        subtitle: '${career.userClub.name} • ${players.length} jovem(ns)',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.green),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESENVOLVIMENTO DE TALENTOS',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'O potencial é uma estimativa e fica menos preciso quanto mais jovem for o atleta.',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (players.isEmpty)
            const SectionCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Nenhum jovem disponível na base.')),
              ),
            )
          else
            ...players.map(
              (player) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _YouthCard(player: player),
              ),
            ),
          const SizedBox(height: 4),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTRUTURA PREPARADA',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  'A base já está separada do elenco profissional e preserva IDs próprios. Isso deixa o sistema pronto para captação por região, olheiros, investimento em instalações e histórico de atletas formados sem misturar regras do elenco principal.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YouthCard extends ConsumerWidget {
  const _YouthCard({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final low = YouthAcademyEngine.estimatedPotentialLow(player);
    final high = YouthAcademyEngine.estimatedPotentialHigh(player);
    final evolution = player.history.isEmpty
        ? null
        : player.overall - player.history.last.overall;
    final report = _report(player, low, high);
    return SectionCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerProfileScreen(
              playerId: player.id,
              clubId: career.userClubId,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PlayerAvatar(
                    player: player,
                    size: 50,
                    accentColor: Color(career.userClub.colors.primaryHex),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${player.age} anos • ${player.primaryPosition.label} • ${player.nationality}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  OverallShield(value: player.overall, compact: true),
                ],
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _YouthMetric(label: 'Potencial est.', value: '$low–$high'),
                  _YouthMetric(label: 'Condição', value: '${player.condition}%'),
                  _YouthMetric(label: 'Fadiga', value: '${player.fatigue}%'),
                  _YouthMetric(
                    label: 'Evolução',
                    value: evolution == null
                        ? 'Base'
                        : '${evolution >= 0 ? '+' : ''}$evolution OVR',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            playerId: player.id,
                            clubId: career.userClubId,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.person_search_rounded),
                      label: const Text('Relatório'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final result = YouthAcademyEngine.promote(career, player.id);
                        await ref
                            .read(gameControllerProvider.notifier)
                            .commitCareer(result.state, message: result.message);
                      },
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: const Text('Promover'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _report(Player player, int low, int high) {
    final gap = high - player.overall;
    if (gap >= 20) {
      return 'Olheiro: teto técnico muito interessante ($low–$high). Vale acompanhar a evolução antes de acelerar a promoção.';
    }
    if (gap >= 12) {
      return 'Olheiro: bom espaço para evolução ($low–$high), com perfil compatível com desenvolvimento gradual.';
    }
    return 'Olheiro: potencial mais próximo do nível atual ($low–$high). Pode ser útil para compor o elenco se houver necessidade.';
  }
}

class _YouthMetric extends StatelessWidget {
  const _YouthMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );
}
