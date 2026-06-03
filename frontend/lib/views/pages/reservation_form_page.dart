import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/reservation_slot.dart';
import '../../providers/client_state.dart';
import '../../providers/client_state_provider.dart';
import '../../providers/reference_time_provider.dart';

class ReservationFormPage extends ConsumerWidget {
  const ReservationFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final referenceTime = ref.watch(referenceTimeProvider);
    final asyncClientState = ref.watch(clientStateProvider);
    final clientStateNotifier = ref.read(clientStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle réservation'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              clientStateNotifier.loadReservationSlots();
            },
          ),
        ],
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(referenceTime),
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
      body: asyncClientState.when(
        data: (clientState) => _data(
          context,
          clientState,
          clientStateNotifier,
          isLoading: false,
        ),
        loading: () => _data(
          context,
          asyncClientState.value ?? ClientState(reservations: []),
          clientStateNotifier,
          isLoading: true,
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              error.toString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _data(
      BuildContext context,
      ClientState clientState,
      ClientStateNotifier clientStateNotifier, {
        required bool isLoading,
      }) {
    final restaurant = clientState.currentRestaurant;
    final selectedDate = clientState.newReservationDate;
    final selectedSlot = clientState.selectedReservationSlot;
    final slots = clientState.reservationSlots;
    final theme = Theme.of(context);

    if (restaurant == null) {
      return const Center(
        child: Text('Aucun restaurant sélectionné.'),
      );
    }

    if (selectedDate == null) {
      return const Center(
        child: Text('Aucune date sélectionnée.'),
      );
    }

    final specialRequests =
    clientState.newReservationSpecialRequests.trim();

    final isSpecialRequestsValid =
        specialRequests.isEmpty || specialRequests.length >= 10;

    final hasOverbookingWarning =
        selectedSlot != null && !selectedSlot.hasEnoughCapacity;

    final canCreate =
        selectedSlot != null &&
            isSpecialRequestsValid &&
            !clientState.isLoadingReservationSlots &&
            !isLoading;

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                _DateSelector(
                  selectedDate: selectedDate,
                  onPrevious: () {
                    clientStateNotifier.previousReservationDate();
                  },
                  onNext: () {
                    clientStateNotifier.nextReservationDate();
                  },
                ),

                const Divider(height: 32),

                Text(
                  'Créneaux disponibles',
                  style: theme.textTheme.titleLarge,
                ),

                const SizedBox(height: 16),

                if (clientState.isLoadingReservationSlots)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (slots.isEmpty)
                  const _WarningBox(
                    icon: Icons.info_outline,
                    title: 'Aucun créneau disponible',
                    message:
                    'Le restaurant est fermé ce jour-là ou vous avez déjà une réservation couvrant tous les services de cette date.',
                  )
                else
                  _SlotsGrid(
                    slots: slots,
                    selectedSlot: selectedSlot,
                    onSelected: clientStateNotifier.setSelectedReservationSlot,
                  ),

                const SizedBox(height: 40),

                _GuestsSelector(
                  guests: clientState.newReservationGuests,
                  onMinus: () {
                    clientStateNotifier.setNewReservationGuests(
                      clientState.newReservationGuests - 1,
                    );
                  },
                  onPlus: () {
                    clientStateNotifier.setNewReservationGuests(
                      clientState.newReservationGuests + 1,
                    );
                  },
                ),

                if (hasOverbookingWarning) ...[
                  const SizedBox(height: 24),
                  const _WarningBox(
                    icon: Icons.warning_amber_rounded,
                    title: 'Surréservation',
                    message:
                    'La capacité disponible semble insuffisante pour ce créneau et ce nombre de convives. La réservation peut être envoyée, mais elle devra être validée par le restaurant.',
                  ),
                ],

                const SizedBox(height: 40),

                TextField(
                  minLines: 3,
                  maxLines: 5,
                  onChanged:
                  clientStateNotifier.setNewReservationSpecialRequests,
                  decoration: InputDecoration(
                    labelText: 'Demandes spéciales (optionnel)',
                    hintText: 'Allergies, préférences, chaise bébé...',
                    border: const OutlineInputBorder(),
                    errorText: isSpecialRequestsValid
                        ? null
                        : 'Minimum 10 caractères ou laissez vide.',
                  ),
                ),

                const SizedBox(height: 40),

                FilledButton.icon(
                  onPressed: canCreate
                      ? () async {
                    try {
                      await clientStateNotifier.createReservation();

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Réservation créée avec succès.',
                          ),
                        ),
                      );

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/clientHome',
                            (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erreur lors de la création : $e',
                          ),
                        ),
                      );
                    }
                  }
                      : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer la réservation'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _DateSelector({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
    DateFormat('EEEE d/MM/yyyy', 'fr_FR').format(selectedDate);

    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 32),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                _capitalize(formattedDate),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.remove),
          tooltip: 'Jour précédent',
        ),
        IconButton.filledTonal(
          onPressed: onNext,
          icon: const Icon(Icons.add),
          tooltip: 'Jour suivant',
        ),
      ],
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1);
  }
}

class _SlotsGrid extends StatelessWidget {
  final List<ReservationSlot> slots;
  final ReservationSlot? selectedSlot;
  final void Function(ReservationSlot slot) onSelected;

  const _SlotsGrid({
    required this.slots,
    required this.selectedSlot,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots.map((slot) {
        final isSelected =
            selectedSlot?.slotDateTime == slot.slotDateTime;

        return SizedBox(
          width: 90,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              onSelected(slot);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor:
              isSelected ? theme.colorScheme.primary : null,
              foregroundColor:
              isSelected ? theme.colorScheme.onPrimary : null,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey,
              ),
            ),
            child: Text(
              slot.slotTime,
              style: TextStyle(
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GuestsSelector extends StatelessWidget {
  final int guests;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _GuestsSelector({
    required this.guests,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.people, size: 32),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombre de convives',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                '$guests',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: guests > 1 ? onMinus : null,
          icon: const Icon(Icons.remove),
          tooltip: 'Retirer un convive',
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add),
          tooltip: 'Ajouter un convive',
        ),
      ],
    );
  }
}

class _WarningBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _WarningBox({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.orange[800],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}