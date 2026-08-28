import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../data/country_catalog.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club_identity.dart';

class ManagerChoiceStep extends StatelessWidget {
  const ManagerChoiceStep({
    super.key,
    required this.onExisting,
    required this.onCreate,
  });

  final VoidCallback onExisting;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            'Escolha seu técnico',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Você pode assumir a carreira com um técnico existente ou criar seu próprio treinador.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          _ChoiceCard(
            icon: Icons.badge_rounded,
            title: 'Usar técnico existente',
            subtitle: 'Escolha um treinador do banco do jogo ou de uma base importada.',
            onTap: onExisting,
          ),
          const SizedBox(height: 12),
          _ChoiceCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Criar meu técnico',
            subtitle: 'Defina nome, idade, país, aparência e comece com um perfil próprio.',
            onTap: onCreate,
          ),
        ],
      );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SectionCard(
          borderColor: AppColors.green.withValues(alpha: .32),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.green, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.muted, height: 1.35)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      );
}

class ExistingManagerSelectionStep extends StatefulWidget {
  const ExistingManagerSelectionStep({
    super.key,
    required this.pack,
    required this.selected,
    required this.onSelected,
  });

  final ClubIdentityPack pack;
  final ManagerProfile? selected;
  final ValueChanged<ManagerProfile> onSelected;

  @override
  State<ExistingManagerSelectionStep> createState() =>
      _ExistingManagerSelectionStepState();
}

class _ExistingManagerSelectionStepState
    extends State<ExistingManagerSelectionStep> {
  final _search = TextEditingController();
  String _status = 'Todos';
  String _nationality = 'Todas';
  String _club = 'Todos';
  int _minimumReputation = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubs = {for (final club in widget.pack.clubs) club.clubId: club.name};
    final managers = [...?widget.pack.managers]
      ..sort((a, b) => b.reputation.compareTo(a.reputation));
    final nationalities = managers.map((m) => m.nationality).toSet().toList()
      ..sort();
    final query = _search.text.trim().toLowerCase();
    final filtered = managers.where((manager) {
      if (query.isNotEmpty &&
          !manager.displayName.toLowerCase().contains(query) &&
          !manager.nickname.toLowerCase().contains(query)) {
        return false;
      }
      if (_status == 'Livres' && manager.currentClubId != null) return false;
      if (_status == 'Em clube' && manager.currentClubId == null) return false;
      if (_nationality != 'Todas' && manager.nationality != _nationality) {
        return false;
      }
      if (_club != 'Todos' && manager.currentClubId != _club) return false;
      if (manager.reputation < _minimumReputation) return false;
      return true;
    }).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Text('Selecionar técnico',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        TextField(
          controller: _search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Pesquisar técnico',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['Todos', 'Em clube', 'Livres']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(growable: false),
                onChanged: (value) => setState(() => _status = value ?? 'Todos'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _nationality,
                decoration: const InputDecoration(labelText: 'Nacionalidade'),
                items: ['Todas', ...nationalities]
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(growable: false),
                onChanged: (value) =>
                    setState(() => _nationality = value ?? 'Todas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _club,
                decoration: const InputDecoration(labelText: 'Clube'),
                items: [
                  const DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                  ...widget.pack.clubs.map(
                    (club) => DropdownMenuItem(
                      value: club.clubId,
                      child: Text(club.shortName),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _club = value ?? 'Todos'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _minimumReputation,
                decoration: const InputDecoration(labelText: 'Reputação'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Todas')),
                  DropdownMenuItem(value: 60, child: Text('60+')),
                  DropdownMenuItem(value: 70, child: Text('70+')),
                  DropdownMenuItem(value: 80, child: Text('80+')),
                ],
                onChanged: (value) =>
                    setState(() => _minimumReputation = value ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const EmptyState(
            icon: Icons.sports_rounded,
            title: 'Nenhum técnico encontrado',
            text: 'Ajuste os filtros ou importe uma base com técnicos na Central de Edição.',
          )
        else
          ...filtered.map((manager) {
            final selected = widget.selected?.id.isNotEmpty == true
                ? widget.selected!.id == manager.id
                : identical(widget.selected, manager);
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => widget.onSelected(manager),
                child: SectionCard(
                  borderColor: selected ? AppColors.green : null,
                  child: Row(
                    children: [
                      ManagerAvatar(manager: manager, size: 64),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(manager.preferredName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 3),
                            Text(
                              '${CountryCatalog.flagOf(manager.nationality)} ${manager.nationality} • ${manager.ageAtStart} anos',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${clubs[manager.currentClubId] ?? 'Livre'} • ${manager.style} • Rep. ${manager.reputation}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.green),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
