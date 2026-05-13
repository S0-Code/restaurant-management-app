import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RestaurantManagementReservationsMockupScreen(),
    ),
  );
}

class RestaurantManagementReservationsMockupScreen extends StatelessWidget {
  const RestaurantManagementReservationsMockupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Le Gourmet'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: const {'all'},
                onSelectionChanged: (_) {},
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(Icons.pending, size: 32, color: Colors.orange),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bruno Lacroix',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.restaurant, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Le Gourmet',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'dim. 24/11/2024 12:30',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.people, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '2 convives',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
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
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(Icons.check_circle, size: 32, color: Colors.green),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Marc Michel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.restaurant, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Le Gourmet',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'mer. 04/12/2024 12:30',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.people, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '2 convives',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Tables',
          ),
        ],
      ),
    );
  }
}
