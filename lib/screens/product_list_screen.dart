import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../utils/constants.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = productProvider.products;

          if (products.isEmpty) {
            return const Center(child: Text('Aucun produit pour le moment'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text(productProvider.categoryName(product.categoryId)),
                trailing: Text('${product.quantity} en stock'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: product.id!),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
