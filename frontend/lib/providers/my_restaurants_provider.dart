import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/api_client.dart';
import '../core/tools/abstract_async_notifier.dart';
import '../models/restaurant.dart';

final myRestaurantsProvider = AsyncNotifierProvider.autoDispose<MyRestaurantsNotifier, List<Restaurant>>(
      () => MyRestaurantsNotifier(),
);

class MyRestaurantsNotifier extends AbstractAsyncNotifier<List<Restaurant>> {
  @override
  Future<List<Restaurant>> build() async {
    return _fetchRestaurants();
  }

  Future<List<Restaurant>> _fetchRestaurants() async {
    final response = await ApiClient.get('get_my_restaurants');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    }
    throw Exception('Erreur chargement restaurants: ${response.statusCode}');
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchRestaurants);
  }
}