# Pinjemin Mobile

Pinjemin Mobile adalah aplikasi Flutter untuk pinjam dan sewa barang antar mahasiswa Universitas Indonesia. Barang yang hanya dibutuhkan sesekali, seperti kabel rol untuk acara atau koper untuk pulang, bisa dipinjam dari mahasiswa lain. Lewat Pinjemin, barang yang jarang dipakai bisa dimanfaatkan bersama. Ide ini kami bawa dari proyek web Pinjemin bertema *Sustainable Living*.

Repo ini memuat beranda dan halaman untuk lima modul. Drawer mengarah ke halaman awal yang tercantum di bawah. Barang Saya masih menampilkan data contoh.

## Anggota Kelompok dan Pembagian Modul

| NPM | Nama | Modul | Halaman awal |
| --- | --- | --- | --- |
| 2506620210 | Roisul Umam | Manajemen Pengguna | Masuk |
| 2506587876 | Chelsea Stania Passikha | Manajemen Kategori | Jelajahi Barang (kerangka Kategori) |
| 2506607272 | Fauzan Taqiy Santosa | Manajemen Barang | Barang Saya |
| 2506615993 | I Nyoman Yadnya Suta Karmana | Manajemen Lokasi | Peta Barang |
| 2506632910 | Alphard Qodaruddin | Manajemen Transaksi | Transaksi |

## Modul Aplikasi

Ini cakupan fitur yang dirancang untuk setiap modul. Penanggung jawab modul mengerjakan halaman Flutter beserta serializer dan view atau viewset Django REST Framework untuk data yang dikelolanya.

### Manajemen Pengguna

Halaman Masuk mengikuti alur login di situs Pinjemin. Di halaman Profil, pengguna bisa melihat data akun, mengubah nomor WhatsApp, beralih antara mode Peminjam dan Pemilik Barang, atau keluar.

### Manajemen Kategori

Halaman Kategori menampilkan daftar kategori barang. Admin punya halaman Kelola Kategori untuk menambah, mengganti nama, atau menghapus kategori. Kategori yang tersimpan dapat dipilih sebagai filter di katalog.

### Manajemen Barang

Pengunjung bisa menyaring katalog di Jelajahi Barang dan membuka Detail Barang. Dari Barang Saya, pemilik bisa menambah, mengedit, atau menghapus barangnya. Formulir barang memuat foto, deskripsi, jenis pinjam atau sewa, dan tarif. Pilihan kategori dan titik jemput diambil dari data yang sudah tersimpan di Django.

### Manajemen Lokasi

**Peta Barang** dapat dibuka dari drawer. Cakupan modul ini adalah pencarian barang dalam radius 1 atau 2 km dari titik yang dipilih di peta, serta pengelolaan titik penjemputan di **Lokasi Tersimpan**. Setiap lokasi memiliki label, alamat, dan koordinat. Titik barang yang muncul di hasil pencarian menunjukkan lokasi perkiraan.

### Manajemen Transaksi

Peminjam memilih jadwal dan durasi di Checkout, lalu melihat biaya, status pembayaran, dan titik jemput di Detail Pesanan. Pesanan sebelumnya dapat dibuka lewat Riwayat. Dari Pesanan Masuk, pemilik bisa menindaklanjuti permintaan pinjam, serah terima, dan pengembalian.

## Peran Pengguna

| Peran | Hak akses |
| --- | --- |
| Tamu | Melihat beranda, menjelajahi katalog, dan membuka informasi umum barang. |
| Peminjam | Membuat pesanan, melihat riwayat dan statusnya, serta melihat titik penjemputan untuk pesanannya. |
| Pemilik Barang | Mengelola barang sendiri dan lokasi tersimpan, serta menindaklanjuti pesanan yang masuk. |
| Admin | Menambah, mengubah, dan menghapus kategori barang. |

Peminjam dan Pemilik Barang adalah dua mode pada akun yang sama. Hak akses setiap aksi diperiksa di Django.

## Integrasi Flutter dan Django

**Django REST Framework (DRF)** adalah pustaka di Django untuk membuat API. Flutter akan memanggil API ini untuk membaca dan memperbarui barang, lokasi, dan pesanan. Data tersebut tetap disimpan di database yang sama dengan situs web Pinjemin dari Proyek Tengah Semester.

