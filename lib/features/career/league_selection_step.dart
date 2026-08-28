import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../domain/season/league_loading.dart';
import '../../game/career/career_league_planner.dart';

class LeagueSelectionStep extends StatelessWidget {
  const LeagueSelectionStep({
    super.key,
    required this.userClubId,
    required this.setup,
    required this.onChanged,
  });

  final String userClubId;
  final CareerLeagueSetup setup;
  final ValueChanged<CareerLeagueSetup> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalized = CareerLeaguePlanner.normalize(
      setup: setup,
      userClubId: userClubId,
    );
    final userSeries = CompetitionCatalog.primarySeriesForClub(userClubId);
    final estimate = CareerLeaguePlanner.performanceEstimate(normalized);
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        Text(
          'Ligas desta carreira',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          'Escolha quanto do mundo será acompanhado neste save. A liga do seu clube permanece sempre completa.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 14),
        ...CareerWorldPreset.values.map(
          (preset) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PresetTile(
              preset: preset,
              selected: normalized.preset == preset,
              onTap: () {
                if (preset == CareerWorldPreset.custom) {
                  onChanged(
                    CareerLeaguePlanner.asCustom(
                      setup: normalized,
                      userClubId: userClubId,
                    ),
                  );
                  return;
                }
                onChanged(
                  CareerLeaguePlanner.forPreset(
                    userClubId: userClubId,
                    preset: preset,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        SectionCard(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desempenho estimado',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estimate.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${normalized.fullCompetitionIds.length} completa${normalized.fullCompetitionIds.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const SectionCard(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LevelHelp(
                title: 'Completa',
                text: 'Calendário, classificação, elenco, mercado e CPU normais.',
              ),
              SizedBox(height: 7),
              _LevelHelp(
                title: '2º plano',
                text: 'Continua no mundo e no mercado, com simulação mais leve.',
              ),
              SizedBox(height: 7),
              _LevelHelp(
                title: 'Fora',
                text: 'Permanece no banco do jogo, sem processamento neste save.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Competições disponíveis',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        for (final country in CompetitionCatalog.countries)
          SectionCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.public_rounded,
                      size: 18,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      country.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                for (final championship in country.championships)
                  for (final series in championship.series)
                    _LeagueTile(
                      name: CompetitionCatalog.displayNameFor(series),
                      level: normalized.levelFor(series.id),
                      locked: series.id == userSeries.id,
                      editable: normalized.preset == CareerWorldPreset.custom,
                      onLevel: (level) => onChanged(
                        CareerLeaguePlanner.normalize(
                          setup: normalized.withLevel(
                            series.id,
                            level,
                            preset: CareerWorldPreset.custom,
                          ),
                          userClubId: userClubId,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        if (CompetitionCatalog.allSeries.length == 1)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'O banco atual possui somente esta liga. Quando novas competições reais forem adicionadas ao catálogo do jogo, elas aparecerão automaticamente nesta etapa.',
              style: TextStyle(color: AppColors.muted, height: 1.4, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _LevelHelp extends StatelessWidget {
  const _LevelHelp({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(text: text),
          ],
        ),
      );
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final CareerWorldPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SectionCard(
          borderColor: selected ? AppColors.green : null,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 20,
                color: selected ? AppColors.green : AppColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.label,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.description,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _LeagueTile extends StatelessWidget {
  const _LeagueTile({
    required this.name,
    required this.level,
    required this.locked,
    required this.editable,
    required this.onLevel,
  });

  final String name;
  final LeagueLoadLevel level;
  final bool locked;
  final bool editable;
  final ValueChanged<LeagueLoadLevel> onLevel;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (locked)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: AppColors.green),
                      SizedBox(width: 4),
                      Text(
                        'Liga do clube',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: LeagueLoadLevel.values.map((value) {
                final selected = level == value;
                final enabled = editable && !locked;
                return ChoiceChip(
                  label: Text(value.label),
                  selected: selected,
                  onSelected: enabled ? (_) => onLevel(value) : null,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(growable: false),
            ),
          ],
        ),
      );
}

extension on CareerWorldPreset {
  String get label => switch (this) {
        CareerWorldPreset.fast => 'Rápido',
        CareerWorldPreset.balanced => 'Equilibrado',
        CareerWorldPreset.broad => 'Mundo amplo',
        CareerWorldPreset.custom => 'Personalizado',
      };

  String get description => switch (this) {
        CareerWorldPreset.fast =>
          'Mantém somente o essencial completo para priorizar velocidade.',
        CareerWorldPreset.balanced =>
          'Equilibra ligas completas e competições em segundo plano.',
        CareerWorldPreset.broad =>
          'Carrega todas as competições disponíveis com maior profundidade.',
        CareerWorldPreset.custom =>
          'Permite escolher manualmente o nível de cada liga e divisão.',
      };
}

extension on LeagueLoadLevel {
  String get label => switch (this) {
        LeagueLoadLevel.full => 'Completa',
        LeagueLoadLevel.background => '2º plano',
        LeagueLoadLevel.unloaded => 'Fora',
      };
}

extension on CareerPerformanceEstimate {
  String get label => switch (this) {
        CareerPerformanceEstimate.fast => 'Rápido',
        CareerPerformanceEstimate.normal => 'Normal',
        CareerPerformanceEstimate.heavy => 'Pesado',
      };
}
