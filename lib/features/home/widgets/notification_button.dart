import 'package:flutter/material.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.notifications_none_outlined,
        size: 28,
      ),
    );
  }
}