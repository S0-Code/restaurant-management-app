import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_c05/views/pages/service_form_page.dart';
import '../../models/restaurant_service.dart';
import '../../providers/restaurant_services_provider.dart';
import '../../providers/manager_reservations_provider.dart';

class RestaurantServicesPage extends ConsumerWidget {
  final int restaurantId;

  const RestaurantServicesPage({super.key, required this.restaurantId});

// Vérifie si un service contient des réservations actives
  bool _isServiceInUse(RestaurantService service, List<dynamic> reservations) {
    return reservations.any((res) {
      // 1. conversion en String
      final statusStr = res.status.toString().toLowerCase();
      if (statusStr.contains('cancelled')) return false;

      // 2. Est-ce le même jour de la semaine ?
      if (res.dateTime.weekday != service.dayOfWeek) return false;

      // 3. L'heure de la réservation tombe-t-elle dans le service ?
      final resTotalMinutes = res.dateTime.hour * 60 + res.dateTime.minute;

      final startParts = service.startTime.split(':');
      final startTotalMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

      final endParts = service.endTime.split(':');
      final endTotalMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return resTotalMinutes >= startTotalMinutes && resTotalMinutes < endTotalMinutes;
    });
  }

  // Fonction pour gérer la suppression avec la boîte de dialogue de confirmation
  Future<void> _deleteService(BuildContext context, WidgetRef ref, RestaurantService service, String dayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le service'),
        content: Text('Êtes-vous sûr de vouloir supprimer le service du $dayName (${service.formattedStartTime} - ${service.formattedEndTime}) ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await RestaurantService.delete(service.id);
        ref.invalidate(restaurantServicesProvider(restaurantId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Service supprimé avec succès'), backgroundColor: Colors.blueGrey[800])
          );
        }
      } catch (e) {
        if (context.mounted) {
          final errorMsg = e.toString().replaceAll('Exception: Impossible de supprimer : ', 'Impossible de supprimer : ');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. On écoute les providers
    final asyncServices = ref.watch(restaurantServicesProvider(restaurantId));
    // On récupère les réservations du restaurant
    final reservations = ref.watch(managerReservationsProvider(restaurantId)).value ?? [];
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    return Stack(
      children: [
        asyncServices.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Erreur : $err')),
          data: (services) {
            if (services.isEmpty) {
              return const Center(
                child: Text(
                  "Aucun service n'est configuré.\nAppuyez sur le + pour en ajouter un.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // 2. L'algorithme de regroupement
            Map<int, List<RestaurantService>> groupedServices = {
              for (var i = 1; i <= 7; i++) i: []
            };

            for (var service in services) {
              groupedServices[service.dayOfWeek]?.add(service);
            }

            // 3. Affichage : On boucle sur les 7 jours
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayNumber = index + 1;
                final dayName = days[index];
                final dayServices = groupedServices[dayNumber]!;

                // CAS A : Aucun service pour ce jour
                if (dayServices.isEmpty) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.grey[100],
                    child: ListTile(
                      leading: const Icon(Icons.schedule, color: Colors.grey),
                      title: Text(dayName, style: TextStyle(color: Colors.grey[600])),
                      subtitle: const Text('Aucun service', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                // CAS B : Exactement 1 service pour ce jour
                if (dayServices.length == 1) {
                  final service = dayServices.first;
                  final bool inUse = _isServiceInUse(service, reservations);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(dayName),
                      subtitle: Text('${service.formattedStartTime} - ${service.formattedEndTime}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ServiceFormPage(restaurantId: restaurantId, existingService: service),
                              ));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: inUse ? Colors.grey[400] : Colors.red),
                            tooltip: inUse ? 'Impossible de supprimer : des réservations non annulées utilisent ce service' : 'Supprimer le service',
                            onPressed: inUse ? null : () => _deleteService(context, ref, service, dayName),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // CAS C : Plusieurs services pour ce jour
                final allTimes = dayServices.map((s) => '${s.formattedStartTime} - ${s.formattedEndTime}').join(', ');

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(dayName),
                    subtitle: Text(allTimes),
                    children: dayServices.map((service) {
                      final bool inUse = _isServiceInUse(service, reservations);

                      return ListTile(
                        title: Text('${service.formattedStartTime} - ${service.formattedEndTime}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ServiceFormPage(restaurantId: restaurantId, existingService: service),
                                ));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: inUse ? Colors.grey[400] : Colors.red),
                              tooltip: inUse ? 'Impossible de supprimer : des réservations non annulées utilisent ce service' : 'Supprimer le service',
                              onPressed: inUse ? null : () => _deleteService(context, ref, service, dayName),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),

        // Le bouton + en bas à droite
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'services_fab',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ServiceFormPage(restaurantId: restaurantId),
              ));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}