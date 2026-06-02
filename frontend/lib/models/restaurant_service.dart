import 'dart:convert';

import '../core/services/api_client.dart';

class RestaurantService {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  RestaurantService({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory RestaurantService.fromJson(Map<String, dynamic> json) {
    return RestaurantService(
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  static Future<List<RestaurantService>> getRestaurantServices(
      int restaurantId,
      ) async {
    final response = await ApiClient.post(
      'get_restaurant_services',
      body: json.encode({
        'p_restaurant': restaurantId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      return body
          .map((json) => RestaurantService.fromJson(json))
          .toList();
    }

    throw Exception('Failed to get restaurant services');
  }

  String get formattedStartTime {
    return startTime.substring(0, 5);
  }

  String get formattedEndTime {
    return endTime.substring(0, 5);
  }
}