import 'dart:convert';

import '../core/services/api_client.dart';

class RestaurantDetail {
  final int id;
  final String name;
  final String city;
  final String? address;
  final String? phone;
  final double? rating;
  final int? priceRange;
  final DateTime? lastReservationDate;
  final int pendingRequestsCount;
  final String? description;

  RestaurantDetail({
    required this.id,
    required this.name,
    required this.city,
    this.address,
    this.phone,
    this.rating,
    this.priceRange,
    this.lastReservationDate,
    required this.pendingRequestsCount,
    this.description,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      priceRange: json['price_range'] as int?,
      lastReservationDate: json['last_reservation_date'] != null
          ? DateTime.parse(json['last_reservation_date'])
          : null,
      pendingRequestsCount: json['pending_requests_count'] as int? ?? 0,
      description: json['description'] as String?,
    );
  }

  static Future<List<RestaurantDetail>> searchClientRestaurants({
    required String searchText,
    required int limit,
  }) async {
    final response = await ApiClient.post(
      'search_client_restaurants',
      body: json.encode({
        'p_search': searchText,
        'p_limit': limit,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      return body
          .map((json) => RestaurantDetail.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to search restaurants: ${response.statusCode} ${response.body}',
    );
  }
}