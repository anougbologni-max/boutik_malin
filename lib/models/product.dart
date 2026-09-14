class Product {
  final int? id;
  final String name;
  final int categoryId;
  final double unitPrice;
  final int quantity;
  final int alertThreshold;
  final String? photoPath;

  const Product({
    this.id,
    required this.name,
    required this.categoryId,
    required this.unitPrice,
    required this.quantity,
    required this.alertThreshold,
    this.photoPath,
  });

  bool get isLowStock => quantity <= alertThreshold;

  double get totalValue => unitPrice * quantity;

  Product copyWith({
    int? id,
    String? name,
    int? categoryId,
    double? unitPrice,
    int? quantity,
    int? alertThreshold,
    String? photoPath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'alertThreshold': alertThreshold,
      'photoPath': photoPath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryId: map['categoryId'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      alertThreshold: map['alertThreshold'] as int,
      photoPath: map['photoPath'] as String?,
    );
  }
}
