import 'package:flutter/material.dart';

import '../../../core/constants/product_status.dart';

class PublicationStatusBadge extends StatelessWidget {
  const PublicationStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final data = _getStatusData(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.icon,
            size: 15,
            color: data.foregroundColor,
          ),
          const SizedBox(width: 5),
          Text(
            data.label,
            style: TextStyle(
              color: data.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusData _getStatusData(String status) {
    switch (status) {
      case ProductStatus.approved:
        return _StatusData(
          label: 'Aprobado',
          icon: Icons.check_circle_outline,
          foregroundColor: Colors.green.shade700,
          backgroundColor: Colors.green.shade50,
        );

      case ProductStatus.rejected:
        return _StatusData(
          label: 'Rechazado',
          icon: Icons.cancel_outlined,
          foregroundColor: Colors.red.shade700,
          backgroundColor: Colors.red.shade50,
        );

      case ProductStatus.suspended:
        return _StatusData(
          label: 'Suspendido',
          icon: Icons.pause_circle_outline,
          foregroundColor: Colors.orange.shade800,
          backgroundColor: Colors.orange.shade50,
        );

      default:
        return _StatusData(
          label: 'Pendiente',
          icon: Icons.schedule,
          foregroundColor: Colors.blue.shade700,
          backgroundColor: Colors.blue.shade50,
        );
    }
  }
}

class _StatusData {
  const _StatusData({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
}