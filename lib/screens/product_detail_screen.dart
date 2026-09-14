import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stock_movement_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/movement_tile.dart';
import 'product_form_screen.dart';
import 'stock_movement_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('« ${product.name} » sera définitivement supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ProductProvider>().deleteProduct(product.id!);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    final product = productProvider.products.where((p) => p.id == productId).firstOrNull;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail produit')),
        body: const Center(child: Text('Produit introuvable')),
      );
    }

    final movements = context
        .watch<StockMovementProvider>()
        .movementsForProduct(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.accent),
            onPressed: () => _confirmDelete(context, product),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.photoPath != null
                ? Image.file(File(product.photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _InfoRow(label: 'Catégorie', value: productProvider.categoryName(product.categoryId)),
                  _InfoRow(label: 'Prix unitaire', value: formatPrice(product.unitPrice, symbol: currencySymbol)),
                  _InfoRow(label: 'Seuil d\'alerte', value: '${product.alertThreshold} unités'),
                  _InfoRow(
                    label: 'Statut stock',
                    valueWidget: _StockBadge(isLowStock: product.isLowStock),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantité actuelle', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${product.quantity} unités',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StockMovementScreen(preselectedProduct: product)),
                );
              },
              icon: const Icon(Icons.swap_vert),
              label: const Text('Enregistrer un mouvement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Historique des mouvements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (movements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Aucun mouvement enregistré pour ce produit'),
            )
          else
            ...movements.map((m) => MovementTile(movement: m, showProductName: false)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          valueWidget ?? Text(value ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final bool isLowStock;

  const _StockBadge({required this.isLowStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLowStock ? AppColors.accent.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isLowStock ? 'Stock Faible' : 'Stock OK',
        style: TextStyle(
          color: isLowStock ? AppColors.accent : AppColors.success,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
