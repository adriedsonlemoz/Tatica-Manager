import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

Future<void> showGameNotice(
  BuildContext context, {
  required String message,
  String title = 'Atenção',
  IconData icon = Icons.info_outline_rounded,
}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: AppColors.green, size: 34),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
