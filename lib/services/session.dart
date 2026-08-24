import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth token + role between app launches. The role is needed
/// because several `AppRepository` methods (e.g. fetchSubjects,
/// fetchClassRooms) are shared by both Student and Teacher screens but hit
/// different, role-scoped Laravel routes — this is how they know which one
/// to call without every call site having to pass the role down explicitly.
class Session {
  Session._();
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _rememberKey = 'remember_me';

  static String? _cachedToken;
  static String? _cachedRole;

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

  static Future<void> saveRole(String role, {required bool remember}) async {
    _cachedRole = role;
    if (!remember) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> loadRole() async {
    if (_cachedRole != null) return _cachedRole;
    final prefs = await SharedPreferences.getInstance();
    _cachedRole = prefs.getString(_roleKey);
    return _cachedRole;
  }

  static Future<void> clear() async {
    _cachedToken = null;
    _cachedRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_rememberKey);
  }
}
