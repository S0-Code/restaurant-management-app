import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c05/providers/reference_time_provider.dart';

import '../../models/restaurant_detail.dart';
import '../../providers/manager_reservations_provider.dart';
import 'restaurant_tables_page.dart';
import '../widgets/data_error_widget.dart';


import '../widgets/simulated_time_dialog.dart';
import 'reservation_details_manager_page.dart';

class RestaurantManagementPage extends ConsumerStatefulWidget {
  final RestaurantDetail restaurant;
  const RestaurantManagementPage({super.key, required this.restaurant});

  @override
  ConsumerState<RestaurantManagementPage> createState() => _RestaurantManagementPageState();
}

class _RestaurantManagementPageState extends ConsumerState<RestaurantManagementPage> {
  int _currentIndex = 0;
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final referenceTime = ref.watch(referenceTimeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.restaurant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(managerReservationsProvider(widget.restaurant.id)),
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => SimulatedTimeDialog(
                          referenceTime: referenceTime
                      )
                  );

                },
                child: Text(
                  DateFormat('EEE dd/MM/yyyy HH:mm', 'fr_FR').format(referenceTime),
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
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Réservations'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.table_restaurant), label: 'Tables'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) return _buildReservationsTab();
    if (_currentIndex == 1) return const Center(child: Text("Services (à venir)"));
    return RestaurantTablesPage(restaurantId: widget.restaurant.id);
  }

  Widget _buildReservationsTab() {
    final asyncReservations = ref.watch(managerReservationsProvider(widget.restaurant.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'all', icon: Icon(Icons.list), tooltip: 'Toutes'),
                ButtonSegment(value: 'pending', icon: Icon(Icons.pending, color: Colors.orange)),
                ButtonSegment(value: 'confirmed', icon: Icon(Icons.check_circle, color: Colors.green)),
                ButtonSegment(value: 'completed', icon: Icon(Icons.event_available, color: Colors.blue)),
                ButtonSegment(value: 'cancelled', icon: Icon(Icons.cancel, color: Colors.red)),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (newSelection) => setState(() => _selectedFilter = newSelection.first),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: asyncReservations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Erreur : $err', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(managerReservationsProvider(widget.restaurant.id)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (reservations) {
              // Filtrage en local côté client
              final filtered = _selectedFilter == 'all'
                  ? reservations
                  : reservations.where((r) => r.status.name == _selectedFilter).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFilter == 'all' ? "Aucune réservation" : "Aucune réservation ${_getStatusLabel(_selectedFilter)}",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      )
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final res = filtered[index];
                  final statusInfo = _getStatusInfo(res.status.name);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReservationDetailsManagerPage(reservation: res)),
                          );
                        },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32, height: 32,
                              child: Icon(statusInfo.icon, size: 32, color: statusInfo.color),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(res.clientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.restaurant, size: 16),
                                      const SizedBox(width: 4),
                                      Text(res.restaurantName, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('EEE dd/MM/yyyy à HH:mm', 'fr_FR').format(res.dateTime),
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.people, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${res.numberOfGuests} convives', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'en attente';
      case 'confirmed': return 'confirmée';
      case 'completed': return 'terminée';
      case 'cancelled': return 'annulée';
      default: return '';
    }
  }

  ({IconData icon, Color color}) _getStatusInfo(String status) {
    switch (status) {
      case 'pending': return (icon: Icons.pending, color: Colors.orange);
      case 'confirmed': return (icon: Icons.check_circle, color: Colors.green);
      case 'completed': return (icon: Icons.event_available, color: Colors.blue);
      case 'cancelled': return (icon: Icons.cancel, color: Colors.red);
      default: return (icon: Icons.help, color: Colors.grey);
    }
  }
}