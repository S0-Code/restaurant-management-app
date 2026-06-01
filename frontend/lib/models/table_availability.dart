import 'dart:convert';
import '../core/services/api_client.dart';

class TableAvailability {
  final int id;
  final int tableNumber;
  final int capacity;
  final bool isAvailable;

  TableAvailability({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.isAvailable,
  });

  factory TableAvailability.fromJson(Map<String, dynamic> json) {
    return TableAvailability(
      id: json['id'] as int,
      tableNumber: json['table_number'] as int,
      capacity: json['capacity'] as int,
      isAvailable: json['is_available'] as bool,
    );
  }

  static Future<List<TableAvailability>> getAvailability(int restaurantId, int reservationId) async {
    final response = await ApiClient.post(
      'get_restaurant_tables_availability',
      body: json.encode({
        'p_restaurant_id': restaurantId,
        'p_reservation_id': reservationId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => TableAvailability.fromJson(e)).toList();
    }
    throw Exception('Erreur API tables: ${response.statusCode}\nDétails: ${response.body}');
  }

  static Future<void> assignAndConfirm(int reservationId, List<int> tableIds) async {
    final response = await ApiClient.post(
      'manager_assign_tables_and_confirm',
      body: json.encode({
        'p_reservation_id': reservationId,
        'p_table_ids': tableIds,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur API (${response.statusCode}) : ${response.body}');
    }
  }
}