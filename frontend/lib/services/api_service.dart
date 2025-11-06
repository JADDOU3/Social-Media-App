import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'local_storage_service.dart';

class ApiService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  // Use HTTP to match your Spring Boot configuration
  static const String _baseUrl = 'http://localhost:8080/api/';

  static String getBaseUrl() => _baseUrl;

  ApiService(this._localStorageService)
      : _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  ) {
    // Bypass SSL certificate verification for localhost (development only!)
    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['auth_required'] == false) {
            return handler.next(options);
          }

          final token = await _localStorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  Future<dynamic> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        bool authRequired = true,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'auth_required': authRequired}),
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<Uint8List> getBytes(
      String path, {
        Map<String, dynamic>? queryParameters,
        bool authRequired = true,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
          extra: {'auth_required': authRequired},
        ),
      );
      return response.data as Uint8List;
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> post(
      String path, {
        dynamic data,
        bool authRequired = true,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(extra: {'auth_required': authRequired}),
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> postFormData(
      String path,
      FormData formData, {
        bool authRequired = true,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'auth_required': authRequired},
        ),
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> patch(
      String path, {
        dynamic data,
        bool authRequired = true,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        options: Options(extra: {'auth_required': authRequired}),
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> delete(String path, {bool authRequired = true}) async {
    final response = await _dio.delete(
      path,
      options: Options(extra: {'auth_required': authRequired}),
    );
    return response.data;
  }

  Future<dynamic> put(
      String path, {
        dynamic data,
        bool authRequired = true,
      }) async {
    final response = await _dio.put(
      path,
      data: data,
      options: Options(extra: {'auth_required': authRequired}),
    );
    return response.data;
  }

  Future<dynamic> putFormData(
      String path,
      FormData formData, {
        bool authRequired = true,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'auth_required': authRequired},
        ),
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }
}

