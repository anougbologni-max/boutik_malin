import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/constants.dart';

class AlertTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const AlertTile({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('Seuil d\'alerte : ${product.alertThreshold} unités'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${product.quantity} restants',
          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
