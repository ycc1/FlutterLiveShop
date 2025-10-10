import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import '../../config/app_config.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({
    String baseUrl = AppConfig.apiBaseUrl, // ← 改这里即可切环境
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: {
                'Content-Type': 'application/json',
                'Host': AppConfig.apiBaseUrl,
                'Content-Length': '4000', // 初始值，后续会覆盖
                'X-Platform': 'flutter' // ← 可自定义平台标识
              },
            )) {
    // ✅ 打印所有请求/响应
    /*
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    */
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
