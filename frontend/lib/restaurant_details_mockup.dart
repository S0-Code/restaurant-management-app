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
      home: const RestaurantDetailsMockupScreen(),
    ),
  );
}

class RestaurantDetailsMockupScreen extends StatelessWidget {
  const RestaurantDetailsMockupScreen({super.key});

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
        title: const Text('Détails du restaurant'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Le Gourmet',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(4.5.toStringAsFixed(1)),
                  const SizedBox(width: 16),
                  Text('€' * 3),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  const Text('Bruxelles'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Rue de la Paix 12',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Restaurant gastronomique français'),
              const SizedBox(height: 24),
              const Text(
                'Horaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Lundi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '12:00 - 14:00, 19:00 - 22:00',
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Mardi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '12:00 - 14:00, 19:00 - 22:00',
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Mercredi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '12:00 - 14:00, 19:00 - 22:00',
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Jeudi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '12:00 - 14:00, 19:00 - 22:00',
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Vendredi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '12:00 - 14:00, 19:00 - 23:00',
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Samedi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '19:00 - 23:00',
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Dimanche',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '12:00 - 14:00',
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
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
