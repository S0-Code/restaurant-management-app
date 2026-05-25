import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_c05/providers/client_state.dart';
import 'package:prbd_2526_c05/providers/client_state_provider.dart';
import '../../models/reservation.dart';
import '../../providers/security_provider.dart';
import '../widgets/data_error_widget.dart';
import '../widgets/reservation_card.dart';


class ClientHomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  @override
  Widget build(BuildContext context) {
    final asyncClientState = ref.watch(clientStateProvider);
    final clientStateNotifier = ref.read(clientStateProvider.notifier);


    return asyncClientState.when(
      data: (clientState) => data(context, clientState, clientStateNotifier),
      error: (err, _) => DataErrorWidget(
        error: err,
        stackTrace: StackTrace.current,
        notifier: clientStateNotifier,
        onGoToLogin: () async {
          ref.read(securityProvider.notifier).logout();

          if (!context.mounted) return;

          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      loading: () => data(
        context,
        asyncClientState.value ?? ClientState(reservations: []),
        clientStateNotifier,
        isLoading: true,
      ),
    );
  }

  Widget data(
      BuildContext context,
      ClientState clientState,
      ClientStateNotifier notifier, {
        isLoading = false
      }
      ) {
    final securityNotifier = ref.read(securityProvider.notifier);
    final theme = Theme.of(context);
    final reservations = clientState.filteredReservations;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              notifier.refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              securityNotifier.logout();
              Navigator.pushReplacementNamed(context, '/login');
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
                child: Text(
                  'mercredi 04/12/2024 16:00',
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
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: SegmentedButton<ReservationsFilter>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ReservationsFilter.all,
                        icon: Icon(Icons.list, size: 24),
                        tooltip: 'Toutes',
                      ),
                      ButtonSegment(
                        value: ReservationsFilter.pending,
                        icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                        tooltip: 'En attente',
                      ),
                      ButtonSegment(
                        value: ReservationsFilter.confirmed,
                        icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                        tooltip: 'Confirmées',
                      ),
                      ButtonSegment(
                        value: ReservationsFilter.completed,
                        icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                        tooltip: 'Terminées',
                      ),
                      ButtonSegment(
                        value: ReservationsFilter.cancelled,
                        icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                        tooltip: 'Annulées',
                      ),
                    ],
                    selected: {clientState.reservationsFilter},
                    onSelectionChanged: (selection) {
                      setState(() {
                        notifier.setReservationsFilter(selection.first);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: reservations.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _emptyMessage(clientState.reservationsFilter),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: reservations
                        .map(
                          (reservation) =>
                          ReservationCard(reservation: reservation),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }

  String _emptyMessage(ReservationsFilter filter) {
    switch (filter) {
      case ReservationsFilter.all:
        return 'Aucune réservation';

      case ReservationsFilter.pending:
        return 'Aucune réservation en attente';

      case ReservationsFilter.confirmed:
        return 'Aucune réservation confirmée';

      case ReservationsFilter.completed:
        return 'Aucune réservation terminée';

      case ReservationsFilter.cancelled:
        return 'Aucune réservation annulée';
    }
  }


}
