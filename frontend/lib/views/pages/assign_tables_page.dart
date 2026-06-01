import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/manager_reservation.dart';
import '../../models/table_availability.dart';
import '../../providers/manager_reservations_provider.dart';
import '../../providers/table_availability_provider.dart';

class AssignTablesPage extends ConsumerStatefulWidget {
  final ManagerReservation reservation;

  const AssignTablesPage({super.key, required this.reservation});

  @override
  ConsumerState<AssignTablesPage> createState() => _AssignTablesPageState();
}

class _AssignTablesPageState extends ConsumerState<AssignTablesPage> {
  final Set<TableAvailability> _selectedTables = {};
  bool _isLoading = false;

  void _toggleTable(TableAvailability table, bool? value) {
    if (!table.isAvailable) return;
    setState(() {
      if (value == true) {
        _selectedTables.add(table);
      } else {
        _selectedTables.remove(table);
      }
    });
  }

  Future<void> _confirmReservation() async {
    setState(() => _isLoading = true);
    try {
      final tableIds = _selectedTables.map((t) => t.id).toList();
      await TableAvailability.assignAndConfirm(widget.reservation.id, tableIds);

      // Rafraîchit les réservations en arrière-plan
      ref.invalidate(managerReservationsProvider(widget.reservation.restaurantId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation confirmée avec les tables assignées'),
            backgroundColor: Colors.green,
          ),
        );
        // On fait 2 "pop" pour retourner directement à la liste (RestaurantManagementPage)
        Navigator.of(context)..pop()..pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = TableAvailabilityArgs(widget.reservation.restaurantId, widget.reservation.id);
    final asyncTables = ref.watch(tableAvailabilityProvider(args));

    final totalCapacity = _selectedTables.fold(0, (sum, t) => sum + t.capacity);
    final hasEnoughCapacity = totalCapacity >= widget.reservation.numberOfGuests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigner des tables'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // En-tête bleu clair avec les informations
            Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Réservation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${widget.reservation.numberOfGuests} convives'),
                  Text(DateFormat('dd/MM/yyyy à HH:mm').format(widget.reservation.dateTime)),
                ],
              ),
            ),

            // Bannière de capacité dynamique
            if (_selectedTables.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: hasEnoughCapacity ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: hasEnoughCapacity ? Colors.green : Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasEnoughCapacity ? Icons.check_circle : Icons.warning,
                          color: hasEnoughCapacity ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Capacité totale: $totalCapacity places',
                          style: TextStyle(
                            color: hasEnoughCapacity ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasEnoughCapacity
                          ? '✓ Capacité suffisante pour ${widget.reservation.numberOfGuests} convives'
                          : '! Capacité insuffisante: $totalCapacity places pour ${widget.reservation.numberOfGuests} convives',
                      style: TextStyle(
                        color: hasEnoughCapacity ? Colors.green : Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            // Liste des tables
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sélectionnez les tables disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: asyncTables.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Erreur: $err')),
                data: (tables) {
                  if (tables.isEmpty) {
                    return const Center(child: Text("Aucune table n'est configurée pour ce restaurant."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.table_restaurant,
                            color: table.isAvailable ? Colors.black87 : Colors.grey,
                          ),
                          title: Text('Table ${table.tableNumber}'),
                          subtitle: Text(
                            table.isAvailable
                                ? 'Capacité: ${table.capacity} personnes'
                                : 'Occupée pour ce service',
                            style: TextStyle(color: table.isAvailable ? Colors.grey[600] : Colors.red),
                          ),
                          trailing: table.isAvailable
                              ? Checkbox(
                            value: _selectedTables.contains(table),
                            onChanged: (val) => _toggleTable(table, val),
                          )
                              : null,
                          onTap: table.isAvailable
                              ? () => _toggleTable(table, !_selectedTables.contains(table))
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bouton de validation
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasEnoughCapacity && !_isLoading ? _confirmReservation : null,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Confirmer la réservation', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}