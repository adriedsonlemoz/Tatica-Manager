import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/color_hex.dart';
import 'color_picker_field.dart';
import '../../domain/club/club.dart';

class KitSetEditorScreen extends StatefulWidget {
  const KitSetEditorScreen({
    super.key,
    required this.homeKit,
    required this.awayKit,
    required this.thirdKit,
    required this.clubName,
  });

  final ClubKit homeKit;
  final ClubKit awayKit;
  final ClubKit thirdKit;
  final String clubName;

  @override
  State<KitSetEditorScreen> createState() => _KitSetEditorScreenState();
}

class KitSetResult {
  const KitSetResult({required this.home, required this.away, required this.third});
  final ClubKit home;
  final ClubKit away;
  final ClubKit third;
}

class _KitSetEditorScreenState extends State<KitSetEditorScreen> {
  late ClubKit _home;
  late ClubKit _away;
  late ClubKit _third;

  @override
  void initState() {
    super.initState();
    _home = widget.homeKit;
    _away = widget.awayKit;
    _third = widget.thirdKit;
  }

  @override
  Widget build(BuildContext context) => PremiumScaffold(
        appBar: GameTopBar(
          title: 'Uniformes',
          subtitle: widget.clubName,
          actions: [
            IconButton(
              tooltip: 'Salvar uniformes',
              onPressed: () => Navigator.pop(
                context,
                KitSetResult(home: _home, away: _away, third: _third),
              ),
              icon: const Icon(Icons.check_rounded),
            ),
          ],
        ),
        safeBottom: true,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          children: [
            _KitCard(
              title: 'Uniforme 1',
              subtitle: 'Principal',
              kit: _home,
              onChanged: (value) => setState(() => _home = value),
            ),
            const SizedBox(height: 12),
            _KitCard(
              title: 'Uniforme 2',
              subtitle: 'Visitante',
              kit: _away,
              onChanged: (value) => setState(() => _away = value),
            ),
            const SizedBox(height: 12),
            _KitCard(
              title: 'Uniforme 3',
              subtitle: 'Alternativo',
              kit: _third,
              onChanged: (value) => setState(() => _third = value),
            ),
          ],
        ),
      );
}

class _KitCard extends StatelessWidget {
  const _KitCard({
    required this.title,
    required this.subtitle,
    required this.kit,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final ClubKit kit;
  final ValueChanged<ClubKit> onChanged;

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _KitPreview(kit: kit),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                      const SizedBox(height: 3),
                      Text('$subtitle • ${kit.pattern.label}', style: TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final result = await showDialog<ClubKit>(
                      context: context,
                      builder: (context) => _KitDialog(kit: kit, title: title),
                    );
                    if (result != null) onChanged(result);
                  },
                  icon: const Icon(Icons.edit_rounded),
                ),
              ],
            ),
          ],
        ),
      );
}

class _KitPreview extends StatelessWidget {
  const _KitPreview({required this.kit});
  final ClubKit kit;

  @override
  Widget build(BuildContext context) {
    final primary = Color(kit.primaryHex);
    final secondary = Color(kit.secondaryHex);
    return Container(
      width: 68,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.checkroom_rounded, color: primary, size: 54),
          Positioned(
            top: 31,
            child: Container(
              width: 28,
              height: 5,
              decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitDialog extends StatefulWidget {
  const _KitDialog({required this.kit, required this.title});
  final ClubKit kit;
  final String title;

  @override
  State<_KitDialog> createState() => _KitDialogState();
}

class _KitDialogState extends State<_KitDialog> {
  late final TextEditingController _primary;
  late final TextEditingController _secondary;
  late final TextEditingController _accent;
  late final TextEditingController _shorts;
  late final TextEditingController _socks;
  late ClubKitPattern _pattern;
  String? _error;

  @override
  void initState() {
    super.initState();
    _primary = TextEditingController(text: _hex(widget.kit.primaryHex));
    _secondary = TextEditingController(text: _hex(widget.kit.secondaryHex));
    _accent = TextEditingController(text: _hex(widget.kit.accentHex));
    _shorts = TextEditingController(text: _hex(widget.kit.shortsHex));
    _socks = TextEditingController(text: _hex(widget.kit.socksHex));
    _pattern = widget.kit.pattern;
  }

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    _accent.dispose();
    _shorts.dispose();
    _socks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ClubKitPattern>(
                initialValue: _pattern,
                decoration: const InputDecoration(labelText: 'Modelo'),
                items: ClubKitPattern.values
                    .map((value) => DropdownMenuItem(value: value, child: Text(value.label)))
                    .toList(),
                onChanged: (value) => setState(() => _pattern = value ?? _pattern),
              ),
              const SizedBox(height: 8),
              ColorPickerField(controller: _primary, label: 'Cor principal'),
              ColorPickerField(controller: _secondary, label: 'Cor secundária'),
              ColorPickerField(controller: _accent, label: 'Cor de detalhe'),
              ColorPickerField(controller: _shorts, label: 'Calção'),
              ColorPickerField(controller: _socks, label: 'Meiões'),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: _submit, child: const Text('Aplicar')),
        ],
      );


  void _submit() {
    try {
      Navigator.pop(
        context,
        ClubKit(
          primaryHex: _parseHex(_primary.text),
          secondaryHex: _parseHex(_secondary.text),
          accentHex: _parseHex(_accent.text),
          shortsHex: _parseHex(_shorts.text),
          socksHex: _parseHex(_socks.text),
          pattern: _pattern,
        ),
      );
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('FormatException: ', ''));
    }
  }
}

String _hex(int value) => ColorHex.format(value);

int _parseHex(String source) => ColorHex.parse(source);
