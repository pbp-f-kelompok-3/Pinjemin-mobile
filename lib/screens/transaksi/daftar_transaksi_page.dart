import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/widgets/left_drawer.dart';

/// Modul: Manajemen Transaksi
/// Penanggung jawab: Alphard Qodaruddin (2506632910)
class DaftarTransaksiPage extends StatelessWidget {
  const DaftarTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Color(0xFF1976D2)),
            SizedBox(height: 16),
            Text(
              'Manajemen Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Penanggung jawab: Alphard Qodaruddin',
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
