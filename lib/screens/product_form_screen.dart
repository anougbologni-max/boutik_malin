import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _thresholdController = TextEditingController(text: '5');

  int? _selectedCategoryId;
  String? _photoPath;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.unitPrice.toString();
      _quantityController.text = product.quantity.toString();
      _thresholdController.text = product.alertThreshold.toString();
      _selectedCategoryId = product.categoryId;
      _photoPath = product.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final productProvider = context.read<ProductProvider>();
    final product = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      categoryId: _selectedCategoryId!,
      unitPrice: double.parse(_priceController.text.replaceAll(',', '.')),
      quantity: int.parse(_quantityController.text),
      alertThreshold: int.parse(_thresholdController.text),
      photoPath: _photoPath,
    );

    if (_isEditing) {
      await productProvider.updateProduct(product);
    } else {
      await productProvider.addProduct(product);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le produit' : 'Nouveau produit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _photoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_photoPath!), fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.primary),
                          const SizedBox(height: 8),
                          const Text('Ajouter une photo du produit', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Formats acceptés : PNG, JPG', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('NOM DU PRODUIT *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ex: Huile de Tournesol 1L',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Le nom du produit est obligatoire' : null,
            ),
            const SizedBox(height: 16),

            const Text('CATÉGORIE *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Sélectionner une catégorie'),
              items: categories
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRIX UNITAIRE ($currencySymbol) *', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '0.00', border: OutlineInputBorder()),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) return 'Prix invalide';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('QUANTITÉ INITIALE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '0', border: OutlineInputBorder()),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed < 0) return 'Quantité invalide';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('SEUIL D\'ALERTE BAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('Notification auto', style: TextStyle(fontSize: 12, color: AppColors.accent)),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed < 0) return 'Seuil invalide';
                return null;
              },
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
