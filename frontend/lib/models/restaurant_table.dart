import 'dart:convert';
import '../core/services/api_client.dart';

class RestaurantTable {
  final int id;
  final int restaurantId;
  final int tableNumber;
  final int capacity;

  RestaurantTable({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.capacity,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as int,
      restaurantId: json['restaurant'] as int,
      tableNumber: json['table_number'] as int,
      capacity: json['capacity'] as int,
    );
  }

  // 1. READ : Appel fonction SQL
  static Future<List<RestaurantTable>> getForRestaurant(int restaurantId) async {
    final response = await ApiClient.post(
      'get_restaurant_tables',
      body: json.encode({'p_restaurant_id': restaurantId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RestaurantTable.fromJson(json)).toList();
    }
    throw Exception('Erreur API (${response.statusCode}): ${response.body}');
  }

  // 2. CREATE
  static Future<void> create(int restaurantId, int tableNumber, int capacity) async {
    final response = await ApiClient.post(
      'create_restaurant_table',
      body: json.encode({
        'p_restaurant_id': restaurantId,
        'p_table_number': tableNumber,
        'p_capacity': capacity,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur API : ${response.body}');
    }
  }

  // 3. UPDATE
  static Future<void> update(int id, int tableNumber, int capacity) async {
    final response = await ApiClient.post(
      'update_restaurant_table',
      body: json.encode({
        'p_table_id': id,
        'p_table_number': tableNumber,
        'p_capacity': capacity,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur API : ${response.body}');
    }
  }
}