import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth token + basic student info between app launches.
class Session {
  Session._();
  static const _tokenKey = 'auth_token';
  static const _rememberKey = 'remember_me';

  static String? _cachedToken;

  static Future<void> saveToken(String token, {required bool remember}) async {
    _cachedToken = token;
    if (!remember) return; // keep in-memory only for this launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_rememberKey, true);
  }

  static Future<String?> loadToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  static Future<void> clear() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_rememberKey);
  }
}
