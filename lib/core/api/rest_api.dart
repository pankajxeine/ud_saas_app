import 'package:dio/dio.dart';

import '../app_api_exception.dart';
import '../config/app_logger.dart';
import '../config/local_storage.dart';

typedef JsonMap = Map<String, dynamic>;
typedef RestDecoder<T> = T Function(dynamic data);

const String _domainAppStorageKey = 'app.type';
const String _domainSlugStorageKey = 'app.slug';
const String _defaultDomainApp = 'crm';
const String _defaultDomainSlug = 'test_cpanel';

enum RestMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  const RestMethod(this.value);

  final String value;
}

class RestApi {
  static final _log = AppLogger.getLogger('RestApi');
  static RestApi? _global;

  final Dio _dio;

  RestApi({
    String? baseUrl,
    Map<String, String> defaultHeaders = const {},
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    configure(
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  factory RestApi.global() {
    return _global ??= RestApi();
  }

  static void configureGlobal({
    required String baseUrl,
    Map<String, String> defaultHeaders = const {},
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    _global = RestApi(
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  void configure({
    String? baseUrl,
    Map<String, String> defaultHeaders = const {},
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    _dio.options
      ..baseUrl = baseUrl ?? _dio.options.baseUrl
      ..connectTimeout = connectTimeout
      ..receiveTimeout = receiveTimeout
      ..headers = {
        Headers.acceptHeader: Headers.jsonContentType,
        Headers.contentTypeHeader: Headers.jsonContentType,
        ...defaultHeaders,
      };

    if (_dio.interceptors.whereType<LogInterceptor>().isEmpty) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  void setBearerToken(String? token) {
    if (token == null || token.trim().isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void setHeader(String key, String? value) {
    if (value == null) {
      _dio.options.headers.remove(key);
    } else {
      _dio.options.headers[key] = value;
    }
  }

  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    RestDecoder<T>? decoder,
  }) {
    return request<T>(
      endpointPath: endpoint,
      method: RestMethod.get.value,
      queryParams: queryParams,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    RestDecoder<T>? decoder,
  }) {
    return request<T>(
      endpointPath: endpoint,
      method: RestMethod.post.value,
      body: body,
      queryParams: queryParams,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    RestDecoder<T>? decoder,
  }) {
    return request<T>(
      endpointPath: endpoint,
      method: RestMethod.put.value,
      body: body,
      queryParams: queryParams,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> patch<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    RestDecoder<T>? decoder,
  }) {
    return request<T>(
      endpointPath: endpoint,
      method: RestMethod.patch.value,
      body: body,
      queryParams: queryParams,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    RestDecoder<T>? decoder,
  }) {
    return request<T>(
      endpointPath: endpoint,
      method: RestMethod.delete.value,
      body: body,
      queryParams: queryParams,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<T> request<T>({
    String? endpoint,
    String? endpointPath,
    String method = 'GET',
    Map<String, dynamic>? queryParams,
    dynamic body,
    Map<String, String>? headers,
    RestDecoder<T>? decoder,
  }) async {
    final path = endpointPath ?? endpoint;
    if (path == null || path.trim().isEmpty) {
      throw BadRequestException('Endpoint path is required');
    }

    try {
      final requestHeaders = await _withStoredRequestHeaders(headers);
      final response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: queryParams,
        options: Options(method: method, headers: requestHeaders),
      );
      final data = response.data;
      if (decoder != null) {
        return decoder(data);
      }
      return data as T;
    } on DioException catch (error, stack) {
      _log.error(
        'REST request failed: ${error.requestOptions.method} '
        '${error.requestOptions.uri}',
        [error, stack],
      );
      throw _mapDioException(error);
    }
  }

  Future<Response<T>> requestWithResponse<T>({
    String? endpoint,
    String? endpointPath,
    String method = 'GET',
    Map<String, dynamic>? queryParams,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final path = endpointPath ?? endpoint;
    if (path == null || path.trim().isEmpty) {
      throw BadRequestException('Endpoint path is required');
    }

    try {
      final requestHeaders = await _withStoredRequestHeaders(headers);
      final response = await _dio.request<T>(
        path,
        data: body,
        queryParameters: queryParams,
        options: Options(method: method, headers: requestHeaders),
      );
      return response;
    } on DioException catch (error, stack) {
      _log.error(
        'REST request failed: ${error.requestOptions.method} '
        '${error.requestOptions.uri}',
        [error, stack],
      );
      throw _mapDioException(error);
    }
  }

  Future<Map<String, String>> _withStoredRequestHeaders(
    Map<String, String>? providedHeaders,
  ) async {
    final Map<String, String> headers = <String, String>{...?providedHeaders};
    if (!_containsHeader(headers, 'x-domain-app')) {
      headers['x-domain-app'] = await _readStoredHeaderValue(
        _domainAppStorageKey,
        _defaultDomainApp,
      );
    }
    if (!_containsHeader(headers, 'x-domain-slug')) {
      headers['x-domain-slug'] = await _readStoredHeaderValue(
        _domainSlugStorageKey,
        _defaultDomainSlug,
      );
    }

    if (_containsHeader(headers, 'authorization')) {
      return headers;
    }

    final token = await AppLocalStorage().read(StorageKeys.accessToken.name);
    if (token is! String || token.trim().isEmpty) {
      return headers;
    }

    return {...headers, 'Authorization': 'Bearer $token'};
  }

  Future<String> _readStoredHeaderValue(String key, String fallback) async {
    final Object? storedValue = await AppLocalStorage().read(key);
    if (storedValue is String && storedValue.trim().isNotEmpty) {
      return storedValue.trim();
    }
    return fallback;
  }

  bool _containsHeader(Map<String, String> headers, String name) =>
      headers.keys.any((String key) => key.toLowerCase() == name);

  AppException _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _extractMessage(error);

    if (statusCode == 400) {
      return BadRequestException(message);
    }
    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedException(message);
    }
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ApiBusinessException(message);
    }
    return FetchDataException(message);
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null) {
        return message.toString();
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return error.message ?? 'Unable to complete request';
  }
}
