import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/manager_reservation.dart';
import '../../models/reservation.dart';

class ReservationDetailsManagerPage extends StatelessWidget {
  final ManagerReservation reservation;

  const ReservationDetailsManagerPage({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
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
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations client',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 8),
                          Text('Nom: ${reservation.clientName}'),
                        ],
                      ),
                      // Note : Email et Téléphone ne sont pas encore dans ManagerReservation.
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20),
                          const SizedBox(width: 8),
                          Text('Email: Non renseigné', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20),
                          const SizedBox(width: 8),
                          Text('Téléphone: Non renseigné', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détails de la réservation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reservation.restaurantName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text('Date: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(reservation.dateTime)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text('Heure: ${DateFormat('HH:mm').format(reservation.dateTime)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          Text('Nombre de convives: ${reservation.numberOfGuests}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          const Text('Statut: '),
                          _buildStatusChip(reservation.status.name),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Demandes spéciales',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.specialRequests != null && reservation.specialRequests!.isNotEmpty
                            ? reservation.specialRequests!
                            : 'Aucune demande spéciale',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cette partie reste statique pour le moment jusqu'à ce que l'assignation de tables soit développée
              const Text('Tables assignées (À venir)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Gestion des tables en cours de développement...", style: TextStyle(color: Colors.grey[600])),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle),
                label: const Text('Marquer comme terminée'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cancel),
                label: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = Colors.orange;
        label = 'En attente';
        break;
      case 'confirmed':
        bgColor = Colors.green;
        label = 'Confirmée';
        break;
      case 'completed':
        bgColor = Colors.blue;
        label = 'Terminée';
        break;
      case 'cancelled':
        bgColor = Colors.red;
        label = 'Annulée';
        break;
      default:
        bgColor = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      backgroundColor: bgColor,
      padding: EdgeInsets.zero,
    );
  }
}