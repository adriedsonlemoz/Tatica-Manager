import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/club/club.dart';
import '../../game/match/renderer/match_kit_resolver.dart';
import 'widgets/match_kit_preview.dart';

class PreMatchKitSelector extends StatelessWidget {
  const PreMatchKitSelector({
    super.key,
    required this.home,
    required this.away,
    required this.userClubId,
    required this.selectedSlot,
    required this.selection,
    required this.onChanged,
  });

  final Club home;
  final Club away;
  final String userClubId;
  final MatchKitSlot selectedSlot;
  final MatchVisualKitSelection selection;
  final ValueChanged<MatchKitSlot> onChanged;

  @override
  Widget build(BuildContext context) {
    final userClub = home.id == userClubId ? home : away;
    final opponent = home.id == userClubId ? away : home;
    final opponentSlot = selection.slotForClub(opponent.id, home.id);
    final opponentKit = selection.kitForClub(opponent.id, home.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF13232B), Color(0xFF101B22), Color(0xFF0F181E)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: .82)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _KitHeadingIcon(),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIFORME DA PARTIDA',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .25,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Escolha o seu. O rival será ajustado automaticamente.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var index = 0;
                  index < MatchKitSlot.values.length;
                  index++) ...[
                Expanded(
                  child: _KitChoice(
                    slot: MatchKitSlot.values[index],
                    kit: MatchKitSlot.values[index].kitOf(userClub),
                    selected: MatchKitSlot.values[index] == selectedSlot,
                    onTap: () => onChanged(MatchKitSlot.values[index]),
                  ),
                ),
                if (index != MatchKitSlot.values.length - 1)
                  const SizedBox(width: 7),
              ],
            ],
          ),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF091116).withValues(alpha: .72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.green.withValues(alpha: .20),
              ),
            ),
            child: Row(
              children: [
                _MiniKit(kit: selectedSlot.kitOf(userClub)),
                const SizedBox(width: 7),
                const Icon(
                  Icons.compare_arrows_rounded,
                  size: 17,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 7),
                _MiniKit(kit: opponentKit),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userClub.shortName} ${selectedSlot.shortLabel} • '
                        '${opponent.shortName} ${opponentSlot.shortLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selection.safetyFallbackUsed
                            ? 'Ajuste visual de segurança aplicado ao rival'
                            : 'Combinação automática sem conflito de cores',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selection.safetyFallbackUsed
                              ? AppColors.warning
                              : AppColors.green,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KitChoice extends StatelessWidget {
  const _KitChoice({
    required this.slot,
    required this.kit,
    required this.selected,
    required this.onTap,
  });

  final MatchKitSlot slot;
  final ClubKit kit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.green.withValues(alpha: .10)
                  : const Color(0xFF0B151B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected
                    ? AppColors.green.withValues(alpha: .70)
                    : AppColors.border.withValues(alpha: .72),
                width: selected ? 1.3 : 1,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 49,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MatchKitPreview(kit: kit, size: 45),
                      if (selected)
                        const Positioned(
                          right: 2,
                          top: 0,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.green,
                            size: 15,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slot.label,
                  maxLines: 1,
                  style: TextStyle(
                    color: selected ? AppColors.white : AppColors.textSecondary,
                    fontSize: 8.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  slot.roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 7.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _KitHeadingIcon extends StatelessWidget {
  const _KitHeadingIcon();

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green.withValues(alpha: .10),
          border: Border.all(color: AppColors.green.withValues(alpha: .28)),
        ),
        child: const Icon(
          Icons.checkroom_rounded,
          color: AppColors.green,
          size: 20,
        ),
      );
}

class _MiniKit extends StatelessWidget {
  const _MiniKit({required this.kit});

  final ClubKit kit;

  @override
  Widget build(BuildContext context) => Container(
        width: 31,
        height: 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF152229),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.border),
        ),
        child: MatchKitPreview(kit: kit, size: 25),
      );
}
