import '../models/restaurant.dart';
import '../core/services/api_client.dart';
import 'dart:convert';

class ManagerState {
  final List<Restaurant> restaurants;

  ManagerState({required this.restaurants});

  List<Restaurant> get sortedRestaurants {
    final sorted = List<Restaurant>.from(restaurants);
    sorted.sort((a, b) {
      final dateA = a.lastReservationDate;
      final dateB = b.lastReservationDate;

      // Tri par date décroissante
      if (dateA != null && dateB != null) {
        int dateCmp = dateB.compareTo(dateA);
        if (dateCmp != 0) return dateCmp;
      } else if (dateA != null) return -1;
      else if (dateB != null) return 1;

      // Sinon tri alphabétique
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  static Future<ManagerState> getManagerState() async {
    final response = await ApiClient.get("get_my_restaurants");
    if (response.statusCode != 200) throw Exception("Erreur API: ${response.body}");

    final List<dynamic> body = json.decode(response.body);
    final list = body.map((json) => Restaurant.fromJson(json)).toList();
    return ManagerState(restaurants: list);
  }
}