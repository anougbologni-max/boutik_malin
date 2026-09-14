import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'boutik_malin.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            categoryId INTEGER NOT NULL,
            unitPrice REAL NOT NULL,
            quantity INTEGER NOT NULL,
            alertThreshold INTEGER NOT NULL,
            photoPath TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE stock_movements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId INTEGER NOT NULL,
            productName TEXT NOT NULL,
            type TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            date TEXT NOT NULL,
            reason TEXT NOT NULL,
            FOREIGN KEY (productId) REFERENCES products (id)
          )
        ''');

        final defaultCategories = ['Épicerie', 'Boissons', 'Frais', 'Hygiène'];
        for (final name in defaultCategories) {
          await db.insert('categories', {'name': name});
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE stock_movements ADD COLUMN productName TEXT NOT NULL DEFAULT ''",
          );
          await db.execute('''
            UPDATE stock_movements
            SET productName = (
              SELECT name FROM products WHERE products.id = stock_movements.productId
            )
            WHERE productName = ''
          ''');
        }
      },
    );
  }

  // ---------- Categories ----------

  Future<List<Category>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'name');
    return rows.map((row) => Category.fromMap(row)).toList();
  }

  // ---------- Products ----------

  Future<List<Product>> getProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'name');
    return rows.map((row) => Product.fromMap(row)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert('products', product.toMap()..remove('id'));
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Stock movements ----------

  Future<List<StockMovement>> getMovements() async {
    final db = await database;
    final rows = await db.query('stock_movements', orderBy: 'date DESC');
    return rows.map((row) => StockMovement.fromMap(row)).toList();
  }

  Future<void> recordMovement(StockMovement movement, int newQuantity) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('stock_movements', movement.toMap()..remove('id'));
      await txn.update(
        'products',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [movement.productId],
      );
    });
  }
}
