import 'dart:convert';
import '../core/services/api_client.dart';
import 'reservation.dart';

class ManagerReservation {
  final int id;
  final String clientName;
  final String restaurantName;
  final DateTime dateTime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;

  ManagerReservation({
    required this.id,
    required this.clientName,
    required this.restaurantName,
    required this.dateTime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
  });

  factory ManagerReservation.fromJson(Map<String, dynamic> json) {
    return ManagerReservation(
      id: json['id'] as int,
      clientName: json['client_name'] as String,
      restaurantName: json['restaurant_name'] as String,
      dateTime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'] as int,
      status: Status.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => Status.pending,
      ),
      specialRequests: json['special_requests'] as String?,
    );
  }

  static Future<List<ManagerReservation>> getForRestaurant(int restaurantId) async {
    final response = await ApiClient.post(
      'get_manager_restaurant_reservations',
      body: json.encode({'p_restaurant_id': restaurantId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => ManagerReservation.fromJson(json)).toList();
    }
    throw Exception('Erreur API: ${response.statusCode} ${response.body}');
  }
}