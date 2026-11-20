import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/widgets/left_drawer.dart';

/// Modul: Manajemen Barang
/// Penanggung jawab: Fauzan Taqiy Santosa (2506607272)
class DaftarBarangPage extends StatelessWidget {
  DaftarBarangPage({super.key});

  // Data dummy sementara, nanti diganti fetch dari API Django
  final List<Map<String, dynamic>> dummyBarang = [
    {
      'nama': 'Jas Almamater UI',
      'kategori': 'Pakaian & Formal',
      'jenis': 'gratis',
      'tarif': 0,
      'lokasi': 'Kutek',
      'status': 'aktif',
    },
    {
      'nama': 'Setrika Philips',
      'kategori': 'Elektronik Kost',
      'jenis': 'sewa',
      'tarif': 10000,
      'lokasi': 'Barel',
      'status': 'aktif',
    },
    {
      'nama': 'Koper Samsonite 24"',
      'kategori': 'Travel',
      'jenis': 'sewa',
      'tarif': 25000,
      'lokasi': 'Kukel',
      'status': 'aktif',
    },
  ];

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
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: navigasi ke TambahBarangPage
            },
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: dummyBarang.isEmpty
          ? const Center(
              child: Text('Belum ada barang. Tambahkan barang pertamamu!'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dummyBarang.length,
              itemBuilder: (context, index) {
                final barang = dummyBarang[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory_2,
                          color: Color(0xFF00897B)),
                    ),
                    title: Text(
                      barang['nama'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${barang['kategori']} · ${barang['lokasi']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: barang['jenis'] == 'gratis'
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            barang['jenis'] == 'gratis'
                                ? 'Gratis'
                                : 'Rp ${barang['tarif']}/hari',
                            style: TextStyle(
                              fontSize: 11,
                              color: barang['jenis'] == 'gratis'
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: navigasi ke DetailBarangPage
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: navigasi ke TambahBarangPage
        },
        backgroundColor: const Color(0xFF00897B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Barang',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
