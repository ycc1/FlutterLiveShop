import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:io' show Platform;

class ApiClient {
  final Dio _dio;

  ApiClient({
    String baseUrl = 'http://localhost:2015',
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: {
                'Content-Type': 'application/json',
                'X-Platform': 'flutter'
              },
            )) {
    // ✅ 在构造时添加拦截器：自动加入动态 Header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 这里可动态添加 headers
          options.headers['X-App-Version'] = '1.0.0';

          // 如果你有 JWT Token：
          final token = await _getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (!Platform.isWindows && !Platform.isMacOS) {
            options.headers.addAll({
              'Host': 'localhost:2015',
            });

            // Content-Length 必须是准确值，否则 HttpClient 会覆盖
            final data = options.data;
            if (data is String) {
              options.headers['Content-Length'] = data.length.toString();
            } else if (data is Map) {
              final jsonStr = jsonEncode(data);
              options.headers['Content-Length'] =
                  utf8.encode(jsonStr).length.toString();
            }
          }

          return handler.next(options);
        },
        onError: (e, handler) {
          // 统一错误处理也可在这
          return handler.next(e);
        },
      ),
    );
  }

  // 假设未来要从本地 SecureStorage 获取 token
  Future<String?> _getToken() async {
    // TODO: 换成你自己的逻辑，如 SharedPreferences / secure storage
    // return await SecureStorage.getToken();
    return null;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Exception _wrap(DioException e) {
    final code = e.response?.statusCode;
    final msg = e.response?.data is Map && e.response?.data['message'] != null
        ? e.response!.data['message'].toString()
        : e.message ?? 'Network error';
    return Exception('HTTP $code: $msg');
  }
}
