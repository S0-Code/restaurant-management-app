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
      home: const RestaurantManagementServicesMockupScreen(),
    ),
  );
}

class RestaurantManagementServicesMockupScreen extends StatelessWidget {
  const RestaurantManagementServicesMockupScreen({super.key});

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
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.grey[100],
                  child: ListTile(
                    leading: const Icon(Icons.schedule, color: Colors.grey),
                    title: Text(
                      'Lundi',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    subtitle: const Text(
                      'Aucun service',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Mardi'),
                    subtitle: const Text('12:00 - 14:00, 19:00 - 22:00'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                          tooltip: 'Supprimer le service',
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Mercredi'),
                    subtitle: const Text('12:00 - 14:00, 19:00 - 22:00'),
                    children: [
                      ListTile(
                        title: const Text('12:00 - 14:00'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {},
                              tooltip: 'Supprimer le service',
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: const Text('19:00 - 22:00'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey[400]),
                              onPressed: null,
                              tooltip:
                                  'Impossible de supprimer : des réservations non annulées utilisent ce service',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Jeudi'),
                    subtitle: const Text('12:00 - 14:00, 19:00 - 22:00'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                          tooltip: 'Supprimer le service',
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Vendredi'),
                    subtitle: const Text('12:00 - 14:00, 19:00 - 23:00'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                          tooltip: 'Supprimer le service',
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Samedi'),
                    subtitle: const Text('19:00 - 23:00'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                          tooltip: 'Supprimer le service',
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Dimanche'),
                    subtitle: const Text('12:00 - 14:00'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                          tooltip: 'Supprimer le service',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'services_fab',
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
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
