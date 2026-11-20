import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/location.dart';
import '../../services/auth_service.dart';
import '../../services/location_api.dart';
import '../../widgets/left_drawer.dart';
import '../../widgets/pinjemin_app_bar.dart';
import 'location_map.dart';
import 'saved_locations_page.dart';

class PetaBarangPage extends StatefulWidget {
  const PetaBarangPage({super.key});

  @override
  State<PetaBarangPage> createState() => _PetaBarangPageState();
}

class _PetaBarangPageState extends State<PetaBarangPage> {
  late final LocationApi _api;
  LatLng _point = campusCenter;
  int _radius = 1;
  bool _searching = false;
  List<NearbyItem>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = LocationApi(context.read<CookieRequest>());
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _searching = true;
      _error = null;
      _items = null;
    });
    try {
      final items = await _api.nearby(_point, _radius);
      if (!mounted) return;
      setState(() => _items = items);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _items;
    return Scaffold(
      appBar: const PinjeminAppBar(title: 'Peta Barang'),
      drawer: const LeftDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Cari barang terdekat', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text('Ketuk peta untuk memilih titik awal pencarian.'),
          const SizedBox(height: 12),
          LocationMap(
            initialCenter: campusCenter,
            point: _point,
            items: items ?? const [],
            onPointSelected: (point) {
              if (_searching) return;
              setState(() {
                _point = point;
                _items = null;
                _error = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Text('Radius pencarian', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 km')),
                ButtonSegment(value: 2, label: Text('2 km')),
              ],
              selected: {_radius},
              onSelectionChanged: _searching
                  ? null
                  : (selection) => setState(() {
                      _radius = selection.single;
                      _items = null;
                      _error = null;
                    }),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _searching ? null : _search,
            icon: const Icon(Icons.search),
            label: const Text('Cari barang'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SavedLocationsPage(api: _api)),
            ),
            icon: const Icon(Icons.bookmark_outline),
            label: const Text('Lokasi Tersimpan'),
          ),
          if (_searching) const LinearProgressIndicator(),
          if (_error case final error?)
            Text(error, style: TextStyle(color: theme.colorScheme.error)),
          if (items != null) ...[
            const SizedBox(height: 14),
            if (items.isEmpty)
              const Text('Belum ada barang dalam radius ini.')
            else ...[
              Text(
                'Lokasi barang di peta hanya perkiraan.',
                style: theme.textTheme.bodySmall,
              ),
              for (final item in items)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.area} · ${item.distanceKm.toStringAsFixed(2)} km',
                    ),
                    trailing: Text(item.price),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
