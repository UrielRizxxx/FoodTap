import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileAvatarEditor extends StatelessWidget {
  const ProfileAvatarEditor({
    super.key,
    this.photoUrl,
    required this.onTap,
    this.isLoading = false,
  });

  final String? photoUrl;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const _DefaultAvatar();
                    },
                  )
                : const _DefaultAvatar(),
          ),
        ),
        Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 40,
              height: 40,
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 21,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person,
        color: AppColors.primary,
        size: 62,
      ),
    );
  }
}