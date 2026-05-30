import 'dart:convert';

import '../core/services/api_client.dart';

class AppTime {
  static Future<DateTime?> getSimulatedTime() async {
    final response = await ApiClient.post(
      'get_simulated_time'
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body == null) return null;

      return DateTime.parse(body);
    }

    throw Exception('Failed to get simulated time');
  }

  static Future<void> setSimulatedTime(DateTime? time) async {
    final response = await ApiClient.post(
      'set_simulated_time',
      body: json.encode({
        'p_time': time?.toIso8601String(),
      }),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to set simulated time: ${response.statusCode} ${response.body}',
      );
    }
  }
}