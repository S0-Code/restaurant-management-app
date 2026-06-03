import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c05/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_c05/models/reservation.dart';
import 'package:prbd_2526_c05/views/widgets/data_error_widget.dart';
import 'package:prbd_2526_c05/views/widgets/simulated_time_dialog.dart';

import '../../providers/client_state_provider.dart';
import '../../providers/reference_time_provider.dart';
import '../../providers/simulated_time_provider.dart';


class ClientViewReservation extends ConsumerWidget {
  const ClientViewReservation({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final clientState = ref.watch(clientStateProvider);
    final referenceTime = ref.watch(referenceTimeProvider);
    return clientState.when(
      data: (state) {
        final reservation = state.currentReservation;

        if (reservation == null) {
          return const Scaffold(
            body: Center(
              child: Text('Aucune réservation sélectionnée'),
            ),
          );
        }


        return viewReservationWidget(
            context,
            reservation,
            referenceTime,
            ref.read(clientStateProvider.notifier),
            ref
        );
      },
      loading: () => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
      error: (error, stack) => Scaffold(
          body: DataErrorWidget(
            error: error,
            stackTrace: stack,
            notifier: ref.read(clientStateProvider.notifier)
        ),
      ),
    );


  }

  Widget viewReservationWidget(
      BuildContext context,
      Reservation reservation,
      DateTime referenceTime,
      AbstractAsyncNotifier notifier,
      WidgetRef ref) {
    final theme = Theme.of(context);
    final formattedDate =
    DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(reservation.dateTime);
    final formattedHour = DateFormat('HH:mm').format(reservation.dateTime);
    final canModify = reservation.canBeModified(referenceTime);
    final canCancel = reservation.canBeCancelled(referenceTime);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              notifier.refresh();
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
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reservation.restaurantName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${reservation.restaurantAddress}, ${reservation.cityName}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            reservation.restaurantPhone,
                            style: TextStyle(color: Colors.grey[600]),
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
                            'Date: $formattedDate',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text('Heure: $formattedHour'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          Text('Nombre de convives: ${reservation
                              .numberOfGuests}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          const Text('Statut: '),
                          Chip(
                            label: Text(
                              _statusLabel(reservation.status),
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            backgroundColor: _statusColor(reservation.status),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
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
                        reservation.specialRequests ??
                            'Aucune demande spéciale',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canModify ? () async {
                        await ref.read(clientStateProvider.notifier).prepareEditReservation();

                        if (!context.mounted) return;

                        Navigator.pushNamed(context, '/clientEditReservation');
                      } : null,
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canCancel
                          ? () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Annuler la réservation'),
                              content: const Text(
                                'Êtes-vous sûr de vouloir annuler cette réservation ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text('Non'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Oui'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed != true) return;

                        try {
                          await ref.read(clientStateProvider.notifier).cancelReservation();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Réservation annulée avec succès'),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                          : null,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Annuler'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(Status status) {
    switch (status) {
      case Status.pending:
        return Colors.orange;
      case Status.confirmed:
        return Colors.green;
      case Status.cancelled:
        return Colors.red;
      case Status.completed:
        return Colors.blue;
    }
  }

  String _statusLabel(Status status) {
    switch (status) {
      case Status.pending:
        return 'En attente';
      case Status.confirmed:
        return 'Confirmée';
      case Status.cancelled:
        return 'Annulée';
      case Status.completed:
        return 'Terminée';
    }
  }

}
