import 'dart:convert';

import 'package:intl/intl.dart';

import '../core/services/api_client.dart';
import 'reservation_slot.dart';

class Reservation {
  final int? id;
  final int clientId;
  final int restaurantId;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantPhone;
  final String cityName;
  final DateTime dateTime;
  final int numberOfGuests;
  final Status status;
  final String ?specialRequests;

  Reservation({
    this.id,
    required this.clientId,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantPhone,
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

  bool needsEditConfirmation(DateTime currentTime) {
    return status == Status.confirmed && dateTime.isAfter(currentTime);
  }

  bool canBeModified(DateTime currentTime) {
    return (status == Status.pending || status == Status.confirmed)
        && dateTime.isAfter(currentTime);
  }

  bool canBeCancelled(DateTime currentTime) {
    return (status == Status.pending || status == Status.confirmed)
        && dateTime.isAfter(currentTime);
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      clientId: json['client_id'],
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'],
      restaurantAddress: json['restaurant_address'],
      restaurantPhone: json['restaurant_phone'],
      specialRequests: json['special_requests'],
      cityName: json['city_name'],
      dateTime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'],
      status: Status.values.firstWhere(
            (status) => status.name == json['status'],
      ),
    );
  }


  static Future<List<ReservationSlot>> getReservationSlots({
    required int restaurantId,
    required DateTime date,
    required int numberOfGuests,
    int? ignoredReservationId,
  }) async {
    final response = await ApiClient.post(
      'get_client_reservation_slots',
      body: json.encode({
        'p_restaurant': restaurantId,
        'p_date': DateFormat('yyyy-MM-dd').format(date),
        'p_number_of_guests': numberOfGuests,
        'p_ignored_reservation': ignoredReservationId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      return body
          .map((json) => ReservationSlot.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to get reservation slots : ${response.statusCode} ${response.body}',
    );
  }

  static Future<Reservation> createReservation({
    required int restaurantId,
    required DateTime dateTime,
    required int numberOfGuests,
    String? specialRequests,
  }) async {
    final response = await ApiClient.post(
      'create_client_reservation',
      body: json.encode({
        'p_restaurant': restaurantId,
        'p_datetime': dateTime.toIso8601String(),
        'p_number_of_guests': numberOfGuests,
        'p_special_requests': specialRequests,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return Reservation.fromJson(body);
    }

    throw Exception(
      'Failed to create reservation : ${response.statusCode} ${response.body}',
    );
  }



  static Future<Reservation> updateReservation({
    required int reservationId,
    required DateTime dateTime,
    required int numberOfGuests,
    String? specialRequests,
  }) async {
    final response = await ApiClient.post(
      'update_client_reservation',
      body: json.encode({
        'p_reservation': reservationId,
        'p_datetime': dateTime.toIso8601String(),
        'p_number_of_guests': numberOfGuests,
        'p_special_requests': specialRequests,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return Reservation.fromJson(body);
    }

    throw Exception(
      'Failed to update reservation : ${response.statusCode} ${response.body}',
    );
  }


  static Future<Reservation> cancelReservation({
    required int reservationId,
  }) async {
    final response = await ApiClient.post(
      'cancel_client_reservation',
      body: json.encode({
        'p_reservation': reservationId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return Reservation.fromJson(body);
    }

    throw Exception(
      'Failed to cancel reservation : ${response.statusCode} ${response.body}',
    );
  }


}
enum Status {
  pending,
  confirmed,
  cancelled,
  completed
}