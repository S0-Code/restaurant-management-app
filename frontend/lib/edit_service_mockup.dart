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
      home: const EditServiceMockupScreen(),
    ),
  );
}

class EditServiceMockupScreen extends StatelessWidget {
  const EditServiceMockupScreen({super.key});

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
        title: const Text('Modifier le service'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: () {},
            icon: const Icon(Icons.save),
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
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: 'Mercredi',
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Lundi', child: Text('Lundi')),
                    DropdownMenuItem(value: 'Mardi', child: Text('Mardi')),
                    DropdownMenuItem(value: 'Mercredi', child: Text('Mercredi')),
                    DropdownMenuItem(value: 'Jeudi', child: Text('Jeudi')),
                    DropdownMenuItem(value: 'Vendredi', child: Text('Vendredi')),
                    DropdownMenuItem(value: 'Samedi', child: Text('Samedi')),
                    DropdownMenuItem(value: 'Dimanche', child: Text('Dimanche')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: 19,
                        decoration: const InputDecoration(
                          labelText: 'Heure de début (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: 0,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(value: 0, child: const Text('00 min')),
                          DropdownMenuItem<int?>(value: 15, child: const Text('15 min')),
                          DropdownMenuItem<int?>(value: 30, child: const Text('30 min')),
                          DropdownMenuItem<int?>(value: 45, child: const Text('45 min')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: 22,
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: 0,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(value: 0, child: const Text('00 min')),
                          DropdownMenuItem<int?>(value: 15, child: const Text('15 min')),
                          DropdownMenuItem<int?>(value: 30, child: const Text('30 min')),
                          DropdownMenuItem<int?>(value: 45, child: const Text('45 min')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
