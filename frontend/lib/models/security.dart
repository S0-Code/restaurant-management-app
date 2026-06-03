import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:prbd_2526_c05/core/services/api_client.dart';

class Security {
  static Future<String?> login(String email, String password) async {
    final response = await ApiClient.post(
      'login',
      body: json.encode({'email': email, 'password': password}),
      anonymous: true,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login');
    }
    final dynamic body = json.decode(response.body);
    String token = body['token'];
    return token;
  }
  static Future<void> resetDatabase() async {
    final response = await ApiClient.post(
      'reset_database',
      anonymous: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to reset database');
    }
  }

  // VERIFIER L'EMAIL
  static Future<bool> checkEmailAvailable({required String email}) async {
    try {
      final response = await ApiClient.post(
        'check_email_available',
        body: json.encode({'p_email': email}),
        anonymous: true,
      );

      final dynamic body = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception('Failed to validate email\n\n${body['message']}');
      }
      return body;
    } catch (e, st) {
      debugPrint('$e\n$st');
      throw Exception('Failed to validate email');
    }
  }

  // VERIFIER LE NOM COMPLET
  static Future<bool> checkFullNameAvailable({required String fullName}) async {
    try {
      final response = await ApiClient.post(
        'check_fullname_available',
        body: json.encode({'p_full_name': fullName}),
        anonymous: true,
      );

      final dynamic body = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception('Failed to validate full name');
      }
      return body;
    } catch (e, st) {
      debugPrint('ERREUR API NOM: $e');
      throw Exception('Failed to validate full name');
    }
  }

  // INSCRIPTION
  static Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await ApiClient.post(
        'signup',
        body: json.encode({
          'p_email': email,
          'p_password': password,
          'p_full_name': fullName,
          'p_phone': phone,
        }),
        anonymous: true,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to signup\n\n${response.body}');
      }
    } catch (e, st) {
      debugPrint('$e\n$st');
      throw Exception('Failed to signup');
    }
  }
}