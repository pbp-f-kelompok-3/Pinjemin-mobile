import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modul: Manajemen Barang — Tambah Barang
/// Penanggung jawab: Fauzan Taqiy Santosa (2506607272)
///
/// TODO (integrasi): Hubungkan ke endpoint POST /barang/api/ setelah
/// DRF endpoint aktif di PWS. Gunakan CookieRequest dari pbp_django_auth.
class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final _formKey = GlobalKey<FormState>();

  // Field controllers
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tarifController = TextEditingController();

  String _jenisPenawaran = 'gratis';
  String _statusPenawaran = 'aktif';
  bool _isLoading = false;

  static const List<String> _kategoriOptions = [
    'Elektronik Kost',
    'Pakaian & Formal',
    'Buku & Alat Tulis',
    'Peralatan Rumah',
    'Travel',
    'Olahraga',
    'Lainnya',
  ];

  static const List<String> _lokasiOptions = [
    'Kutek',
    'Barel',
    'Kukel',
    'Mako',
    'Wisma Makara',
    'Lainnya',
  ];

  String? _kategoriPilihan;
  String? _lokasiPilihan;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _tarifController.dispose();
    super.dispose();
  }

  Future<void> _simpanBarang() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi delay network — TODO: ganti dengan CookieRequest.post()
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barang berhasil ditambahkan! (simulasi)'),
        backgroundColor: Color(0xFF00897B),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Barang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00897B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(label: 'Informasi Barang'),
              const SizedBox(height: 12),

              // Nama barang
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang *',
                  hintText: 'Contoh: Koper Samsonite 24"',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nama barang wajib diisi';
                  if (val.trim().length < 3) return 'Minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi *',
                  hintText: 'Jelaskan kondisi, kelengkapan, dan aturan peminjaman...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 72),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Deskripsi wajib diisi';
                  if (val.trim().length < 10) return 'Minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Kategori
              DropdownButtonFormField<String>(
                initialValue: _kategoriPilihan,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _kategoriOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (val) => setState(() => _kategoriPilihan = val),
                validator: (val) => val == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 14),

              // Lokasi
              DropdownButtonFormField<String>(
                initialValue: _lokasiPilihan,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Penjemputan *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _lokasiOptions
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) => setState(() => _lokasiPilihan = val),
                validator: (val) => val == null ? 'Pilih lokasi' : null,
              ),
              const SizedBox(height: 20),

              _SectionHeader(label: 'Jenis Penawaran'),
              const SizedBox(height: 12),

              // Toggle gratis / sewa
              Row(
                children: [
                  Expanded(
                    child: _JenisCard(
                      label: 'Gratis',
                      icon: Icons.card_giftcard,
                      selected: _jenisPenawaran == 'gratis',
                      onTap: () => setState(() {
                        _jenisPenawaran = 'gratis';
                        _tarifController.clear();
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _JenisCard(
                      label: 'Sewa',
                      icon: Icons.paid_outlined,
                      selected: _jenisPenawaran == 'sewa',
                      onTap: () => setState(() => _jenisPenawaran = 'sewa'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tarif (hanya tampil kalau sewa)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _jenisPenawaran == 'sewa'
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: TextFormField(
                  controller: _tarifController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Tarif per Hari (Rp) *',
                    hintText: '0',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (_jenisPenawaran == 'sewa') {
                      if (val == null || val.isEmpty) return 'Tarif wajib diisi untuk barang sewa';
                      final tarif = int.tryParse(val);
                      if (tarif == null || tarif <= 0) return 'Tarif harus lebih dari Rp 0';
                    }
                    return null;
                  },
                ),
                secondChild: const SizedBox.shrink(),
              ),
              if (_jenisPenawaran == 'sewa') const SizedBox(height: 14),

              // Status penawaran
              _SectionHeader(label: 'Status Penawaran'),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Aktif Ditawarkan'),
                subtitle: Text(
                  _statusPenawaran == 'aktif'
                      ? 'Barang terlihat oleh peminjam'
                      : 'Barang disembunyikan sementara',
                  style: const TextStyle(fontSize: 12),
                ),
                value: _statusPenawaran == 'aktif',
                activeThumbColor: const Color(0xFF00897B),
                onChanged: (val) =>
                    setState(() => _statusPenawaran = val ? 'aktif' : 'nonaktif'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),

              // Tombol simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _simpanBarang,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Menyimpan...' : 'Simpan Barang',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
    );
  }
}

class _JenisCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _JenisCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00897B) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF00897B) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
