import 'package:flutter/material.dart';

import '../../models/location.dart';
import '../../services/auth_service.dart';
import '../../services/location_api.dart';
import 'pickup_location_form.dart';

class SavedLocationsPage extends StatefulWidget {
  const SavedLocationsPage({super.key, required this.api});

  final LocationApi api;

  @override
  State<SavedLocationsPage> createState() => _SavedLocationsPageState();
}

class _SavedLocationsPageState extends State<SavedLocationsPage> {
  late Future<List<PickupLocation>> _locations;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _locations = widget.api.savedLocations();
  }

  void _reload() => setState(() => _locations = widget.api.savedLocations());

  Future<void> _openForm([PickupLocation? location]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PickupLocationForm(api: widget.api, location: location),
      ),
    );
    if (mounted && saved == true) _reload();
  }

  Future<void> _delete(PickupLocation location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus lokasi?'),
        content: Text('Hapus ${location.label} dari lokasi tersimpan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await widget.api.delete(location.id);
      if (mounted) _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Tersimpan')),
      body: FutureBuilder<List<PickupLocation>>(
        future: _locations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error is ApiException
                          ? error.message
                          : kBadResponseMessage,
                    ),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final locations = snapshot.data!;
          if (locations.isEmpty) {
            return const Center(
              child: Text('Kamu belum punya lokasi tersimpan.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(location.label),
                  subtitle: Text(location.address),
                  onTap: _deleting ? null : () => _openForm(location),
                  trailing: IconButton(
                    tooltip: 'Hapus lokasi',
                    onPressed: _deleting ? null : () => _delete(location),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _deleting ? null : _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Tambah lokasi'),
      ),
    );
  }
}
