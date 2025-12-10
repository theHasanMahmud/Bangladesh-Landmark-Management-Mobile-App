import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  static const _tokenKey = 'auth_token';
  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  String? _token;

  String? get token => _token;

  Map<String, String> get authHeaders => _token != null ? {'Authorization': 'Bearer $_token'} : {};

  /// Call this after Clerk (or any IdP) returns a session/JWT token.
  Future<void> setExternalToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    isLoggedIn.value = true;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    isLoggedIn.value = _token != null;
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return false;
    // Legacy mock login; prefer setExternalToken() with Clerk session tokens.
    await setExternalToken('${username.hashCode}-${password.hashCode}');
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _token = null;
    isLoggedIn.value = false;
  }
}
