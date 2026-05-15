import 'dart:async';

import '../domain/auth_state.dart';

class AuthRepository {
  Future<AuthState> signIn(String nik, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return const AuthState(isAuthenticated: true, userName: 'Budi Santoso');
  }

  Future<AuthState> register(Map<String, String> payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const AuthState(isAuthenticated: true, userName: 'Budi Santoso');
  }
}
