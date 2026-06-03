import 'dart:convert';
import '../core/services/api_client.dart';

class RestaurantService {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  RestaurantService({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  // 1. TRADUCTEUR
  factory RestaurantService.fromJson(Map<String, dynamic> json) {
    return RestaurantService(
      id: json['id'] as int,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  // 2. READ
  static Future<List<RestaurantService>> getRestaurantServices(int restaurantId) async {
    final response = await ApiClient.post(
      'get_restaurant_services',
      body: json.encode({
        'p_restaurant_id': restaurantId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => RestaurantService.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des services : ${response.body}');
  }


  // READ (CLIENT)
  static Future<List<RestaurantService>> getPublicServices(int restaurantId) async {
    final response = await ApiClient.post(
      'get_public_restaurant_services',
      body: json.encode({'p_restaurant_id': restaurantId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => RestaurantService.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des horaires : ${response.body}');
  }

  // 3. CREATE
  static Future<void> create(int restaurantId, int dayOfWeek, String startTime, String endTime) async {
    final response = await ApiClient.post(
      'create_restaurant_service',
      body: json.encode({
        'p_restaurant_id': restaurantId,
        'p_day_of_week': dayOfWeek,
        'p_start_time': startTime,
        'p_end_time': endTime,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la création : ${response.body}');
    }
  }

  // 4. UPDATE
  static Future<void> update(int serviceId, int dayOfWeek, String startTime, String endTime) async {
    final response = await ApiClient.post(
      'update_restaurant_service',
      body: json.encode({
        'p_service_id': serviceId,
        'p_day_of_week': dayOfWeek,
        'p_start_time': startTime,
        'p_end_time': endTime,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la mise à jour : ${response.body}');
    }
  }

  // 5. DELETE
  static Future<void> delete(int serviceId) async {
    final response = await ApiClient.post(
      'delete_restaurant_service',
      body: json.encode({
        'p_service_id': serviceId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Impossible de supprimer : ${response.body}');
    }
  }

  // Helpers pour l'affichage (enlève les secondes retournées par PostgreSQL)
  String get formattedStartTime => startTime.substring(0, 5);
  String get formattedEndTime => endTime.substring(0, 5);
}