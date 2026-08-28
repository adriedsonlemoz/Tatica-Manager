import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text_file_decoder.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/player/player.dart';
import '../../domain/player/player_data_pack.dart';
import '../../game/club/club_identity_engine.dart';
import '../../game/club/club_pack_importer.dart';
import '../../game/player/player_pack_importer.dart';
import 'player_database_editor_screen.dart';

class RosterEditorScreen extends StatefulWidget {
  const RosterEditorScreen({
    super.key,
    required this.title,
    required this.players,
    required this.currentPack,
    required this.allowStructureChanges,
    this.clubId,
    this.freeAgents = false,
  });

  final String title;
  final String? clubId;
  final List<Player> players;
  final ClubIdentityPack currentPack;
  final bool allowStructureChanges;
  final bool freeAgents;

  @override
  State<RosterEditorScreen> createState() => _RosterEditorScreenState();
}

class _RosterEditorScreenState extends State<RosterEditorScreen> {
  late List<Player> _players;
  String? _error;

  static const _fileTypes = XTypeGroup(
    label: 'Banco Tática Manager',
    extensions: ['json', 'tmclubs', 'tmplayers', 'xml'],
    mimeTypes: ['application/json', 'application/xml', 'text/xml', 'application/octet-stream'],
    uniformTypeIdentifiers: ['public.json', 'public.data'],
  );

  @override
  void initState() {
    super.initState();
    _players = [...widget.players];
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._players]
      ..sort((a, b) {
        if (!widget.freeAgents) {
          final number = a.shirtNumber.compareTo(b.shirtNumber);
          if (number != 0) return number;
        }
        return b.overall.compareTo(a.overall);
      });

