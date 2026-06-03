import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/restaurant_service.dart';
import '../../providers/client_state_provider.dart';
import '../../providers/reference_time_provider.dart';

class RestaurantDetailPage extends ConsumerStatefulWidget {
  const RestaurantDetailPage({super.key});

  @override
  ConsumerState<RestaurantDetailPage> createState() =>
      _RestaurantDetailPageState();
}

class _RestaurantDetailPageState
    extends ConsumerState<RestaurantDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(clientStateProvider.notifier)
          .loadCurrentRestaurantServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(referenceTimeProvider);
    final clientState = ref.watch(clientStateProvider).value;
    final restaurant = clientState?.currentRestaurant;
    final services = clientState?.currentRestaurantServices ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Détails du restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(clientStateProvider.notifier).refresh();
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message:
                'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: restaurant == null
            ? const Center(
          child: Text('Aucun restaurant sélectionné.'),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  if (restaurant.rating != null) ...[
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(restaurant.rating!.toStringAsFixed(1)),
                    const SizedBox(width: 16),
                  ],
                  if (restaurant.priceRange != null &&
                      restaurant.priceRange! > 0) ...[
                    Text('€' * restaurant.priceRange!),
                    const SizedBox(width: 16),
                  ],
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(restaurant.city),
                ],
              ),

              if (restaurant.address != null &&
                  restaurant.address!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.place,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant.address!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],

              if (restaurant.phone != null &&
                  restaurant.phone!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.phone!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],

              if (restaurant.pendingRequestsCount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.pending,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${restaurant.pendingRequestsCount} demande${restaurant.pendingRequestsCount > 1 ? 's' : ''} en attente',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              if (restaurant.description != null &&
                  restaurant.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(restaurant.description!),
              ],

              const SizedBox(height: 24),

              const Text(
                'Horaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              services.isEmpty
                  ? const Text(
                'Aucun horaire renseigné.',
                style: TextStyle(color: Colors.grey),
              )
                  : _RestaurantServicesView(services: services),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(clientStateProvider.notifier).prepareNewReservation();

                    if (!context.mounted) return;

                    Navigator.pushNamed(
                      context,
                      '/clientAddReservation',
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Réserver'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantServicesView extends StatelessWidget {
  final List<RestaurantService> services;

  const _RestaurantServicesView({
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Regrouper les services par jour
    final groupedServices = <int, List<RestaurantService>>{};

    for (final service in services) {
      groupedServices.putIfAbsent(service.dayOfWeek, () => []);
      groupedServices[service.dayOfWeek]!.add(service);
    }

    // 2. Extraire uniquement les jours qui ont au moins un service
    final activeDays = groupedServices.keys.toList()..sort();

    // 3. Couper la liste en deux pour faire deux colonnes équilibrées
    final half = (activeDays.length / 2).ceil();
    final leftDays = activeDays.sublist(0, half);
    final rightDays = activeDays.sublist(half);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne de Gauche
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: leftDays.map((day) => _buildDayRow(day, groupedServices[day]!)).toList(),
          ),
        ),
        const SizedBox(width: 8),
        // Colonne de Droite
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightDays.map((day) => _buildDayRow(day, groupedServices[day]!)).toList(),
          ),
        ),
      ],
    );
  }

  // Sous-widget pour construire la ligne d'un jour spécifique
  Widget _buildDayRow(int dayOfWeek, List<RestaurantService> dayServices) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Le nom du jour
          SizedBox(
            width: 75,
            child: Text(
              _dayName(dayOfWeek),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Les horaires empilés
          Expanded(
            child: Text(
              dayServices
                  .map((service) => '${service.formattedStartTime} - ${service.formattedEndTime}')
                  .join(',\n'),
              style: TextStyle(color: Colors.grey[800], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }
}