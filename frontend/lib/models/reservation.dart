import 'dart:convert';

import '../core/services/api_client.dart';

class Reservation {
  int? id;
  int clientId;
  int restaurantId;
  String dateTime;
  int numberOfGuests;
  Status status = Status.pending;
  String ?specialRequests;

  Reservation({
    this.id,
    required this.clientId,
    required this.restaurantId,
    required this.dateTime,
    required this.numberOfGuests,
    this.status = Status.pending,
    this.specialRequests,
  });

  static Future<List<Reservation>> getReservations() async {
    final response = await ApiClient.get("reservations");

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      return body
          .map((json) => Reservation.fromJson(json))
          .toList();
    }

    throw Exception('Failed to get reservations');
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      clientId: json['client'],
      restaurantId: json['restaurant'],
      dateTime: json['datetime'],
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