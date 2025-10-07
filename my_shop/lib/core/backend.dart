import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized backend configuration and a tiny Api client wrapper.
/// Change [baseUrl] to point to your backend (currently https://localhost/).
const String baseUrl = 'https://localhost/';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  final http.Client _http;
  final String base;

  ApiClient({http.Client? httpClient, this.base = baseUrl})
      : _http = httpClient ?? http.Client();

  Uri _uri(String path) {
    // Ensure we build a correct full URI
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, String>? headers}) async {
    final uri = _uri(path);
    final res = await _http.get(uri, headers: headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('GET ${uri.toString()} failed',
          statusCode: res.statusCode);
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path,
      {Map<String, String>? headers, Object? body}) async {
    final uri = _uri(path);
    final defaultHeaders = {'Content-Type': 'application/json'};
    if (headers != null) defaultHeaders.addAll(headers);
    final res = await _http.post(uri,
        headers: defaultHeaders, body: body == null ? null : json.encode(body));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('POST ${uri.toString()} failed',
          statusCode: res.statusCode);
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  void close() => _http.close();
}
