import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/transaction.dart';
import 'auth_service.dart';

class TransactionApi {
  TransactionApi(this._session, {this.baseUrl = kBaseUrl, http.Client? client})
    : _client = client ?? http.Client();

  static const _orders = '/api/pesanan/';
  final CookieRequest _session;
  final http.Client _client;
  final String baseUrl;

  void close() => _client.close();

  Future<List<RentalTransaction>> history() async {
    final uri = Uri.parse(baseUrl).resolve(_orders);
    final request = http.Request('GET', uri)
      ..followRedirects = false
      ..headers['Accept'] = 'application/json';

    await _session.init();
    final cookie = _session.headers['cookie'];
    if (!kIsWeb && cookie != null) request.headers['Cookie'] = cookie;

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
      throw const ApiException('Sesi kamu berakhir. Silakan masuk kembali.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException(
        'Riwayat transaksi belum tersedia. Coba lagi nanti.',
      );
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final rows = _transactionRows(decoded);
      return rows
          .whereType<Map<String, dynamic>>()
          .map(RentalTransaction.fromJson)
          .toList();
    } on FormatException {
      throw const ApiException(kBadResponseMessage);
    } on TypeError {
      throw const ApiException(kBadResponseMessage);
    }
  }

  List<dynamic> _transactionRows(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      if (decoded['status'] == false) {
        throw ApiException(
          decoded['message'] as String? ?? 'Riwayat transaksi gagal dimuat.',
        );
      }
      for (final key in ['results', 'pesanan', 'orders', 'data']) {
        final value = decoded[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          for (final nestedKey in ['results', 'pesanan', 'orders']) {
            if (value[nestedKey] is List) return value[nestedKey] as List;
          }
        }
      }
    }
    throw const FormatException('Unknown transaction response');
  }
}
