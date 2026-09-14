enum MovementType { entry, exit }

int applyMovement(int currentQuantity, MovementType type, int movementQuantity) {
  return type == MovementType.entry
      ? currentQuantity + movementQuantity
      : currentQuantity - movementQuantity;
}

class StockMovement {
  final int? id;
  final int productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final DateTime date;
  final String reason;

  const StockMovement({
    this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type.name,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'reason': reason,
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      productName: map['productName'] as String? ?? 'Produit supprimé',
      type: MovementType.values.byName(map['type'] as String),
      quantity: map['quantity'] as int,
      date: DateTime.parse(map['date'] as String),
      reason: map['reason'] as String,
    );
  }
}
