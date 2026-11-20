import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/widgets/left_drawer.dart';

/// Modul: Manajemen Kategori & Browse
/// Penanggung jawab: Chelsea Stania Passikha (2506587876)
class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jelajahi Barang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF57C00),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64, color: Color(0xFFF57C00)),
            SizedBox(height: 16),
            Text(
              'Jelajahi & Kategori Barang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Penanggung jawab: Chelsea Stania Passikha',
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
