// singleton with configuration
class Config {
  static final Config _config = Config._internal();

  factory Config() {
    return _config;
  }

  Config._internal();

  String get host => 'http://localhost:8000';
}
