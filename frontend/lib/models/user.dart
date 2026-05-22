
import 'dart:convert';

import 'package:prbd_2526_c05/core/services/api_client.dart';

import 'package:flutter/foundation.dart';

import 'package:prbd_2526_c05/models/security.dart';

class User {


  int? id;
  String email;
  Role role;


  User(this.id, this.email, this.role);



  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['email'],
      json['role'],
    );
  }


  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'Requis';
    if (!email.contains('@') || !email.contains('.')) return 'Format d\'email invalide';
    return null;
  }

  static Future<String?> validateEmailUnicity(String? value) async {
    String? formatError = validateEmail(value);
    if (formatError != null) return formatError;

    try {
      var isAvailable = await Security.checkEmailAvailable(email: value!.trim());
      return isAvailable ? null : 'Cet email est déjà utilisé';
    } catch (e) {
      debugPrint('ERREUR API EMAIL: $e');
      return 'Erreur de connexion au serveur';
    }
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Requis';
    if (value.length < 8) return 'Minimum 8 caractères';

    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Doit contenir une minuscule';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Doit contenir une majuscule';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Doit contenir un chiffre';
    if (!RegExp(r'[,;.:!?/$%&@#]').hasMatch(value)) return 'Caractère spécial requis (,;.:!?/\$%&@#)';

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    String? passwordError = validatePassword(value);
    if (passwordError != null) return passwordError;
    if (value != password) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().length < 3) return 'Le nom doit contenir au moins 3 caractères';
    return null;
  }

  // Vérification du Nom
  static Future<String?> validateFullNameUnicity(String? value) async {
    String? formatError = validateFullName(value);
    if (formatError != null) return formatError;

    try {
      var isAvailable = await Security.checkFullNameAvailable(fullName: value!.trim());
      return isAvailable ? null : 'Ce nom complet est déjà utilisé';
    } catch (e) {
      debugPrint('ERREUR API NOM: $e');
      return 'Erreur de connexion au serveur';
    }
  }

  // Vérification du téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    if (!RegExp(r'^[+0-9\s]+$').hasMatch(value)) {
      return 'Format de téléphone invalide (chiffres uniquement)';
    }
    return null;
  }
}

enum Role {
  client,
  manager
}