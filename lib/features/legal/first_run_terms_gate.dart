import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'game_information_screen.dart';

class FirstRunTermsGate extends StatelessWidget {
  const FirstRunTermsGate({
    super.key,
    required this.onAccept,
  });

  final Future<void> Function() onAccept;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surfaceSoft, AppColors.background],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Dialog(
                      backgroundColor: AppColors.surface,
                      insetPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side:  BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.green,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Bem-vindo ao Tática Manager',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 7),
                             Text(
                              'Antes de continuar, leia os Termos de Uso e a Política de Privacidade. O jogo mantém os principais dados de carreira localmente no aparelho.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                height: 1.45,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const GameInformationScreen(
                                          page: GameInformationPage.terms,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Termos de Uso'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const GameInformationScreen(
                                          page: GameInformationPage.privacy,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Privacidade'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () async => onAccept(),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Aceitar e continuar'),
                              ),
                            ),
                            const SizedBox(height: 7),
                             Text(
                              'Ao tocar em “Aceitar e continuar”, você confirma que leu e concorda com os Termos de Uso.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 9.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
