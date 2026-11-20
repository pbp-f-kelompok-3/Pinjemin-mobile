import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/location.dart';

const campusCenter = LatLng(-6.3621, 106.8279);

class LocationMap extends StatelessWidget {
  const LocationMap({
    super.key,
    required this.initialCenter,
    required this.onPointSelected,
    this.point,
    this.items = const [],
  });

  final LatLng initialCenter;
  final ValueChanged<LatLng> onPointSelected;
  final LatLng? point;
  final List<NearbyItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 15,
            minZoom: 4,
            maxZoom: 19,
            backgroundColor: colors.surfaceContainer,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (_, selected) => onPointSelected(selected),
          ),
          children: [
            TileLayer(
              urlTemplate: const String.fromEnvironment(
                'OSM_TILE_URL',
                defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              userAgentPackageName: 'id.ac.ui.pbp.pinjemin',
              panBuffer: 0,
            ),
            MarkerLayer(
              markers: [
                for (final item in items)
                  Marker(
                    point: item.point,
                    child: Tooltip(
                      message: item.name,
                      child: Icon(Icons.place, color: colors.error, size: 29),
                    ),
                  ),
                if (point case final selected?)
                  Marker(
                    point: selected,
                    child: Icon(
                      Icons.my_location,
                      color: colors.tertiary,
                      size: 31,
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
      ),
    );
  }
}
