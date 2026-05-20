import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:prbd_2526_c05/core/tools/params.dart';
import 'package:prbd_2526_c05/models/security.dart';

final securityProvider = AsyncNotifierProvider<SecurityNotifier, String?>(
      () => SecurityNotifier(),
);

class SecurityNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // pour que le state soit initialisée de manière synchrone
    state = AsyncData(Params.getValue('token'));
    return state.value;
  }
  Future<void> resetDatabase() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    try {
      final previousState = state;
      await Security.resetDatabase();
      state = previousState;
    } catch (e) {
      state = AsyncError(
          "Something went wrong!\nPlease try again later.",
          StackTrace.current);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));

    try {
      var token = await Security.login(email, password);
      Params.setValue('token', token);
      state = AsyncData(token);
    } catch (e) {
      state = AsyncError(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

  void logout() {
    Params.clearValue('token');
    state = AsyncData(null);
  }

  bool get isLoggedIn => loggedUser != null;

  String? get loggedUser {
    return _getUserFromToken(state.value);
  }

  static String? _getUserFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'];
    } catch (e) {
      return null;
    }
  }

  bool get isManager => _getRoleFromToken(state.value) == 'manager';

  static String? _getRoleFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'];
    } catch (e) {
      return null;
    }
  }

  Future<void> signup({
    required String pseudo,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await Security.signup(pseudo: pseudo, password: password);
      await login(pseudo, password);
      state = AsyncValue.data(Params.getValue('token'));
    } catch (e) {
      state = AsyncValue.error("Signup failed", StackTrace.current);
    }
  }
}
