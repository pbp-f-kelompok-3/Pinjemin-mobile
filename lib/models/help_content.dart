// Static Help Center content, kept in sync by hand with the web page
// (templates/help_center/help.html in the Django repo). There is no endpoint.

class HelpStep {
  const HelpStep(this.title, this.body);

  final String title;
  final String body;
}

class PolicySection {
  const PolicySection(this.title, {this.intro, this.points = const []});

  final String title;
  final String? intro;
  final List<String> points;
}

class FaqItem {
  const FaqItem(this.question, this.answer);

  final String question;
  final String answer;
}

const borrowSteps = [
  HelpStep(
    'Login dengan SSO UI',
    'Verifikasi otomatis tanpa perlu upload KTP. Cukup masuk dengan akun mahasiswa '
        'aktif untuk membuka katalog barang.',
  ),
  HelpStep(
    'Cari dan ajukan pinjaman',
    'Filter berdasarkan titik temu terdekat (Kantin Fasilkom, Kansas, Pocin, Kutek, dan '
        'lainnya). Tentukan tanggal pinjam lalu pilih barang gratis atau dengan harga '
        'sewa bersahabat.',
  ),
  HelpStep(
    'Sepakati titik temu',
    'Pilih titik kumpul resmi yang terawasi, misalnya Perpustakaan Pusat, Kantin FT, '
        'Selasar RIK, atau Stasiun UI. Cek kondisi barang bersama pemiliknya.',
  ),
  HelpStep(
    'Scan QR pengembalian',
    'Saat masa pinjam selesai, temui pemilik di titik yang sama. Scan QR konfirmasi '
        'serah terima, lalu beri review untuk reputasi pemilik.',
  ),
];

const lendSteps = [
  HelpStep(
    'Pindah ke mode Minjemin',
    'Ganti mode dari Minjem ke Minjemin, lalu lengkapi nomor WhatsApp di profil kamu.',
  ),
  HelpStep(
    'Unggah barang',
    'Tambahkan foto, nama, deskripsi, dan kondisi barang. Tentukan apakah barang '
        'dipinjamkan gratis atau disewakan dengan harga bersahabat.',
  ),
  HelpStep(
    'Setujui dan sepakati titik temu',
    'Tinjau permintaan yang masuk, setujui peminjam yang sesuai, lalu tentukan titik '
        'kumpul resmi untuk serah terima barang.',
  ),
  HelpStep(
    'Konfirmasi pengembalian',
    'Setelah barang kembali, cek kondisinya bersama peminjam, konfirmasi lewat QR, lalu '
        'beri review untuk membangun reputasi.',
  ),
];

const policyUpdatedAt = 'Terakhir diperbarui: 12 Oktober 2026 (Revisi V2.3)';

const policyIntro =
    'Pinjemin adalah platform berbagi dan menyewakan barang khusus mahasiswa Universitas '
    'Indonesia. Supaya semuanya aman, adil, dan ramah lingkungan, setiap pengguna wajib '
    'memahami dan mematuhi kebijakan berikut.';

const policySections = [
  PolicySection(
    'Verifikasi akun dan identitas',
    intro: 'Akun Pinjemin hanya bisa dibuat dan diakses lewat SSO UI. Nama, NPM, dan status '
        'kemahasiswaan diambil otomatis dari SSO. Pinjemin tidak pernah menyimpan kata '
        'sandi SSO kamu.',
    points: [
      'Satu mahasiswa hanya boleh memiliki satu akun.',
      'Dilarang membagikan akun atau akses login kepada orang lain.',
      'Informasi kontak hanya ditampilkan kepada pihak yang terlibat dalam transaksi yang '
          'disetujui.',
    ],
  ),
  PolicySection(
    'Ketentuan barang dan kategori',
    intro: 'Barang yang diizinkan: kebutuhan kuliah, kegiatan organisasi atau kampus, '
        'perlengkapan kos, alat elektronik, koper, hingga pakaian formal atau jas sidang. '
        'Barang yang dilarang:',
    points: [
      'Narkotika, obat-obatan terlarang, dan minuman beralkohol.',
      'Senjata tajam, senjata api, atau bahan peledak.',
      'Dokumen pribadi resmi (KTP, SIM, KTM asli) atau barang bernilai sangat tinggi yang '
          'berisiko ekstrem.',
      'Barang ilegal, bajakan, atau yang melanggar hukum dan norma kampus.',
    ],
  ),
  PolicySection(
    'Tata cara transaksi dan penjemputan',
    points: [
      'Seluruh transaksi dilakukan lewat Pinjemin supaya tercatat dan terlindungi.',
      'Serah terima dilakukan di titik temu resmi kampus yang terawasi.',
      'Cek kondisi barang bersama sebelum dan sesudah masa pinjam.',
      'Pengembalian dikonfirmasi lewat pemindaian QR oleh kedua pihak.',
    ],
  ),
  PolicySection(
    'Tanggung jawab kerusakan dan keterlambatan',
    points: [
      'Peminjam bertanggung jawab atas barang selama masa pinjam, termasuk kerusakan atau '
          'kehilangan di luar pemakaian wajar.',
      'Keterlambatan pengembalian wajib dikabarkan ke pemilik sebelum batas waktu berakhir.',
      'Kerusakan yang sudah ada sebelum masa pinjam wajib dicatat saat pengecekan bersama.',
    ],
  ),
  PolicySection(
    'Sanksi dan mediasi sengketa',
    points: [
      'Pelanggaran dapat dikenai peringatan, pembatasan fitur, hingga penangguhan akun.',
      'Jika terjadi sengketa, kedua pihak dapat menghubungi Tim Support Pinjemin untuk '
          'mediasi.',
      'Keputusan mediasi didasarkan pada riwayat transaksi, bukti foto, dan hasil '
          'pengecekan bersama.',
    ],
  ),
];

const faqItems = [
  FaqItem(
    'Apakah semua mahasiswa UI bisa langsung bertransaksi di Pinjemin?',
    'Bisa. Cukup login dengan akun SSO UI dan lengkapi nomor WhatsApp aktif.',
  ),
  FaqItem(
    'Bagaimana kalau barang yang kamu pinjam rusak?',
    'Segera laporkan ke pemilik barang dan diskusikan opsi perbaikannya. Kalau belum ada '
        'jalan keluar, hubungi Tim Mediasi dan Bantuan Pinjemin.',
  ),
  FaqItem(
    'Bisakah kamu membatalkan pesanan sewa yang sudah dibayar?',
    'Bisa, selama masa pinjam belum dimulai, lewat menu Riwayat Pesanan.',
  ),
  FaqItem(
    'Apakah ada asuransi resmi dari Pinjemin?',
    'Saat ini transaksi dilindungi oleh sistem Deposit Escrow dan Kode Etik Kemahasiswaan '
        'UI. Untuk barang super premium (di atas Rp 10 juta), kamu bisa mengaktifkan '
        'asuransi mikro mitra kampus dengan premi Rp 5.000 per hari saat checkout.',
  ),
];
