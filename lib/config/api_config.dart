/// Central place to point the app at your REST API.
///
/// - Android emulator -> host machine: use 10.0.2.2
/// - iOS simulator -> host machine: use localhost / 127.0.0.1
/// - Physical device: use your machine's LAN IP, e.g. http://192.168.1.20:8000
/// - Production: swap for your real API domain.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://127.0.0.1:8000/api',
    // defaultValue: 'http://10.144.63.138/api',
    defaultValue: 'http://18.142.171.237/api',
  );

  static const Duration timeout = Duration(seconds: 8);
}
