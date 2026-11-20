import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/location.dart';
import '../../services/auth_service.dart';
import '../../services/location_api.dart';
import 'location_map.dart';

class PickupLocationForm extends StatefulWidget {
  const PickupLocationForm({super.key, required this.api, this.location});

  final LocationApi api;
  final PickupLocation? location;

  @override
  State<PickupLocationForm> createState() => _PickupLocationFormState();
}

class _PickupLocationFormState extends State<PickupLocationForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _label;
  late final TextEditingController _address;
  LatLng? _point;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.location?.label);
    _address = TextEditingController(text: widget.location?.address);
    _point = widget.location?.point;
  }

  @override
  void dispose() {
    _label.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final valid = _form.currentState!.validate();
    final point = _point;
    if (point == null) {
      setState(() => _error = 'Pilih titik penjemputan di peta.');
      return;
    }
    if (!valid) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.save(
        id: widget.location?.id,
        label: _label.text.trim(),
        address: _address.text.trim(),
        point: point,
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location == null ? 'Tambah lokasi' : 'Edit lokasi'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _label,
              enabled: !_saving,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Label lokasi'),
              validator: (text) =>
                  text!.trim().isEmpty ? 'Isi label lokasi.' : null,
            ),
            TextFormField(
              controller: _address,
              enabled: !_saving,
              maxLength: 255,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat penjemputan',
              ),
              validator: (text) =>
                  text!.trim().isEmpty ? 'Isi alamat penjemputan.' : null,
            ),
            const SizedBox(height: 8),
            const Text('Ketuk peta untuk memilih titik penjemputan.'),
            const SizedBox(height: 8),
            LocationMap(
              initialCenter: widget.location?.point ?? campusCenter,
              point: _point,
              onPointSelected: (point) {
                if (_saving) return;
                FocusScope.of(context).unfocus();
                setState(() {
                  _point = point;
                  _error = null;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_error case final error?)
              Text(error, style: TextStyle(color: theme.colorScheme.error)),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Menyimpan…' : 'Simpan lokasi'),
            ),
          ],
        ),
      ),
    );
  }
}
