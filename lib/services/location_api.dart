import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/location.dart';
import 'auth_service.dart';

class LocationApi {
  LocationApi(this._session, {this.baseUrl = kBaseUrl, http.Client? client})
    : _client = client ?? http.Client();

  static const _pickups = '/api/lokasi-penjemputan/';
  final CookieRequest _session;
  final http.Client _client;
  final String baseUrl;

  void close() => _client.close();

  Future<List<NearbyItem>> nearby(LatLng point, int radius) => _call(
    'GET',
    '/api/barang-terdekat/',
    (data) => ((data as Map<String, dynamic>)['items'] as List)
        .map((item) => NearbyItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    query: {
      'latitude': point.latitude.toStringAsFixed(6),
      'longitude': point.longitude.toStringAsFixed(6),
      'radius': '$radius',
    },
    authenticated: false,
  );

  Future<List<PickupLocation>> savedLocations() => _call(
    'GET',
    _pickups,
    (data) => (data as List)
        .map(
          (location) =>
              PickupLocation.fromJson(location as Map<String, dynamic>),
        )
        .toList(),
  );

  Future<PickupLocation> save({
    required String label,
    required String address,
    required LatLng point,
    int? id,
  }) => _call(
    id == null ? 'POST' : 'PATCH',
    id == null ? _pickups : '$_pickups$id/',
    (data) => PickupLocation.fromJson(data as Map<String, dynamic>),
    body: {
      'label': label,
      'address': address,
      'latitude': point.latitude.toStringAsFixed(6),
      'longitude': point.longitude.toStringAsFixed(6),
    },
  );

  Future<void> delete(int id) => _call('DELETE', '$_pickups$id/', (_) {});

  Future<T> _call<T>(
    String method,
    String path,
    T Function(dynamic) parse, {
    Map<String, String>? query,
    Map<String, String>? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse(baseUrl)
        .resolve(path)
        .replace(queryParameters: query);
    final request = http.Request(method, uri)..followRedirects = false;
    request.headers['Accept'] = 'application/json';
    if (authenticated) {
      await _session.init();
      final cookie = _session.headers['cookie'];
      if (!kIsWeb && cookie != null) request.headers['Cookie'] = cookie;
      if (method != 'GET') {
        final csrf = _session.cookies['csrftoken']?.value;
        if (csrf != null) request.headers['X-CSRFToken'] = csrf;
        if (!kIsWeb) request.headers['Origin'] = uri.origin;
      }
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const ApiException(kNetworkErrorMessage);
    } on http.ClientException {
      throw const ApiException(kNetworkErrorMessage);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ApiException('Akses lokasi ditolak. Coba masuk ulang.');
    }
    if (response.statusCode == 400) {
      throw const ApiException('Periksa kembali data atau titik lokasi.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException(
        'Layanan lokasi belum tersedia. Coba lagi nanti.',
      );
    }
    try {
      return parse(
        response.statusCode == 204
            ? null
            : jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } on FormatException {
      throw const ApiException(kBadResponseMessage);
    } on TypeError {
      throw const ApiException(kBadResponseMessage);
    }
  }
}
