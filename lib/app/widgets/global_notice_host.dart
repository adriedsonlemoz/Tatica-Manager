import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../audio/audio_providers.dart';
import '../state/game_controller.dart';
import '../state/reward_controller.dart';

/// Mantém avisos acima do Navigator para que continuem visíveis em qualquer
/// tela. Recompensas sempre interrompem avisos comuns, que voltam para a fila.
class GlobalNoticeHost extends ConsumerStatefulWidget {
  const GlobalNoticeHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GlobalNoticeHost> createState() => _GlobalNoticeHostState();
}

class _GlobalNoticeHostState extends ConsumerState<GlobalNoticeHost> {
  final List<_QueuedNotice> _queue = [];
  final Set<String> _seenRewardKeys = {};
  Timer? _timer;
  _QueuedNotice? _current;
  int _nextCommonId = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardState>(rewardControllerProvider, (previous, next) {
      final notice = next.notice;
      if (notice == null || !_seenRewardKeys.add(notice.eventKey)) return;
      _enqueue(
        _QueuedNotice(
          id: 'reward:${notice.eventKey}',
          title: notice.title,
          message: notice.message,
          rewardEventKey: notice.eventKey,
        ),
      );
    });
    ref.listen<GameState>(gameControllerProvider, (previous, next) {
      final message = next.message;
      if (message == null || message == previous?.message) return;
      _enqueue(
        _QueuedNotice(
          id: 'common:${_nextCommonId++}',
          title: 'Atualização do clube',
          message: message,
        ),
      );
      Future.microtask(() {
        ref.read(gameControllerProvider.notifier).clearMessage();
      });
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 12,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -1.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _current == null
                    ? const SizedBox.shrink(key: ValueKey('notice-empty'))
                    : ConstrainedBox(
                        key: ValueKey(_current!.id),
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _GlobalNoticeCard(
                            notice: _current!,
                            onDismiss: _finishCurrent,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _enqueue(_QueuedNotice notice) {
    if (!mounted) return;
    if (notice.reward && _current?.reward != true) {
      _timer?.cancel();
      if (_current != null) _queue.insert(0, _current!);
      setState(() => _current = notice);
      _scheduleCurrent();
      return;
    }
    if (notice.reward) {
      final firstCommon = _queue.indexWhere((item) => !item.reward);
      _queue.insert(firstCommon < 0 ? _queue.length : firstCommon, notice);
    } else {
      _queue.add(notice);
    }
    if (_current == null) _showNext();
  }

  void _showNext() {
    if (!mounted || _current != null || _queue.isEmpty) return;
    setState(() => _current = _queue.removeAt(0));
    _scheduleCurrent();
  }

  void _scheduleCurrent() {
    _timer?.cancel();
    final notice = _current;
    if (notice == null) return;
    if (notice.reward) {
      unawaited(ref.read(audioManagerProvider).playUi(UiAudioCue.confirm));
    }
    _timer = Timer(
      Duration(milliseconds: notice.reward ? 4200 : 3200),
      _finishCurrent,
    );
  }

  void _finishCurrent() {
    if (!mounted || _current == null) return;
    _timer?.cancel();
    final rewardEventKey = _current!.rewardEventKey;
    setState(() => _current = null);
    if (rewardEventKey != null) {
      ref
          .read(rewardControllerProvider.notifier)
          .consumeNotice(rewardEventKey);
    }
    Future<void>.delayed(const Duration(milliseconds: 210), _showNext);
  }
}

class _QueuedNotice {
  const _QueuedNotice({
    required this.id,
    required this.title,
    required this.message,
    this.rewardEventKey,
  });

  final String id;
  final String title;
  final String message;
  final String? rewardEventKey;

  bool get reward => rewardEventKey != null;
}

class _GlobalNoticeCard extends StatelessWidget {
  const _GlobalNoticeCard({required this.notice, required this.onDismiss});

  final _QueuedNotice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 12,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onDismiss,
          borderRadius: BorderRadius.circular(17),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(13, 11, 11, 11),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised.withValues(alpha: .985),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: notice.reward
                    ? AppColors.green.withValues(alpha: .72)
                    : AppColors.border,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x77000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notice.reward
                        ? Icons.workspace_premium_rounded
                        : Icons.notifications_active_rounded,
                    color: AppColors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        style: TextStyle(
                          color: notice.reward
                              ? AppColors.green
                              : AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notice.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.muted,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
