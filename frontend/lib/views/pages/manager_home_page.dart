import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/manager_state_provider.dart';
import '../../providers/security_provider.dart';
import '../widgets/data_error_widget.dart';
import '../widgets/restaurant_card.dart';

class ManagerHomePage extends ConsumerStatefulWidget {
  const ManagerHomePage({super.key});

  @override
  ConsumerState<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends ConsumerState<ManagerHomePage> {

  @override
  Widget build(BuildContext context) {
    final asyncManagerState = ref.watch(managerStateProvider);
    final managerStateNotifier = ref.read(managerStateProvider.notifier);
    final securityNotifier = ref.read(securityProvider.notifier);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes restaurants'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => managerStateNotifier.refresh(),
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
        child: asyncManagerState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => DataErrorWidget(
            error: err,
            stackTrace: StackTrace.current,
            notifier: managerStateNotifier,
            onGoToLogin: () async {
              ref.read(securityProvider.notifier).logout();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          data: (state) {
            final restaurants = state.sortedRestaurants;

            if (restaurants.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Aucun restaurant n'est géré",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Veuillez contacter un administrateur pour être assigné à un restaurant.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: restaurants
                  .map((r) => RestaurantCard(restaurant: r, simulatedTime: simulatedTime))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

}
