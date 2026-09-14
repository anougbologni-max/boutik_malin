import 'package:flutter_test/flutter_test.dart';

import 'package:boutik_malin/models/stock_movement.dart';

void main() {
  group('applyMovement', () {
    test('une entrée augmente la quantité', () {
      final result = applyMovement(10, MovementType.entry, 5);
      expect(result, 15);
    });

    test('une sortie diminue la quantité', () {
      final result = applyMovement(10, MovementType.exit, 3);
      expect(result, 7);
    });

    test('une sortie supérieure au stock peut donner un résultat négatif', () {
      final result = applyMovement(2, MovementType.exit, 5);
      expect(result, -3);
    });
  });

  group('StockMovement.toMap / fromMap', () {
    test('reconstruit un objet identique après un aller-retour', () {
      final movement = StockMovement(
        id: 1,
        productId: 7,
        productName: 'Huile de Tournesol 1L',
        type: MovementType.entry,
        quantity: 10,
        date: DateTime(2026, 2, 4, 9, 12),
        reason: 'Livraison Fournisseur',
      );

      final rebuilt = StockMovement.fromMap(movement.toMap());

      expect(rebuilt.productId, movement.productId);
      expect(rebuilt.productName, movement.productName);
      expect(rebuilt.type, movement.type);
      expect(rebuilt.quantity, movement.quantity);
      expect(rebuilt.date, movement.date);
      expect(rebuilt.reason, movement.reason);
    });
  });
}
