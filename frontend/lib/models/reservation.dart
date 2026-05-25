import 'dart:convert';

import '../core/services/api_client.dart';

class Reservation {
  final int? id;
  final String restaurantName;
  final String cityName;
  final DateTime dateTime;
  final int numberOfGuests;
  final Status status;
  final String ?specialRequests;

  Reservation({
    this.id,
    required this.restaurantName,
    required this.cityName,
    required this.dateTime,
    required this.numberOfGuests,
    this.status = Status.pending,
    this.specialRequests,
  });

  static Future<List<Reservation>> getReservations() async {
    final response = await ApiClient.get("get_reservations");

    if (response.statusCode == 200) {

      final List<dynamic> body = json.decode(response.body);

      return body
          .map((json) => Reservation.fromJson(json))
          .toList();
    }

    throw Exception('Failed to get reservations : ${response.statusCode} ${response.body}');
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      restaurantName: json['restaurant_name'],
      cityName: json['city_name'],
      dateTime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'],
      status: Status.values.firstWhere(
            (status) => status.name == json['status'],
      ),
      specialRequests: json['special_requests'],
    );
  }


}
enum Status {
  pending,
  confirmed,
  cancelled,
  completed
}