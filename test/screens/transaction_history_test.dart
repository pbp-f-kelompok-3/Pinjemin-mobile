import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pinjemin_mobile/screens/transaksi/daftar_transaksi_page.dart';
import 'package:pinjemin_mobile/services/transaction_api.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(setUpTestEnvironment);
  setUp(() => mockStoredSession(loggedIn: false));

  const data = [
    {
      'id': 42,
      'item_name': 'Kamera mirrorless',
      'status': 'berlangsung',
      'payment_status': 'lunas',
      'start_date': '2026-11-18T00:00:00Z',
      'end_date': '2026-11-20T00:00:00Z',
      'total': 50000,
      'pickup_location': 'Perpustakaan UI',
    },
    {'id': 43, 'item_name': 'Tripod', 'status': 'selesai', 'total': 25000},
    {'id': 44, 'item_name': 'Proyektor', 'status': 'dibatalkan'},
  ];

  TransactionApi apiFor(List<Map<String, dynamic>> transactions) =>
      TransactionApi(
        FakeCookieRequest(),
        baseUrl: 'https://pinjemin.test',
        client: MockClient(
          (_) async => http.Response(jsonEncode(transactions), 200),
        ),
      );

  testWidgets('shows transaction cards and filters by status', (tester) async {
    final api = apiFor(data);
    addTearDown(api.close);
    await pumpSettled(
      tester,
      wrapWithApp(DaftarTransaksiPage(api: api), request: FakeCookieRequest()),
    );

    expect(find.text('Riwayat transaksi'), findsOneWidget);
    expect(find.text('Kamera mirrorless'), findsOneWidget);
    expect(find.text('Tripod'), findsOneWidget);
    expect(find.text('Rp 50.000'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Tripod'), findsOneWidget);
    expect(find.text('Kamera mirrorless'), findsNothing);
  });

  testWidgets('opens transaction details from a history card', (tester) async {
    final api = apiFor([data.first]);
    addTearDown(api.close);
    await pumpSettled(
      tester,
      wrapWithApp(DaftarTransaksiPage(api: api), request: FakeCookieRequest()),
    );

    await tester.tap(find.text('Kamera mirrorless'));
    await tester.pumpAndSettle();

    expect(find.text('Detail transaksi'), findsOneWidget);
    expect(find.text('Perpustakaan UI'), findsOneWidget);
    expect(find.text('Lunas'), findsWidgets);
  });

  testWidgets('shows a useful empty-history state', (tester) async {
    final api = apiFor([]);
    addTearDown(api.close);
    await pumpSettled(
      tester,
      wrapWithApp(DaftarTransaksiPage(api: api), request: FakeCookieRequest()),
    );

    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
