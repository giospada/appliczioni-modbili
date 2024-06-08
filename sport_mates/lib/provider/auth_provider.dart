import 'package:flutter/material.dart';
import 'package:sport_mates/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool loading = true;
  final storage = const FlutterSecureStorage();

  String? get token => _token;
  // decode jwt token to get the paylod
  String? get getUsername {
    if (_token == null) return null;
    final parts = _token!.split('.');
    if (parts.length != 3) return null;
    final payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    final obj = json.decode(resp);
    return obj['sub'];
  }

  bool get isAuthenticated => _token != null;

  Future<void> tryAutoLogin() async {
    final accessToken = await storage.read(key: 'accessToken');
    loading = false;
    if (accessToken == null) {
      _token = Config().defToken;
      notifyListeners();
      return;
    }
    _token = accessToken;
    notifyListeners();
  }

  Future<void> login(String token) async {
    _token = token;
    await storage.write(key: 'accessToken', value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await storage.delete(key: 'accessToken');
    notifyListeners();
  }
}
