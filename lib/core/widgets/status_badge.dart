import 'package:flutter/material.dart';

import '../constants/product_status.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  String get _label {
    switch (status) {
      case ProductStatus.approved:
        return 'Aprobado';
      case ProductStatus.rejected:
        return 'Rechazado';
      case ProductStatus.suspended:
        return 'Suspendido';
      case ProductStatus.pending:
      default:
        return 'Pendiente';
    }
  }

  Color get _color {
    switch (status) {
      case ProductStatus.approved:
        return AppColors.success;
      case ProductStatus.rejected:
      case ProductStatus.suspended:
        return AppColors.error;
      case ProductStatus.pending:
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
