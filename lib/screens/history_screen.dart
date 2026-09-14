import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/stock_movement.dart';
import '../providers/product_provider.dart';
import '../providers/stock_movement_provider.dart';
import '../utils/constants.dart';
import '../widgets/movement_tile.dart';

const _frenchMonths = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final day = DateTime(date.year, date.month, date.day);

  if (day == today) return "Aujourd'hui";
  if (day == yesterday) return 'Hier';
  return '${date.day} ${_frenchMonths[date.month - 1]}';
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  MovementType? _typeFilter;
  int? _categoryFilter;
  DateTime? _dateFilter;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateFilter = picked);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final allMovements = context.watch<StockMovementProvider>().movements;

    final filtered = allMovements.where((m) {
      if (_typeFilter != null && m.type != _typeFilter) return false;
      if (_dateFilter != null) {
        final d = m.date;
        if (d.year != _dateFilter!.year || d.month != _dateFilter!.month || d.day != _dateFilter!.day) {
          return false;
        }
      }
      if (_categoryFilter != null) {
        final product = productProvider.findById(m.productId);
        if (product == null || product.categoryId != _categoryFilter) return false;
      }
      return true;
    }).toList();

    final grouped = <String, List<StockMovement>>{};
    for (final m in filtered) {
      grouped.putIfAbsent(_dayLabel(m.date), () => []).add(m);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historique'),
            Text('Mouvements enregistrés', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(child: _FilterChip(label: 'Tous', selected: _typeFilter == null, onTap: () => setState(() => _typeFilter = null))),
                const SizedBox(width: 8),
                Expanded(child: _FilterChip(label: 'Entrées (+)', selected: _typeFilter == MovementType.entry, onTap: () => setState(() => _typeFilter = MovementType.entry))),
                const SizedBox(width: 8),
                Expanded(child: _FilterChip(label: 'Sorties (-)', selected: _typeFilter == MovementType.exit, onTap: () => setState(() => _typeFilter = MovementType.exit))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _dateFilter == null
                          ? 'Date'
                          : '${_dateFilter!.day}/${_dateFilter!.month}/${_dateFilter!.year}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                if (_dateFilter != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _dateFilter = null),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _categoryFilter,
                    isExpanded: true,
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Toutes catégories', overflow: TextOverflow.ellipsis)),
                      ...productProvider.categories.map(
                        (c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _categoryFilter = value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: grouped.isEmpty
                ? const Center(child: Text('Aucun mouvement pour ces filtres'))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: grouped.entries.expand((entry) {
                      return [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                          ),
                        ),
                        ...entry.value.map((m) => MovementTile(movement: m)),
                      ];
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