    return PremiumScaffold(
      appBar: GameTopBar(
        title: widget.freeAgents ? 'Jogadores livres' : 'Jogadores',
        subtitle: '${widget.title} • ${_players.length} atletas',
        actions: [
          IconButton(
            tooltip: 'Aplicar elenco',
            onPressed: () => Navigator.pop(context, List<Player>.unmodifiable(_players)),
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.allowStructureChanges
                      ? 'Neste banco padrão você pode editar, importar, adicionar e remover jogadores.'
                      : 'Nesta carreira os IDs e a quantidade de jogadores são preservados para não quebrar histórico, contratos ou partidas.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importPlayers,
                        icon: const Icon(Icons.file_open_rounded),
                        label: Text(widget.freeAgents ? 'Importar livres' : 'Importar elenco'),
                      ),
                    ),
                    if (widget.allowStructureChanges) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addPlayer,
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text('Adicionar'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            _Message(text: _error!),
          ],
          const SizedBox(height: 14),
          ...sorted.map(
            (player) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SectionCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => _editPlayer(player),
                  contentPadding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.green.withValues(alpha: .30)),
                    ),
                    child: Text(
                      widget.freeAgents ? '${player.overall}' : '${player.shirtNumber}',
                      style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900),
                    ),
                  ),
                  title: Text(player.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(
                    '${player.primaryPosition.label} • OVR ${player.overall} • POT ${player.potential}',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  trailing: widget.allowStructureChanges
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _editPlayer(player);
                            if (value == 'delete') _removePlayer(player);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Editar')),
                            PopupMenuItem(value: 'delete', child: Text('Remover')),
                          ],
                        )
                      : const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPlayer(Player player) async {
    final result = await Navigator.of(context).push<Player>(
      MaterialPageRoute(
        builder: (_) => PlayerDatabaseEditorScreen(
          player: player,
          clubName: widget.title,
          freeAgent: widget.freeAgents,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _players = _players.map((item) => item.id == result.id ? result : item).toList(growable: false);
      _error = null;
    });
  }

  Future<void> _importPlayers() async {
    try {
      final file = await openFile(acceptedTypeGroups: const [_fileTypes]);
      if (file == null) return;
      final length = await file.length();
      if (length > 8 * 1024 * 1024) {
        throw const FormatException('O arquivo é grande demais. Limite: 8 MiB.');
      }
      final bytes = await file.readAsBytes();
      final source = TextFileDecoder.decode(bytes).trim();
      final format = _detectPackFormat(source);
      late List<Player> imported;
      if (format == ClubIdentityPack.format) {
        final decoded = ClubPackImporter.decodeBytes(bytes, fileName: file.name);
        final normalized = ClubIdentityEngine.normalizeAndValidatePack(
          decoded,
          expectedIds: widget.currentPack.clubs.map((club) => club.clubId),
          fallbackPack: widget.currentPack,
        );
        imported = widget.freeAgents
            ? normalized.freeAgents ?? const <Player>[]
            : normalized.clubs
                    .firstWhere((club) => club.clubId == widget.clubId)
                    .players ??
                const <Player>[];
      } else if (format == PlayerDataPack.format) {
        final playerPack = PlayerPackImporter.decodeBytes(
          bytes,
          fileName: file.name,
        );
        imported = _playersFromPlayerPack(playerPack);
      } else {
        throw const FormatException(
          'Formato desconhecido. Use tatica-manager-clubs ou tatica-manager-players.',
        );
      }
      if (!widget.allowStructureChanges) {
        final currentIds = _players.map((player) => player.id).toSet();
        final importedIds = imported.map((player) => player.id).toSet();
        if (currentIds.length != importedIds.length || !currentIds.every(importedIds.contains)) {
          throw const FormatException(
            'Este save só aceita importação que preserve exatamente os IDs atuais dos jogadores.',
          );
        }
      }
      if (!mounted) return;
      setState(() {
        _players = [...imported];
        _error = null;
      });
      _show('Jogadores importados. Revise e volte para salvar o banco.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendly(error));
    }
  }

  String? _detectPackFormat(String source) {
    if (source.startsWith('<')) {
      final head = source.length > 1024 ? source.substring(0, 1024) : source;
      final normalized = head.toLowerCase();
      if (normalized.contains('<tatica-manager-clubs') ||
          normalized.contains('<taticamanagerclubs')) {
        return ClubIdentityPack.format;
      }
      if (normalized.contains('<tatica-manager-players') ||
          normalized.contains('<taticamanagerplayers')) {
        return PlayerDataPack.format;
      }
      return null;
    }
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('O arquivo precisa conter um objeto JSON.');
    }
    final format = decoded['format'];
    return format is String ? format : null;
  }

  List<Player> _playersFromPlayerPack(PlayerDataPack playerPack) {
    final candidate = widget.freeAgents
        ? ClubIdentityPack(
            name: widget.currentPack.name,
            author: widget.currentPack.author,
            clubs: widget.currentPack.clubs,
            freeAgents: playerPack.players,
          )
        : ClubIdentityPack(
            name: widget.currentPack.name,
            author: widget.currentPack.author,
            clubs: widget.currentPack.clubs
                .map((club) => club.clubId == widget.clubId
                    ? club.copyWith(players: playerPack.players)
                    : club)
                .toList(growable: false),
            freeAgents: widget.currentPack.freeAgents,
          );
    final normalized = ClubIdentityEngine.normalizeAndValidatePack(
      candidate,
      expectedIds: widget.currentPack.clubs.map((club) => club.clubId),
      fallbackPack: widget.currentPack,
    );
    return widget.freeAgents
        ? normalized.freeAgents ?? const <Player>[]
        : normalized.clubs
                .firstWhere((club) => club.clubId == widget.clubId)
                .players ??
            const <Player>[];
  }

  void _addPlayer() {
    if (!widget.allowStructureChanges) return;
    final fallback = _players.isNotEmpty
        ? _players.first
        : (ClubIdentityEngine.defaultPack().clubs.first.players ?? const <Player>[]).first;
    final usedNumbers = _players.map((player) => player.shirtNumber).toSet();
    var shirtNumber = 1;
    while (usedNumbers.contains(shirtNumber) && shirtNumber < 99) {
      shirtNumber++;
    }
    final id = 'custom-player-${DateTime.now().microsecondsSinceEpoch}';
    final player = fallback.copyWith(
      id: id,
      firstName: 'Novo',
      lastName: 'Jogador',
      displayName: 'Novo Jogador',
      shirtNumber: widget.freeAgents ? 0 : shirtNumber,
      clubId: widget.clubId,
      clearClubId: widget.freeAgents,
      listed: widget.freeAgents,
      clearInjury: true,
      discipline: const PlayerDiscipline(),
      stats: const PlayerSeasonStats(),
      history: const [],
    );
    setState(() => _players = [..._players, player]);
    _editPlayer(player);
  }

  void _removePlayer(Player player) {
    if (!widget.allowStructureChanges) return;
    if (!widget.freeAgents && _players.length <= 20) {
      setState(() => _error = 'Um clube precisa manter pelo menos 20 jogadores para preservar as regras do mercado e da CPU.');
      return;
    }
    setState(() {
      _players = _players.where((item) => item.id != player.id).toList(growable: false);
      _error = null;
    });
  }

  void _show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  static String _friendly(Object error) =>
      error.toString().replaceFirst('FormatException: ', '').replaceFirst('Bad state: ', '');
}

class _Message extends StatelessWidget {
  const _Message({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withValues(alpha: .35)),
        ),
        child: Text(text),
      );
}
