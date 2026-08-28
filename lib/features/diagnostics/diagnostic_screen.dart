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
    setState(() { _report = report; _busy = false; });
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
  Widget build(BuildContext context) => PremiumScaffold(
        appBar: const GameTopBar(title: 'Central de Diagnóstico', subtitle: 'Erros, última saída e checkpoints recentes'),
        safeBottom: true,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(onPressed: _busy ? null : _refresh, icon: const Icon(Icons.refresh_rounded), label: const Text('Atualizar')),
              OutlinedButton.icon(onPressed: _busy ? null : _copy, icon: const Icon(Icons.copy_rounded), label: const Text('Copiar')),
              OutlinedButton.icon(onPressed: _busy ? null : _export, icon: const Icon(Icons.file_download_outlined), label: const Text('Exportar TXT')),
              TextButton.icon(onPressed: _busy ? null : _clear, icon: const Icon(Icons.delete_outline_rounded), label: const Text('Limpar')),
            ]),
            const SizedBox(height: 10),
            SectionCard(
              child: SelectableText(
                _report,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.4, color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
}
