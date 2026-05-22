import 'dart:convert';

import 'package:prbd_2526_c05/core/services/api_client.dart';
import 'package:prbd_2526_c05/models/security.dart';

class User {

  int? id;
  String email;
  Role role;


  User(this.id, this.email, this.role);

  static Future<User?> getUserByEmail(String? email) async {
    if (email == null) {
      return null;
    }

    final encodedEmail = Uri.encodeComponent(email);

    final response = await ApiClient.get(
      "getUserByEmail/$encodedEmail",
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      return User.fromJson(body);
    }

    throw Exception('Failed to get user');
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['email'],
      json['role'],
    );
  }
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'required';
    } else if (email.length < 3) {
      return 'must be at least 3 characters';
    } else {
      return null;
    }
  }

  static Future<String?> validatePseudoUnicity(String? value) async {
    var res = await Security.checkPseudoAvailable(pseudo: value?.trim());
    return res ? null : 'not available';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'required';
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    String? passwordError = validatePassword(value);
    if (passwordError != null) return passwordError;
    if (value != password) return 'passwords do not match';
    return null;
  }
}

enum Role {
  client,
  manager
}