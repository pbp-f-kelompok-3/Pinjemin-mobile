import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/widgets/left_drawer.dart';

/// Modul: Manajemen Barang — Detail Barang
/// Penanggung jawab: Fauzan Taqiy Santosa (2506607272)
class DetailBarangPage extends StatelessWidget {
  final Map<String, dynamic> barang;

  const DetailBarangPage({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    final bool isGratis = barang['jenis'] == 'gratis';
    final bool isAktif = barang['status'] == 'aktif';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          barang['nama'] ?? 'Detail Barang',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF00897B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.3)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 64, color: Color(0xFF00897B)),
                  SizedBox(height: 8),
                  Text('Foto Barang', style: TextStyle(color: Color(0xFF00897B))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nama & badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    barang['nama'] ?? '-',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAktif ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAktif ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAktif ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Harga
            Text(
              isGratis ? 'Gratis' : 'Rp ${barang['tarif']}/hari',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isGratis ? Colors.green.shade700 : const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Info rows
            _InfoRow(icon: Icons.category_outlined, label: 'Kategori', value: barang['kategori'] ?? '-'),
            _InfoRow(icon: Icons.location_on_outlined, label: 'Lokasi', value: barang['lokasi'] ?? '-'),
            _InfoRow(
              icon: isGratis ? Icons.card_giftcard : Icons.paid_outlined,
              label: 'Jenis',
              value: isGratis ? 'Pinjam Gratis' : 'Sewa Berbayar',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              barang['deskripsi'] ?? 'Belum ada deskripsi.',
              style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 32),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF00897B)),
                      foregroundColor: const Color(0xFF00897B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur edit akan hadir segera!')),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    label: const Text('Edit Barang', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00897B)),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
