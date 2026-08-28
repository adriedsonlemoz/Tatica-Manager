import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/career/manager_profile.dart';
import 'player_avatar.dart';

class ManagerAvatar extends StatelessWidget {
  const ManagerAvatar({
    super.key,
    required this.manager,
    this.size = 56,
    this.accentColor = AppColors.green,
    this.showBorder = true,
  });

  final ManagerProfile manager;
  final double size;
  final Color accentColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) => PlayerAvatar.identity(
        identity: manager.appearance.toAvatarIdentity(
          manager.avatarSeedSource,
          age: manager.ageAtStart,
        ),
        size: size,
        accentColor: accentColor,
        showBorder: showBorder,
        customImagePath: manager.appearance.customPhotoPath,
      );
}
