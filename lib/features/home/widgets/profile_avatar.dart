import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.onTap,
  });

  final String? photoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade200,
        backgroundImage:
            photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null
            ? const Icon(
                Icons.person,
                color: Colors.grey,
              )
            : null,
      ),
    );
  }
}