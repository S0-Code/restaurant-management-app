import 'dart:convert';
import '../core/services/api_client.dart';
import 'reservation.dart';

class AssignedTable {
  final int tableNumber;
  final int capacity;

  AssignedTable({required this.tableNumber, required this.capacity});

  factory AssignedTable.fromJson(Map<String, dynamic> json) {
    return AssignedTable(
      tableNumber: json['table_number'] as int,
      capacity: json['capacity'] as int,
    );
  }
}

class ManagerReservation {
  final int id;
  final int restaurantId;
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final String restaurantName;
  final DateTime dateTime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  final List<AssignedTable> assignedTables;

  ManagerReservation({
    required this.id,
    required this.restaurantId,
    required this.clientName,
    required this.clientEmail,
    this.clientPhone,
    required this.restaurantName,
    required this.dateTime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
    required this.assignedTables,
  });

  factory ManagerReservation.fromJson(Map<String, dynamic> json) {
    return ManagerReservation(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      clientName: json['client_name'] as String,
      clientEmail: json['client_email'] as String,
      clientPhone: json['client_phone'] as String?,
      restaurantName: json['restaurant_name'] as String,
      dateTime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'] as int,
      status: Status.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => Status.pending,
      ),
      specialRequests: json['special_requests'] as String?,
      assignedTables: (json['assigned_tables'] as List<dynamic>?)
          ?.map((e) => AssignedTable.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
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

  static Future<void> updateStatus(int reservationId, String newStatus) async {
    final response = await ApiClient.post(
      'manager_update_reservation_status',
      body: json.encode({
        'p_reservation_id': reservationId,
        'p_new_status': newStatus,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Impossible de mettre à jour le statut: ${response.body}');
    }
  }
}