import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (title) {
      case 'Frutas':
        return Icons.local_grocery_store_outlined;
      case 'Verduras':
        return Icons.eco_outlined;
      case 'Comida':
        return Icons.restaurant_outlined;
      case 'Bebidas':
        return Icons.local_drink_outlined;
      case 'PanaderÃ­a':
        return Icons.bakery_dining_outlined;
      case 'LÃ¡cteos':
        return Icons.icecream_outlined;
      case 'Carnes':
        return Icons.lunch_dining_outlined;
      case 'Postres':
        return Icons.cake_outlined;
      case 'Snacks':
        return Icons.fastfood_outlined;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  size: 20,
                  color:
                      selected ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
