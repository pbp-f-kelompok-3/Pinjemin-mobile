import 'package:latlong2/latlong.dart';

class PickupLocation {
  const PickupLocation({
    required this.id,
    required this.label,
    required this.address,
    required this.point,
  });

  factory PickupLocation.fromJson(Map<String, dynamic> data) {
    return PickupLocation(
      id: data['id'] as int,
      label: data['label'] as String,
      address: data['address'] as String,
      point: _pointFromJson(data),
    );
  }

  final int id;
  final String label;
  final String address;
  final LatLng point;
}

class NearbyItem {
  const NearbyItem({
    required this.name,
    required this.price,
    required this.area,
    required this.distanceKm,
    required this.point,
  });

  factory NearbyItem.fromJson(Map<String, dynamic> data) {
    return NearbyItem(
      name: data['name'] as String,
      price: data['price'] as String,
      area: data['area'] as String,
      distanceKm: (data['distance_km'] as num).toDouble(),
      point: _pointFromJson(data),
    );
  }

  final String name;
  final String price;
  final String area;
  final double distanceKm;
  final LatLng point;
}

LatLng _pointFromJson(Map<String, dynamic> data) => LatLng(
  (data['latitude'] as num).toDouble(),
  (data['longitude'] as num).toDouble(),
);
