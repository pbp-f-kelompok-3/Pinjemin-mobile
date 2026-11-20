import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/widgets/left_drawer.dart';

/// Modul: Manajemen Lokasi
/// Penanggung jawab: I Nyoman Yadnya Suta Karmana (2506615993)
class PetaBarangPage extends StatelessWidget {
  const PetaBarangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Peta Barang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7B1FA2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Color(0xFF7B1FA2)),
            SizedBox(height: 16),
            Text(
              'Peta Barang Terdekat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Penanggung jawab: I Nyoman Yadnya Suta Karmana',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              '— Coming Soon —',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
