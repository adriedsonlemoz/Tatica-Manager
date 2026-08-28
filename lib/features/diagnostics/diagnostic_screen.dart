import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/widgets/common.dart';
import '../../core/diagnostics/diagnostic_service.dart';
import '../../core/theme/app_colors.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  String _report = 'Carregando diagnóstico...';
  List<DiagnosticEntry> _entries = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    final report = await DiagnosticService.instance.buildReport();
    if (!mounted) return;
    setState(() {
      _report = report;
      _entries = DiagnosticService.instance.entries;
      _busy = false;
    });
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _report));
    if (mounted) _message('Diagnóstico copiado.');
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    final path = await DiagnosticService.instance.exportReport();
    if (!mounted) return;
    setState(() => _busy = false);
    _message(path == null ? 'Não foi possível exportar o TXT.' : 'TXT exportado para $path');
  }

  Future<void> _clear() async {
    await DiagnosticService.instance.clear();
    await _refresh();
    if (mounted) _message('Registros locais limpos.');
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final errors = _entries.where((entry) => entry.isError).toList(growable: false);
    final checkpoints = _entries.length - errors.length;
    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Central de Diagnóstico',
        subtitle: 'Erros, última saída e checkpoints recentes',
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DiagnosticMetric(
                        icon: errors.isEmpty ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                        label: 'Erros registrados',
                        value: '${errors.length}',
                        accent: errors.isEmpty ? AppColors.green : AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DiagnosticMetric(
                        icon: Icons.timeline_rounded,
                        label: 'Checkpoints',
                        value: '$checkpoints',
                        accent: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'O relatório reúne falhas Flutter/Dart, contexto do erro, stack trace e informações da última saída nativa quando o Android disponibiliza esses dados.',
                  style: TextStyle(color: AppColors.muted, height: 1.4, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Atualizar'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _copy,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copiar'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _export,
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar TXT'),
              ),
              TextButton.icon(
                onPressed: _busy ? null : _clear,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text('REGISTROS RECENTES', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              Text('${_entries.length}', style: const TextStyle(color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 7),
          if (_entries.isEmpty)
            const SectionCard(
              child: Text(
                'Nenhum erro persistido até agora.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            )
          else
            ..._entries.take(12).map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: _DiagnosticEntryCard(entry: entry),
                )),
          const SizedBox(height: 6),
          SectionCard(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              leading: const Icon(Icons.code_rounded, color: AppColors.green),
              title: const Text('Relatório técnico completo', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Dispositivo, última saída, erros e stack traces'),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    _report,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.4, color: AppColors.muted),
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

class _DiagnosticMetric extends StatelessWidget {
  const _DiagnosticMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DiagnosticEntryCard extends StatelessWidget {
  const _DiagnosticEntryCard({required this.entry});

  final DiagnosticEntry entry;

  @override
  Widget build(BuildContext context) {
    final accent = entry.isError ? AppColors.danger : AppColors.green;
    final hasDetails = entry.context?.isNotEmpty == true || entry.stack?.isNotEmpty == true;
    return SectionCard(
      padding: EdgeInsets.zero,
      borderColor: accent.withValues(alpha: .35),
      child: ExpansionTile(
        enabled: hasDetails,
        leading: Icon(entry.isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: accent),
        title: Text(
          entry.type,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.message,
              maxLines: hasDetails ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(_formatTime(entry.time), style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        children: [
          if (entry.context?.isNotEmpty == true) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contexto / origem',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(entry.context!, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
            ),
          ],
          if (entry.stack?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Stack trace',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                entry.stack!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: AppColors.muted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatTime(DateTime time) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(time.day)}/${two(time.month)} ${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
}
