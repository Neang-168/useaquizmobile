import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session.dart';

/// Thrown for any network/API failure. Callers use this to decide whether
/// to fall back to demo data (see [ApiException.isConnectivity]).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isConnectivity; // true = couldn't reach the server at all
  ApiException(this.message, {this.statusCode, this.isConnectivity = false});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin wrapper around package:http that adds base URL, auth header,
/// timeouts, and consistent JSON/error handling.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Set by `main.dart` to bounce back to the login screen whenever a
  /// request comes back 401 (expired/invalid token). Kept as a callback
  /// rather than importing a screen here to keep services/ independent of
  /// screens/.
  static void Function()? onUnauthorized;
  bool _handling401 = false;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (auth) {
      final token = await Session.loadToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('${ApiConfig.baseUrl}/$clean').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    return _send(() async => http.get(_uri(path, query), headers: await _headers(auth: auth)));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    return _send(() async => http.post(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body ?? {})));
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    return _send(() async => http.patch(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body ?? {})));
  }

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    http.Response res;
    try {
      res = await call().timeout(ApiConfig.timeout);
    } catch (_) {
      // Covers SocketException, TimeoutException, handshake errors, etc.
      throw ApiException('Could not reach the server at ${ApiConfig.baseUrl}', isConnectivity: true);
    }

    if (res.statusCode == 401) {
      if (!_handling401) {
        _handling401 = true;
        await Session.clear();
        onUnauthorized?.call();
        _handling401 = false;
      }
      throw ApiException('Session expired. Please log in again.', statusCode: 401);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'Request failed (${res.statusCode})';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['message'] != null) msg = decoded['message'];
      } catch (_) {/* ignore parse errors, use default message */}
      throw ApiException(msg, statusCode: res.statusCode);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }
}
