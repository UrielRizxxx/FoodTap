import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.publications,
    required this.sales,
    required this.rating,
  });

  final int publications;
  final int sales;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '$publications',
              label: 'Publicaciones',
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatItem(
              value: '$sales',
              label: 'Ventas',
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatItem(
              value: rating.toStringAsFixed(1),
              label: 'Calificación',
              icon: Icons.star,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: AppColors.border,
    );
  }
}