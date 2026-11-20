import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:pinjemin_mobile/services/location_api.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const campus = LatLng(-6.3621, 106.8279);
  const location = {
    'id': 17,
    'label': 'Kos Kukusan',
    'address': 'Jalan K.H.M. Usman',
    'latitude': -6.3621,
    'longitude': 106.8279,
  };

  test(
    'nearby sends the point and radius and reads the public results',
    () async {
      final api = LocationApi(
        FakeCookieRequest(),
        baseUrl: 'https://pinjemin.test',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/barang-terdekat/');
          expect(request.url.queryParameters, {
            'latitude': '-6.362100',
            'longitude': '106.827900',
            'radius': '2',
          });
          expect(request.headers['cookie'], isNull);
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'name': 'Kabel rol',
                  'price': 'Gratis',
                  'area': 'Kukusan',
                  'distance_km': 0.2,
                  'latitude': -6.362,
                  'longitude': 106.828,
                },
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(api.close);

      final items = await api.nearby(campus, 2);
      expect(items.single.name, 'Kabel rol');
      expect(items.single.distanceKm, 0.2);
    },
  );

  test(
    'saved location requests reuse the Django session and CSRF token',
    () async {
      mockStoredSession();
      final methods = <String>[];
      final api = LocationApi(
        FakeCookieRequest(),
        baseUrl: 'https://pinjemin.test',
        client: MockClient((request) async {
          methods.add(request.method);
          expect(request.headers['cookie'], contains('sessionid=abc'));
          if (request.method == 'GET') {
            expect(request.url.path, '/api/lokasi-penjemputan/');
            return http.Response(jsonEncode([location]), 200);
          }
          expect(request.headers['X-CSRFToken'], 'stored-token');
          expect(request.headers['Origin'], 'https://pinjemin.test');
          if (request.method == 'DELETE') {
            expect(request.url.path, '/api/lokasi-penjemputan/17/');
            return http.Response('', 204);
          }
          final isNew = request.method == 'POST';
          expect(
            request.url.path,
            isNew ? '/api/lokasi-penjemputan/' : '/api/lokasi-penjemputan/17/',
          );
          expect(jsonDecode(request.body), {
            'label': 'Kos Kukusan',
            'address': 'Jalan K.H.M. Usman',
            'latitude': '-6.362100',
            'longitude': '106.827900',
          });
          return http.Response(jsonEncode(location), isNew ? 201 : 200);
        }),
      );
      addTearDown(api.close);

      expect((await api.savedLocations()).single.label, 'Kos Kukusan');
      for (final id in [null, 17]) {
        final saved = await api.save(
          id: id,
          label: 'Kos Kukusan',
          address: 'Jalan K.H.M. Usman',
          point: campus,
        );
        expect(saved.id, 17);
      }
      await api.delete(17);
      expect(methods, ['GET', 'POST', 'PATCH', 'DELETE']);
    },
  );
}
