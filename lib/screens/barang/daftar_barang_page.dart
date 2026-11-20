import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/widgets/left_drawer.dart';
import 'detail_barang_page.dart';
import 'tambah_barang_page.dart';

/// Modul: Manajemen Barang — Daftar Barang Saya
/// Penanggung jawab: Fauzan Taqiy Santosa (2506607272)
///
/// TODO (integrasi): Ganti _fetchBarang() dengan CookieRequest.get()
/// ke endpoint GET /barang/api/ setelah DRF aktif di PWS.
class DaftarBarangPage extends StatefulWidget {
  const DaftarBarangPage({super.key});

  @override
  State<DaftarBarangPage> createState() => _DaftarBarangPageState();
}

class _DaftarBarangPageState extends State<DaftarBarangPage> {
  late Future<List<Map<String, dynamic>>> _futureBarang;

  @override
  void initState() {
    super.initState();
    _futureBarang = _fetchBarang();
  }

  /// Simulasi async fetch — nanti diganti dengan HTTP call ke DRF API.
  Future<List<Map<String, dynamic>>> _fetchBarang() async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      {
        'id': 1,
        'nama': 'Jas Almamater UI',
        'kategori': 'Pakaian & Formal',
        'jenis': 'gratis',
        'tarif': 0,
        'lokasi': 'Kutek',
        'status': 'aktif',
        'deskripsi': 'Jas almamater UI ukuran M, kondisi baik. Cocok untuk acara wisuda atau sidang.',
      },
      {
        'id': 2,
        'nama': 'Setrika Philips',
        'kategori': 'Elektronik Kost',
        'jenis': 'sewa',
        'tarif': 10000,
        'lokasi': 'Barel',
        'status': 'aktif',
        'deskripsi': 'Setrika Philips 1000W, dilengkapi uap. Kondisi mulus, kabel tidak kusut.',
      },
      {
        'id': 3,
        'nama': 'Koper Samsonite 24"',
        'kategori': 'Travel',
        'jenis': 'sewa',
        'tarif': 25000,
        'lokasi': 'Kukel',
        'status': 'aktif',
        'deskripsi': 'Koper hardcase 24 inci warna hitam. Roda mulus, kunci TSA berfungsi.',
      },
    ];
  }

  void _refresh() {
    setState(() => _futureBarang = _fetchBarang());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barang Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00897B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah barang',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TambahBarangPage()),
            ).then((_) => _refresh()),
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureBarang,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)));
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 52, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat data barang'),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final barangList = snapshot.data ?? [];

          // Empty state
          if (barangList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada barang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tambahkan barang pertamamu!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TambahBarangPage()),
                    ).then((_) => _refresh()),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tambah Barang', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B)),
                  ),
                ],
              ),
            );
          }

          // List state
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            color: const Color(0xFF00897B),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: barangList.length,
              itemBuilder: (context, index) {
                final barang = barangList[index];
                return _BarangCard(
                  barang: barang,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailBarangPage(barang: barang),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahBarangPage()),
        ).then((_) => _refresh()),
        backgroundColor: const Color(0xFF00897B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Barang', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _BarangCard extends StatelessWidget {
  final Map<String, dynamic> barang;
  final VoidCallback onTap;

  const _BarangCard({required this.barang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isGratis = barang['jenis'] == 'gratis';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF00897B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2, color: Color(0xFF00897B)),
        ),
        title: Text(
          barang['nama'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${barang['kategori']} · ${barang['lokasi']}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isGratis ? Colors.green.shade100 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isGratis ? 'Gratis' : 'Rp ${barang['tarif']}/hari',
            style: TextStyle(
              fontSize: 11,
              color: isGratis ? Colors.green.shade700 : Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
