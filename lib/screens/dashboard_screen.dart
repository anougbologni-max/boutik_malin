import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stock_movement_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/alert_tile.dart';
import '../widgets/movement_tile.dart';
import '../widgets/stat_card.dart';
import 'product_detail_screen.dart';
import 'stock_movement_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Boutik Malin'),
            Text('Gestion de stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StockMovementScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer2<ProductProvider, StockMovementProvider>(
        builder: (context, productProvider, stockMovementProvider, child) {
          final currencySymbol = context.watch<SettingsProvider>().currencySymbol;

          if (productProvider.isLoading || stockMovementProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final lowStockProducts = productProvider.lowStockProducts;

          final today = DateTime.now();
          final todayMovements = stockMovementProvider.movements.where((m) =>
              m.date.year == today.year && m.date.month == today.month && m.date.day == today.day);
          final todayEntries = todayMovements.where((m) => m.type.name == 'entry').length;
          final todayExits = todayMovements.where((m) => m.type.name == 'exit').length;

          final recentMovements = stockMovementProvider.movements.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await productProvider.loadAll();
              await stockMovementProvider.loadMovements();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Valeur stock',
                        value: formatPrice(productProvider.totalStockValue, symbol: currencySymbol),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        label: 'Alertes',
                        value: '${lowStockProducts.length} produits',
                        subtitle: lowStockProducts.isNotEmpty ? 'Action requise' : 'Tout va bien',
                        highlighted: lowStockProducts.isNotEmpty,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        label: 'Mvts jour',
                        value: '${todayMovements.length}',
                        subtitle: '$todayEntries entrées / $todayExits sorties',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (lowStockProducts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Alertes stock bas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('IMPORTANT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...lowStockProducts.map(
                    (p) => AlertTile(
                      product: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id!)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const Text('Derniers mouvements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (recentMovements.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Aucun mouvement enregistré pour le moment'),
                  )
                else
                  ...recentMovements.map((m) => MovementTile(movement: m)),
              ],
            ),
          );
        },
      ),
    );
  }
}