Saat halaman dibuka atau pengguna menekan tombol, Flutter mengirim permintaan HTTP secara asinkron. View atau viewset di Django memeriksa hak akses, lalu membaca data atau menyimpan perubahan setelah input divalidasi oleh serializer. Flutter membaca respons JSON dari API untuk memperbarui tampilan.

Contohnya, saat pemilik membuka **Lokasi Tersimpan**, Flutter mengambil daftar lokasi dengan `GET /api/lokasi-penjemputan/`. Ketika pemilik memilih titik di peta dan menekan **Simpan**, Flutter mengirim label, alamat, dan koordinat lewat `POST` ke rute yang sama. Setelah Django menyimpan lokasi, Flutter menambahkannya ke daftar berdasarkan respons API. Lokasi itu juga muncul di situs Pinjemin ketika pemilik masuk dengan akun yang sama.

### Endpoint DRF

Alamat lengkap endpoint terdiri dari alamat server Django dan path API, misalnya `<alamat-server-django>/api/lokasi-penjemputan/`. Ketiga rute modul **Lokasi** sudah berjalan di Django lokal dan diuji melalui permintaan HTTP dari klien Flutter. Rute modul lain di tabel ini masih berupa rancangan integrasi.

| Modul | Rute | Metode | Fungsi |
| --- | --- | --- | --- |
| Pengguna | `/api/akun/login/`, `/api/akun/logout/` | `POST` | Masuk dan keluar dari akun. |
| Pengguna | `/api/akun/profil/` | `GET`, `PATCH` | Membaca atau memperbarui profil. |
| Kategori | `/api/kategori/` | `GET`, `POST` | Melihat daftar atau menambah kategori. |
| Kategori | `/api/kategori/{id}/` | `PATCH`, `DELETE` | Mengubah atau menghapus kategori. |
| Barang | `/api/barang/` | `GET`, `POST` | Melihat katalog atau menambah barang. |
| Barang | `/api/barang/{id}/` | `GET`, `PATCH`, `DELETE` | Melihat detail, mengubah, atau menghapus barang. |
| Barang | `/api/barang/pilihan-form/` | `GET` | Mengambil pilihan kategori dan titik jemput untuk formulir barang. |
| Lokasi | `/api/lokasi-penjemputan/` | `GET`, `POST` | Melihat atau menambah lokasi tersimpan milik akun. |
| Lokasi | `/api/lokasi-penjemputan/{id}/` | `PATCH`, `DELETE` | Mengubah atau menghapus lokasi tersimpan. |
| Lokasi | `/api/barang-terdekat/` | `GET` | Mencari barang berdasarkan koordinat dan radius. |
| Transaksi | `/api/pesanan/` | `GET`, `POST` | Melihat daftar pesanan atau membuat pesanan. |
| Transaksi | `/api/pesanan/{id}/` | `GET`, `PATCH` | Melihat detail, termasuk status pembayaran, atau memperbarui status pesanan. |

### Layanan Eksternal

- **SSO UI** digunakan untuk login melalui WebView di Flutter. Django memvalidasi tiket SSO dan membuat sesi untuk endpoint yang memerlukan login.
- **OpenStreetMap** menyediakan peta dasar untuk Peta Barang dan pemilihan titik penjemputan di Flutter. Daftar barang terdekat dan lokasi tersimpan diambil dari endpoint DRF Pinjemin.


## Tautan

- [Acuan desain Pinjemin di Figma](https://www.figma.com/design/cIcomyuXpNiIPvk3Wa4gwo/Design-System?node-id=0-1&p=f&t=STwAfPD95yE7Ky2X-0)
- Tautan APK menyusul setelah rilis.

## Menjalankan Aplikasi Secara Lokal

Gunakan Flutter SDK yang menyertakan Dart 3.13.7 atau versi 3.x yang lebih baru, sesuai `pubspec.yaml`. Dari folder repo, jalankan perintah berikut dengan emulator Android atau perangkat yang sudah terhubung.

```bash
flutter pub get
flutter run
```

Untuk membuka kerangka aplikasi di Chrome, gunakan `flutter run -d chrome`.

Server Django yang dipakai Flutter perlu menjalankan versi backend yang memuat endpoint Lokasi. Pengujian endpoint dapat dijalankan dari repo Django dengan `python manage.py test locations.test_api`. Di repo Flutter, jalankan `flutter test test/widgets/navigation_test.dart` untuk memeriksa navigasi.
