import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/stock_movement.dart';
import '../providers/product_provider.dart';
import '../providers/stock_movement_provider.dart';
import '../utils/constants.dart';

class StockMovementScreen extends StatefulWidget {
  final Product? preselectedProduct;

  const StockMovementScreen({super.key, this.preselectedProduct});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  final _reasonController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  Product? _selectedProduct;
  MovementType _type = MovementType.entry;
  int _quantity = 1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.preselectedProduct;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _setQuantity(int value) {
    final safeValue = value < 1 ? 1 : value;
    setState(() {
      _quantity = safeValue;
      _quantityController.text = safeValue.toString();
      _quantityController.selection = TextSelection.collapsed(offset: _quantityController.text.length);
    });
  }

  int? get _resultingQuantity {
    if (_selectedProduct == null) return null;
    return applyMovement(_selectedProduct!.quantity, _type, _quantity);
  }

  Future<void> _submit() async {
    final product = _selectedProduct;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un produit')),
      );
      return;
    }

    if (_type == MovementType.exit && _quantity > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantité en sortie supérieure au stock disponible')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final reason = _reasonController.text.trim().isEmpty
        ? (_type == MovementType.entry ? 'Réapprovisionnement' : 'Vente')
        : _reasonController.text.trim();

    await context.read<StockMovementProvider>().registerMovement(
          product: product,
          type: _type,
          quantity: _quantity,
          reason: reason,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mouvement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('SÉLECTIONNER UN PRODUIT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            initialValue: _selectedProduct?.id,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            hint: const Text('Choisir un produit'),
            items: products
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (id) {
              setState(() {
                _selectedProduct = products.where((p) => p.id == id).firstOrNull;
              });
            },
          ),
          const SizedBox(height: 20),

          const Text('TYPE DE MOUVEMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _MovementTypeButton(
                  label: '↑ Entrée (Stock +)',
                  color: AppColors.success,
                  isSelected: _type == MovementType.entry,
                  onTap: () => setState(() => _type = MovementType.entry),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MovementTypeButton(
                  label: '↓ Sortie (Stock -)',
                  color: AppColors.accent,
                  isSelected: _type == MovementType.exit,
                  onTap: () => setState(() => _type = MovementType.exit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('QUANTITÉ À MOUVEMENTER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _quantity > 1 ? () => _setQuantity(_quantity - 1) : null,
                ),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed >= 1) {
                        setState(() => _quantity = parsed);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _setQuantity(_quantity + 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('MOTIF / RÉFÉRENCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _reasonController,
            decoration: const InputDecoration(
              hintText: 'Ex: Livraison fournisseur, Vente caisse...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          if (_selectedProduct != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Impact prévisionnel du stock', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Stock actuel : ${_selectedProduct!.quantity} → Nouveau stock : $_resultingQuantity'),
                ],
              ),
            ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_isSaving ? 'Enregistrement...' : 'Valider le mouvement'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTypeButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MovementTypeButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
