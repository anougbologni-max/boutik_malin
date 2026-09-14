import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseService _db;

  ProductProvider(this._db);

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  double get totalStockValue =>
      _products.fold(0, (sum, p) => sum + p.totalValue);

  String categoryName(int categoryId) {
    final match = _categories.where((c) => c.id == categoryId);
    return match.isEmpty ? 'Sans catégorie' : match.first.name;
  }

  Product? findById(int id) {
    return _products.where((p) => p.id == id).firstOrNull;
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _db.getCategories();
    _products = await _db.getProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _db.insertProduct(product);
    await loadAll();
  }

  Future<void> updateProduct(Product product) async {
    await _db.updateProduct(product);
    await loadAll();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    await loadAll();
  }
}
