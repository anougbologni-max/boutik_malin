import 'package:flutter/material.dart';

import '../models/stock_movement.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class MovementTile extends StatelessWidget {
  final StockMovement movement;
  final bool showProductName;

  const MovementTile({super.key, required this.movement, this.showProductName = true});

  @override
  Widget build(BuildContext context) {
    final isEntry = movement.type == MovementType.entry;
    final dateAndReason = '${timeAgo(movement.date)} · ${movement.reason}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (isEntry ? AppColors.success : AppColors.accent).withValues(alpha: 0.15),
        child: Icon(
          isEntry ? Icons.arrow_upward : Icons.arrow_downward,
          color: isEntry ? AppColors.success : AppColors.accent,
        ),
      ),
      title: Text(
        showProductName ? movement.productName : dateAndReason,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: showProductName ? Text(dateAndReason) : null,
      trailing: Text(
        '${isEntry ? '+' : '-'}${movement.quantity}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isEntry ? AppColors.success : AppColors.accent,
        ),
      ),
    );
  }
}
