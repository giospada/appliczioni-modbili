// singleton with configuration
import 'package:flutter/foundation.dart';

class Config {
  static final Config _config = Config._internal();

  factory Config() {
    return _config;
  }

  Config._internal();

  String get host => 'appliczioni-modbili.vercel.app';

  int? notifyBefore = 10;

  String nullSport = 'Nessuno';

  final String? defToken = !kDebugMode
      ? null
      : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdHJpbmciLCJleHAiOjE3MTkzOTc4MTF9.pCulGDc_PpfYbEmkVO_JEt-24C5P_MlgSl-iK3aDDzw";

  final List<String> sports = ['running', 'basketball', 'football'];
}
