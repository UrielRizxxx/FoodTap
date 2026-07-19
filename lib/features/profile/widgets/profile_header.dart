import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'profile_avatar_editor.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.onPhotoTap,
    this.isUploadingPhoto = false,
    this.isVerified = false,
    this.isFrequentSeller = false,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallback onPhotoTap;
  final bool isUploadingPhoto;
  final bool isVerified;
  final bool isFrequentSeller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatarEditor(
          photoUrl: photoUrl,
          onTap: onPhotoTap,
          isLoading: isUploadingPhoto,
        ),
        const SizedBox(height: 18),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        if (isVerified || isFrequentSeller) ...[
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isVerified)
                const _ProfileBadge(
                  icon: Icons.verified,
                  text: 'Verificado',
                ),
              if (isFrequentSeller)
                const _ProfileBadge(
                  icon: Icons.storefront,
                  text: 'Vendedor frecuente',
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}