import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Виджет строки информации с иконкой, меткой и значением.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingInfoRowVertical,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeInfoRow,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.spacingLarge),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
