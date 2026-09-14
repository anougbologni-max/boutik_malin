import 'package:flutter_test/flutter_test.dart';

import 'package:boutik_malin/models/product.dart';

void main() {
  group('Product.isLowStock', () {
    test('est vrai quand la quantité est sous le seuil', () {
      const product = Product(
        name: 'Riz Basmati 1kg',
        categoryId: 1,
        unitPrice: 2.4,
        quantity: 3,
        alertThreshold: 5,
      );

      expect(product.isLowStock, isTrue);
    });

    test('est vrai quand la quantité est exactement égale au seuil', () {
      const product = Product(
        name: 'Riz Basmati 1kg',
        categoryId: 1,
        unitPrice: 2.4,
        quantity: 5,
        alertThreshold: 5,
      );

      expect(product.isLowStock, isTrue);
    });

    test('est faux quand la quantité est au-dessus du seuil', () {
      const product = Product(
        name: 'Riz Basmati 1kg',
        categoryId: 1,
        unitPrice: 2.4,
        quantity: 45,
        alertThreshold: 5,
      );

      expect(product.isLowStock, isFalse);
    });
  });

  group('Product.totalValue', () {
    test('multiplie le prix unitaire par la quantité', () {
      const product = Product(
        name: 'Coca Cola 1.5L',
        categoryId: 2,
        unitPrice: 1.8,
        quantity: 8,
        alertThreshold: 12,
      );

      expect(product.totalValue, closeTo(14.4, 0.001));
    });
  });

  group('Product.copyWith', () {
    test('ne modifie que le champ demandé', () {
      const product = Product(
        id: 1,
        name: 'Savon Liquide 500ml',
        categoryId: 3,
        unitPrice: 3.2,
        quantity: 4,
        alertThreshold: 5,
      );

      final updated = product.copyWith(quantity: 20);

      expect(updated.quantity, 20);
      expect(updated.name, product.name);
      expect(updated.unitPrice, product.unitPrice);
    });
  });
}
