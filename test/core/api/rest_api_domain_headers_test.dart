import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ud_sass_app/core/api/rest_api.dart';
import 'package:ud_sass_app/core/config/app_logger.dart';
import 'package:ud_sass_app/core/config/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences preferences;
  late _RecordingAdapter adapter;
  late RestApi api;

  setUp(() async {
    AppLogger.configure(isProduction: false);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    SharedPreferencesStrategy().setPreferencesInstance(preferences);
    AppLocalStorage().setStorage(StorageType.sharedPreferences);
    adapter = _RecordingAdapter();
    api = RestApi(
      baseUrl: 'https://api.example.test',
      dio: Dio()..httpClientAdapter = adapter,
    );
  });

  test('sends stored domain app and slug values', () async {
    await preferences.setString('app.type', 'billing');
    await preferences.setString('app.slug', 'north-region');

    await api.get<dynamic>('/health');

    expect(adapter.headers['x-domain-app'], 'billing');
    expect(adapter.headers['x-domain-slug'], 'north-region');
    expect(adapter.headers.keys, isNot(contains('host')));
  });

  test('uses configured defaults when domain values are missing', () async {
    await api.requestWithResponse<dynamic>(endpointPath: '/health');

    expect(adapter.headers['x-domain-app'], 'test-cpanel');
    expect(adapter.headers['x-domain-slug'], 'crm');
    expect(adapter.headers.keys, isNot(contains('host')));
  });

  test(
    'request headers override stored domain values case-insensitively',
    () async {
      await preferences.setString('app.type', 'billing');
      await preferences.setString('app.slug', 'north-region');

      await api.post<dynamic>(
        '/health',
        headers: const <String, String>{
          'X-Domain-App': 'custom-app',
          'X-Domain-Slug': 'custom-slug',
        },
      );

      expect(adapter.headers['x-domain-app'], 'custom-app');
      expect(adapter.headers['x-domain-slug'], 'custom-slug');
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  Map<String, dynamic> headers = <String, dynamic>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    headers = Map<String, dynamic>.from(options.headers);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
