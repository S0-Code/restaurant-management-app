import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/api_client.dart';
import '../core/tools/abstract_async_notifier.dart';
import '../models/restaurant_detail.dart';

final myRestaurantsProvider = AsyncNotifierProvider.autoDispose<MyRestaurantsNotifier, List<RestaurantDetail>>(
      () => MyRestaurantsNotifier(),
);

class MyRestaurantsNotifier extends AbstractAsyncNotifier<List<RestaurantDetail>> {
  @override
  Future<List<RestaurantDetail>> build() async {
    return _fetchRestaurants();
  }

  Future<List<RestaurantDetail>> _fetchRestaurants() async {
    final response = await ApiClient.get('get_my_restaurants');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RestaurantDetail.fromJson(json)).toList();
    }
    throw Exception('Erreur chargement restaurants: ${response.statusCode}');
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchRestaurants);
  }
}