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
      home: const SearchRestaurantsMockupScreen(),
    ),
  );
}

class SearchRestaurantsMockupScreen extends StatelessWidget {
  const SearchRestaurantsMockupScreen({super.key});

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
        title: const Text('Rechercher un restaurant'),
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
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom, ville, description...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {},
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    color: Colors.orange.shade50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Trop de résultats trouvés. Veuillez affiner votre recherche pour voir plus de restaurants.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, size: 40),
                      title: const Text('Le Gourmet'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text('Bruxelles'),
                              const SizedBox(width: 12),
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '4.5',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '€€€',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Aujourd\'hui à 12:30',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, size: 40),
                      title: const Text('La Trattoria'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text('Bruxelles'),
                              const SizedBox(width: 12),
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '4.2',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '€€',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Dernière réservation: jeu. 28/11/2024',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.pending,
                                  size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                '1 demande en attente',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, size: 40),
                      title: const Text('Sushi House'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text('Bruxelles'),
                              const SizedBox(width: 12),
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '4.7',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '€€€',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Dernière réservation: mar. 26/11/2024',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, size: 40),
                      title: const Text('Bistrot du port'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text('Anvers'),
                              const SizedBox(width: 12),
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '4.3',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '€€',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Dernière réservation: ven. 29/11/2024',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.pending,
                                  size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                '1 demande en attente',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, size: 40),
                      title: const Text('Le Bistrot Flamand'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text('Gand'),
                              const SizedBox(width: 12),
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '4.4',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '€€',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Dernière réservation: sam. 30/11/2024',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
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
      ),
    );
  }
}
