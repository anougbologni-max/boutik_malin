import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editProfile(BuildContext context, SettingsProvider settings) async {
    final shopController = TextEditingController(text: settings.shopName);
    final ownerController = TextEditingController(text: settings.ownerName);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil de la boutique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: shopController,
              decoration: const InputDecoration(labelText: 'Nom de la boutique'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ownerController,
              decoration: const InputDecoration(labelText: 'Propriétaire'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enregistrer')),
        ],
      ),
    );

    if (result == true) {
      await settings.updateShopProfile(
        shopName: shopController.text.trim().isEmpty ? 'Ma Boutique' : shopController.text.trim(),
        ownerName: ownerController.text.trim(),
      );
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final products = context.read<ProductProvider>().products;
    final productProvider = context.read<ProductProvider>();

    final buffer = StringBuffer('Nom,Catégorie,Prix unitaire,Quantité,Valeur totale\n');
    for (final product in products) {
      buffer.writeln(
        '"${product.name}","${productProvider.categoryName(product.categoryId)}",'
        '${product.unitPrice},${product.quantity},${product.totalValue.toStringAsFixed(2)}',
      );
    }

    final dbPath = await getDatabasesPath();
    final filePath = p.join(dbPath, 'export_stock.csv');
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export enregistré : $filePath')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paramètres'),
            Text('Configuration de la boutique', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            onTap: () => _editProfile(context, settings),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text(
                      settings.shopName.isNotEmpty ? settings.shopName.substring(0, 2).toUpperCase() : 'BM',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settings.shopName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          settings.ownerName.isEmpty ? 'Propriétaire : —' : 'Propriétaire : ${settings.ownerName}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('GESTION DES STOCKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Seuil d\'alerte par défaut'),
            subtitle: const Text('Quantité minimale avant notification'),
            trailing: SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: settings.defaultThreshold.toString(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                onFieldSubmitted: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed >= 0) {
                    settings.updateDefaultThreshold(parsed);
                  }
                },
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Alertes par notifications'),
            subtitle: const Text('Notification quand un produit passe en stock bas'),
            value: settings.notificationsEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => settings.setNotificationsEnabled(value),
          ),
          const SizedBox(height: 16),

          const Text('DONNÉES & EXPORTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exporter au format CSV'),
            subtitle: const Text('Générer un rapport de l\'état du stock'),
            trailing: OutlinedButton(
              onPressed: () => _exportCsv(context),
              child: const Text('EXPORTER'),
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Devise'),
            subtitle: const Text('Utilisée pour l\'affichage des prix'),
            trailing: DropdownButton<String>(
              value: settings.currencyCode,
              items: SettingsProvider.currencySymbols.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} (${e.value})')))
                  .toList(),
              onChanged: (value) {
                if (value != null) settings.setCurrencyCode(value);
              },
            ),
          ),
          const SizedBox(height: 16),

          const Text('PRÉFÉRENCES D\'AFFICHAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Thème sombre'),
            subtitle: Text(settings.darkMode ? 'Activé' : 'Désactivé (mode clair actif)'),
            value: settings.darkMode,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => settings.setDarkMode(value),
          ),
        ],
      ),
    );
  }
}
