import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/stock_movement.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'product_provider.dart';

class StockMovementProvider extends ChangeNotifier {
  final DatabaseService _db;
  ProductProvider? _productProvider;

  StockMovementProvider(this._db);

  List<StockMovement> _movements = [];
  bool _isLoading = false;

  List<StockMovement> get movements => _movements;
  bool get isLoading => _isLoading;

  List<StockMovement> movementsForProduct(int productId) {
    return _movements.where((m) => m.productId == productId).toList();
  }

  void attachProductProvider(ProductProvider productProvider) {
    _productProvider = productProvider;
  }

  Future<void> loadMovements() async {
    _isLoading = true;
    notifyListeners();

    _movements = await _db.getMovements();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerMovement({
    required Product product,
    required MovementType type,
    required int quantity,
    required String reason,
  }) async {
    final newQuantity = applyMovement(product.quantity, type, quantity);

    final movement = StockMovement(
      productId: product.id!,
      productName: product.name,
      type: type,
      quantity: quantity,
      date: DateTime.now(),
      reason: reason,
    );

    await _db.recordMovement(movement, newQuantity);
    await loadMovements();
    await _productProvider?.loadAll();

    await NotificationService.instance.notifyIfLowStock(
      product.copyWith(quantity: newQuantity),
    );
  }
}
