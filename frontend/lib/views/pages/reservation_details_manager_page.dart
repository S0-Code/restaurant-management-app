import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c05/providers/reference_time_provider.dart';

import '../../models/manager_reservation.dart';
import '../../models/reservation.dart';
import '../../providers/manager_reservations_provider.dart';
import '../widgets/simulated_time_dialog.dart';
import 'assign_tables_page.dart';
import '../../providers/my_restaurants_provider.dart';

class ReservationDetailsManagerPage extends ConsumerStatefulWidget {
  final ManagerReservation reservation;

  const ReservationDetailsManagerPage({super.key, required this.reservation});

  @override
  ConsumerState<ReservationDetailsManagerPage> createState() => _ReservationDetailsManagerPageState();
}

class _ReservationDetailsManagerPageState extends ConsumerState<ReservationDetailsManagerPage> {
  // 1. Notre état local qui peut être modifié
  late ManagerReservation _reservation;

  @override
  void initState() {
    super.initState();
    // On initialise l'état avec la réservation passée en paramètre
    _reservation = widget.reservation;
  }

  Future<void> _handleStatusAction(
      BuildContext context,
      String newStatus,
      String title,
      String content,
      ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ManagerReservation.updateStatus(_reservation.id, newStatus);

        // Rafraîchir les données en arrière-plan pour les autres écrans
        ref.invalidate(managerReservationsProvider(_reservation.restaurantId));

        // rafraîchir les compteurs de la page d'accueil
        ref.invalidate(myRestaurantsProvider);

        // 2. Mettre à jour l'écran actuel en direct
        setState(() {
          _reservation = _reservation.copyWith(
            status: Status.values.firstWhere((e) => e.name == newStatus),
            // Si on annule, on vide visuellement les tables (comme le fait le backend)
            assignedTables: newStatus == 'cancelled' ? [] : _reservation.assignedTables,
          );
        });

        // 3. Afficher le feedback sans quitter la page
        if (context.mounted) {
          String message;
          if (newStatus == 'cancelled') {
            message = 'Réservation annulée avec succès';
          } else if (newStatus == 'completed') {
            message = 'Réservation marquée comme terminée';
          } else {
            message = 'Réservation mise à jour avec succès';
          }

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: newStatus == 'cancelled' ? Colors.grey[900] : Colors.blue,
              )
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

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
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
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
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => SimulatedTimeDialog(referenceTime: referenceTime)
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 8),
                          Text('Nom: ${_reservation.clientName}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20),
                          const SizedBox(width: 8),
                          Text('Email: ${_reservation.clientEmail}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Téléphone: ${_reservation.clientPhone ?? "Non renseigné"}',
                            style: TextStyle(
                              color: _reservation.clientPhone == null ? Colors.grey[600] : null,
                            ),
                          ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _reservation.restaurantName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                          Text(
                            'Date: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(_reservation.dateTime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Heure: ${DateFormat('HH:mm').format(_reservation.dateTime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Nombre de convives: ${_reservation.numberOfGuests}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          const Text('Statut: '),
                          _buildStatusChip(_reservation.status.name),
                        ],
                      ),
                      if (_reservation.specialRequests != null &&
                          _reservation.specialRequests!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Demandes spéciales',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _reservation.specialRequests!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Tables assignées',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_reservation.assignedTables.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _reservation.status == Status.cancelled
                          ? "Aucune table assignée"
                          : "Aucune table assignée (en attente de confirmation)",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _reservation.assignedTables.map((table) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.table_restaurant, size: 20),
                              const SizedBox(width: 8),
                              Text('Table ${table.tableNumber}'),
                              const SizedBox(width: 16),
                              Text(
                                '(${table.capacity} places)',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),

              // Boutons d'actions conditionnels selon le statut
              if (_reservation.status == Status.pending) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignTablesPage(reservation: _reservation),
                      ),
                    );
                  },
                  icon: const Icon(Icons.table_restaurant),
                  label: const Text('Confirmer et assigner tables'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _handleStatusAction(
                    context,
                    'cancelled',
                    'Annuler la réservation',
                    'Êtes-vous sûr de vouloir annuler cette réservation ?',
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler'),
                ),
              ] else if (_reservation.status == Status.confirmed) ...[
                // Vérification du temps : est-ce que referenceTime est AVANT la réservation ?
                if (referenceTime.isBefore(_reservation.dateTime)) ...[
                  ElevatedButton.icon(
                    onPressed: null,
                    // null désactive visuellement le bouton (le grise)
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Marquer comme terminée'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'La réservation ne peut être terminée que durant son service ou après celui-ci',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  // Si le temps est passé ou actuel, le bouton est actif
                  ElevatedButton.icon(
                    onPressed: () => _handleStatusAction(
                      context,
                      'completed',
                      'Terminer la réservation',
                      'Voulez-vous marquer cette réservation comme terminée ?',
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Marquer comme terminée'),
                  ),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _handleStatusAction(
                    context,
                    'cancelled',
                    'Annuler la réservation',
                    'Êtes-vous sûr de vouloir annuler cette réservation ?',
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler'),
                ),
              ],
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
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: bgColor,
      padding: EdgeInsets.zero,
    );
  }
}