import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/restaurant_table.dart';
import '../../providers/restaurant_tables_provider.dart';

class TableFormPage extends ConsumerStatefulWidget {
  final int restaurantId;
  final RestaurantTable? existingTable;

  const TableFormPage({super.key, required this.restaurantId, this.existingTable});

  @override
  ConsumerState<TableFormPage> createState() => _TableFormPageState();
}

class _TableFormPageState extends ConsumerState<TableFormPage> {
  late TextEditingController _numberController;
  late int _capacity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.existingTable?.tableNumber.toString() ?? '');
    _capacity = widget.existingTable?.capacity ?? 2;
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final numberStr = _numberController.text.trim();
    if (numberStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le numéro est requis')));
      return;
    }

    final tableNumber = int.tryParse(numberStr);
    if (tableNumber == null || tableNumber <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Numéro de table invalide')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.existingTable == null) {
        await RestaurantTable.create(widget.restaurantId, tableNumber, _capacity);
      } else {
        await RestaurantTable.update(widget.existingTable!.id, tableNumber, _capacity);
      }

      // Rafraîchir la liste des tables
      ref.invalidate(restaurantTablesProvider(widget.restaurantId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingTable == null ? 'Table créée avec succès' : 'Table mise à jour avec succès'),
              backgroundColor: Colors.blueGrey[800],
            )
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Affichage des erreurs PostgreSQL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTable != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la table' : 'Nouvelle table'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numéro de table',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Capacité', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _capacity > 1
                      ? () => setState(() => _capacity--)
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capacité minimale (1 personne)')));
                  },
                ),
                Text('$_capacity personne${_capacity > 1 ? 's' : ''}', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _capacity++),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}