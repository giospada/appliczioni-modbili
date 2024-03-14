import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool loading = true;
  final storage = FlutterSecureStorage();

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> tryAutoLogin() async {
    final accessToken = await storage.read(key: 'accessToken');
    loading = false;
    if (accessToken == null) {
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
