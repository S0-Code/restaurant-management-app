import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/restaurant_tables_provider.dart';
import 'table_form_page.dart';

class RestaurantTablesPage extends ConsumerWidget {
  final int restaurantId;

  const RestaurantTablesPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le provider pour avoir les données en temps réel
    final asyncTables = ref.watch(restaurantTablesProvider(restaurantId));

    return Stack(
      children: [
        asyncTables.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Erreur : $err')),
          data: (tables) {
            if (tables.isEmpty) {
              return const Center(
                child: Text(
                  "Aucune table n'est configurée pour ce restaurant.\nAppuyez sur le + pour en ajouter une.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];

                return Card(
                  margin: EdgeInsets.only(bottom: index == tables.length - 1 ? 0 : 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.table_restaurant, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Table ${table.tableNumber}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.people, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${table.capacity} personne${table.capacity > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => TableFormPage(restaurantId: restaurantId, existingTable: table),
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'tables_fab',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => TableFormPage(restaurantId: restaurantId),
              ));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}