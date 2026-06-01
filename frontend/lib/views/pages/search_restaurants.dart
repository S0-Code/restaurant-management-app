import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/client_state_provider.dart';
import '../../providers/reference_time_provider.dart';
import '../widgets/restaurant_search_card.dart';

class SearchRestaurantsView extends ConsumerStatefulWidget {
  const SearchRestaurantsView({super.key});

  @override
  ConsumerState<SearchRestaurantsView> createState() =>
      _SearchRestaurantsScreenState();
}

class _SearchRestaurantsScreenState
    extends ConsumerState<SearchRestaurantsView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(clientStateProvider.notifier).searchRestaurants('');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncClientState = ref.watch(clientStateProvider);
    final notifier = ref.read(clientStateProvider.notifier);
    final simulatedTime = ref.watch(referenceTimeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Rechercher un restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les résultats',
            onPressed: () {
              notifier.searchRestaurants(_searchController.text);
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
        child: asyncClientState.when(
          data: (clientState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher par nom, ville, description...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();

                      _debounce = Timer(const Duration(milliseconds: 600), () {
                        ref.read(clientStateProvider.notifier).searchRestaurants(value);
                      });
                    },
                  ),
                ),

                if (clientState.hasTooManyRestaurantResults)
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
                  child: clientState.restaurants.isEmpty
                      ? const Center(
                    child: Text('Aucun restaurant trouvé.'),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: clientState.restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant =
                      clientState.restaurants[index];

                      return RestaurantSearchCard(
                        restaurant: restaurant,
                        simulatedTime: simulatedTime,
                        onTap: () {
                          notifier.setCurrentRestaurant(restaurant);
                          Navigator.pushNamed(
                            context,
                            '/clientViewRestaurant',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}