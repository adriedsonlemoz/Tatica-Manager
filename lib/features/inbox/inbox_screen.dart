import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/season/inbox_message.dart';
import '../../game/season/inbox_engine.dart';
import '../calendar/calendar_screen.dart';
import '../career/manager_job_market_screen.dart';
import '../clubs/club_profile_screen.dart';
import '../finances/finances_screen.dart';
import '../market/incoming_transfer_offer_dialog.dart';
import '../market/market_screen.dart';
import '../medical/medical_department_screen.dart';
import '../player/player_profile_screen.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final all = career.inbox.where((item) => !item.deleted).toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));
    final incoming = all.where((item) => !item.archived).toList(growable: false);
    final unread = incoming.where((item) => !item.read).toList(growable: false);
    final important = incoming.where((item) => item.important).toList(growable: false);
    final archived = all.where((item) => item.archived).toList(growable: false);
    return DefaultTabController(
      length: 4,
      child: PremiumScaffold(
        safeBottom: true,
        appBar: GameTopBar(
          title: 'Caixa de entrada',
          subtitle: '${unread.length} não lida(s) • ${all.length} mensagem(ns)',
        ),
        body: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Entrada'),
                Tab(text: 'Não lidas'),
                Tab(text: 'Importantes'),
                Tab(text: 'Arquivadas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MessageList(messages: incoming),
                  _MessageList(messages: unread),
                  _MessageList(messages: important),
                  _MessageList(messages: archived),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends ConsumerWidget {
  const _MessageList({required this.messages});

  final List<InboxMessage> messages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma mensagem nesta categoria.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return SectionCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          borderColor: !message.read ? AppColors.green.withValues(alpha: .55) : null,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            leading: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_senderIcon(message.senderType), color: AppColors.green),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    message.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: message.read ? FontWeight.w700 : FontWeight.w900,
                    ),
                  ),
                ),
                if (message.important)
                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 17),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  '${message.sender} • ${shortDate(message.date)}',
                  style: const TextStyle(color: AppColors.green, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  message.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            trailing: !message.read
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: () => _openMessage(context, ref, message),
          ),
        );
      },
    );
  }
}

Future<void> _openMessage(
  BuildContext context,
  WidgetRef ref,
  InboxMessage message,
) async {
  var career = ref.read(gameControllerProvider).career!;
  if (!message.read) {
    career = InboxEngine.markRead(career, message.id, true);
    await ref.read(gameControllerProvider.notifier).commitCareer(career);
    message = message.copyWith(read: true);
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(_senderIcon(message.senderType), color: AppColors.green),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.subject,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${message.sender} • ${shortDate(message.date)}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: message.important ? 'Remover destaque' : 'Marcar importante',
                    onPressed: () async {
                      final current = ref.read(gameControllerProvider).career!;
                      await ref.read(gameControllerProvider.notifier).commitCareer(
                            InboxEngine.toggleImportant(current, message.id),
                          );
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                    icon: Icon(
                      message.important ? Icons.star_rounded : Icons.star_border_rounded,
                      color: message.important ? AppColors.warning : AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(message.body, style: const TextStyle(height: 1.45)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (message.actionType != InboxActionType.none)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _performPrimaryAction(context, ref, message);
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(_actionLabel(message.actionType)),
                    ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final current = ref.read(gameControllerProvider).career!;
                      await ref.read(gameControllerProvider.notifier).commitCareer(
                            InboxEngine.archive(current, message.id, !message.archived),
                          );
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                    icon: Icon(message.archived ? Icons.unarchive_rounded : Icons.archive_rounded),
                    label: Text(message.archived ? 'Desarquivar' : 'Arquivar'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final current = ref.read(gameControllerProvider).career!;
                      await ref.read(gameControllerProvider.notifier).commitCareer(
                            InboxEngine.markRead(current, message.id, !message.read),
                          );
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                    icon: Icon(message.read ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded),
                    label: Text(message.read ? 'Não lida' : 'Marcar lida'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final current = ref.read(gameControllerProvider).career!;
                      await ref.read(gameControllerProvider.notifier).commitCareer(
                            InboxEngine.delete(current, message.id),
                          );
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _performPrimaryAction(
  BuildContext context,
  WidgetRef ref,
  InboxMessage message,
) {
  switch (message.actionType) {
    case InboxActionType.transferOffer:
      if (message.eventId != null) {
        showIncomingTransferOfferDialog(
          context,
          ref,
          eventId: message.eventId!,
        );
      }
      return;
    case InboxActionType.transferNegotiation:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MarketScreen(initialTab: 2)),
      );
      return;
    case InboxActionType.player:
    case InboxActionType.contract:
      if (message.playerId != null) {
        final career = ref.read(gameControllerProvider).career;
        final playerIsLocal = career != null &&
            (career.userClub.squad.any((item) => item.id == message.playerId) ||
                career.youthAcademy.any((item) => item.id == message.playerId));
        if (message.clubId == null && !playerIsLocal) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MarketScreen()),
          );
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerProfileScreen(
              playerId: message.playerId!,
              clubId: message.clubId,
            ),
          ),
        );
      }
      return;
    case InboxActionType.club:
      if (message.clubId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClubProfileScreen(clubId: message.clubId!),
          ),
        );
      }
      return;
    case InboxActionType.match:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CalendarScreen(initialFixtureId: message.fixtureId)),
      );
      return;
    case InboxActionType.medical:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MedicalDepartmentScreen()),
      );
      return;
    case InboxActionType.managerOffer:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ManagerJobMarketScreen()),
      );
      return;
    case InboxActionType.sponsorship:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FinancesScreen()),
      );
      return;
    case InboxActionType.none:
      return;
  }
}

IconData _senderIcon(InboxSenderType type) => switch (type) {
      InboxSenderType.board => Icons.business_center_rounded,
      InboxSenderType.agent => Icons.support_agent_rounded,
      InboxSenderType.club => Icons.shield_rounded,
      InboxSenderType.medical => Icons.medical_services_rounded,
      InboxSenderType.staff => Icons.groups_2_rounded,
      InboxSenderType.sponsor => Icons.handshake_rounded,
      InboxSenderType.media => Icons.newspaper_rounded,
      InboxSenderType.system => Icons.notifications_rounded,
    };

String _actionLabel(InboxActionType type) => switch (type) {
      InboxActionType.transferOffer => 'Responder proposta',
      InboxActionType.transferNegotiation => 'Ver negociação',
      InboxActionType.player => 'Ver jogador',
      InboxActionType.club => 'Ver clube',
      InboxActionType.match => 'Ver partida',
      InboxActionType.medical => 'Abrir departamento',
      InboxActionType.contract => 'Ver contrato',
      InboxActionType.managerOffer => 'Ver proposta',
      InboxActionType.sponsorship => 'Abrir Finanças',
      InboxActionType.none => 'Abrir',
    };
