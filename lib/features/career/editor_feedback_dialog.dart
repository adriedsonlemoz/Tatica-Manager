import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

Future<void> showEditorNotice(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Color accent = AppColors.green,
}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
        icon: Icon(icon, color: accent, size: 42),
        title: Text(title, textAlign: TextAlign.center),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

Future<bool> showEditorConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  IconData icon = Icons.help_outline_rounded,
  Color accent = AppColors.green,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      icon: Icon(icon, color: accent, size: 42),
      title: Text(title, textAlign: TextAlign.center),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Text(message, textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: destructive ? FilledButton.styleFrom(backgroundColor: AppColors.danger) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed == true;
}
