import 'package:flutter/material.dart';

import '../utils/constants.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool highlighted;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.accent.withValues(alpha: 0.1) : Colors.white,
        border: highlighted ? Border.all(color: AppColors.accent.withValues(alpha: 0.4)) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: highlighted ? AppColors.accent : AppColors.primary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: highlighted ? AppColors.accent : Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
