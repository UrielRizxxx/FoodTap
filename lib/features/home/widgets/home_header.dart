import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'notification_button.dart';
import 'profile_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    this.photoUrl,
    this.onProfileTap,
    this.onNotificationTap,
  });

  final String userName;
  final String? photoUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          photoUrl: photoUrl,
          onTap: onProfileTap,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Que vas a comprar hoy?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        NotificationButton(
          onPressed: onNotificationTap,
        ),
      ],
    );
  }
}
