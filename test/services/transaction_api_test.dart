import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pinjemin_mobile/models/transaction.dart';
import 'package:pinjemin_mobile/services/auth_service.dart';
import 'package:pinjemin_mobile/services/transaction_api.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => mockStoredSession(loggedIn: false));

  test(
    'loads and parses transaction history from the authenticated endpoint',
    () async {
      mockStoredSession();
      final api = TransactionApi(
        FakeCookieRequest(),
        baseUrl: 'https://pinjemin.test',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/pesanan/');
          expect(request.headers['cookie'], contains('sessionid=abc'));
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'id': 42,
                  'barang': {'nama': 'Kamera mirrorless'},
                  'status_pesanan': 'berlangsung',
                  'status_pembayaran': 'lunas',
                  'tanggal_mulai': '2026-11-18T00:00:00Z',
                  'tanggal_kembali': '2026-11-20T00:00:00Z',
                  'total_harga': 50000,
                  'lokasi_penjemputan': 'Perpustakaan UI',
                },
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(api.close);

      final history = await api.history();

      expect(history, hasLength(1));
      expect(history.single.itemName, 'Kamera mirrorless');
      expect(history.single.statusLabel, 'Berlangsung');
      expect(history.single.paymentStatus, 'lunas');
      expect(history.single.total, 50000);
      expect(history.single.pickupLocation, 'Perpustakaan UI');
    },
  );

  test('accepts a plain empty list as an empty history', () async {
    final api = TransactionApi(
      FakeCookieRequest(),
      baseUrl: 'https://pinjemin.test',
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    addTearDown(api.close);

    expect(await api.history(), isEmpty);
  });

  test('maps an unauthorized response to a friendly session message', () async {
    final api = TransactionApi(
      FakeCookieRequest(),
      baseUrl: 'https://pinjemin.test',
      client: MockClient((_) async => http.Response('', 401)),
    );
    addTearDown(api.close);

    await expectLater(
      api.history(),
      throwsA(
        isA<ApiException>().having(
          (error) => error.toString(),
          'message',
          contains('Sesi kamu berakhir'),
        ),
      ),
    );
  });

  test('normalizes status aliases for filters', () {
    final transaction = RentalTransaction.fromJson({
      'id': 1,
      'status': 'selesai',
    });

    expect(transaction.isCompleted, isTrue);
    expect(transaction.statusLabel, 'Selesai');
  });
}
