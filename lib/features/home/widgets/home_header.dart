import 'package:flutter/material.dart';

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

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '¿Qué vas a comprar hoy?',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
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