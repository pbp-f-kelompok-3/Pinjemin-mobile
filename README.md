# Pinjemin Mobile 📱

Aplikasi mobile yang memfasilitasi mahasiswa Universitas Indonesia dalam meminjamkan atau menyewakan barang kebutuhan kuliah, organisasi, dan kos — guna mengurangi penumpukan barang jarang terpakai dan pembelian berlebih.

Proyek ini merupakan versi mobile dari [Pinjemin Web](https://roisul-umam-pinjemin.pws.cs.ui.ac.id/) yang dibangun dengan Flutter, terhubung ke backend Django melalui Django REST Framework.

---

## Anggota Kelompok dan Pembagian Tugas

| NPM | Nama | Modul |
| :---: | :--- | :--- |
| **2506632910** | Alphard Qodaruddin | Manajemen Transaksi |
| **2506587876** | Chelsea Stania Passikha | Manajemen Kategori & Browse |
| **2506615993** | I Nyoman Yadnya Suta Karmana | Manajemen Lokasi & Peta |
| **2506607272** | Fauzan Taqiy Santosa | Manajemen Barang |
| **2506620210** | Roisul Umam | Manajemen Pengguna (Login & Profil) |

---

## Deskripsi Aplikasi

**Pinjemin** adalah platform berbagi dan peminjaman barang berbasis komunitas mahasiswa UI dengan tema *Sustainable Living*. Pengguna dapat:
- 🔍 **Menjelajahi** barang yang tersedia di sekitar kampus
- 📦 **Meminjamkan atau menyewakan** barang milik sendiri
- 🗺️ **Melihat lokasi** barang terdekat di peta
- 💳 **Bertransaksi** secara aman dengan sesama mahasiswa UI

---

## Peran / Aktor Pengguna

| Peran | Hak Akses |
| :--- | :--- |
| **Tamu** | Melihat beranda dan daftar barang secara terbatas |
| **Peminjam** | Login, memesan barang, melihat riwayat transaksi |
| **Pemilik Barang** | Menambah, mengedit, dan menghapus barang milik sendiri; melihat pesanan masuk |
| **Admin** | Mengelola kategori barang dan memantau aktivitas platform |

---

## Modul yang Diimplementasikan

### 1. Manajemen Pengguna (Roisul Umam)
Login via SSO UI, halaman profil, beralih mode Peminjam/Pemilik Barang.

### 2. Manajemen Kategori & Browse (Chelsea Stania Passikha)
Halaman utama/browse barang, filter berdasarkan kategori, harga, dan lokasi.

### 3. Manajemen Lokasi & Peta (I Nyoman Yadnya Suta Karmana)
Peta barang terdekat berbasis lokasi, detail lokasi penjemputan.

### 4. Manajemen Barang (Fauzan Taqiy Santosa)
Dashboard barang saya, tambah barang, edit barang, hapus barang.

### 5. Manajemen Transaksi (Alphard Qodaruddin)
Daftar pesanan, checkout, riwayat transaksi, status pembayaran.

---

## Alur Integrasi Mobile ↔ Web Django

```
Aplikasi Flutter (Mobile)
        |
        | HTTP Request + Cookie Session
        ↓
Django REST Framework (API Endpoints)
        |
        | QuerySet Django ORM
        ↓
Database PostgreSQL (di PWS)
```

Aplikasi Flutter berkomunikasi dengan backend Django di [https://roisul-umam-pinjemin.pws.cs.ui.ac.id/](https://roisul-umam-pinjemin.pws.cs.ui.ac.id/) melalui endpoint REST API yang dibangun dengan Django REST Framework. Autentikasi menggunakan cookie session yang dikelola oleh package `pbp_django_auth`.

---

## Link

- 🎨 **Figma:** https://www.figma.com/design/cIcomyuXpNiIPvk3Wa4gwo/Design-System?node-id=0-1&p=f&t=STwAfPD95yE7Ky2X-0
- 🌐 **Web PWS:** https://roisul-umam-pinjemin.pws.cs.ui.ac.id/
- 📦 **APK:** *(akan ditambahkan setelah build)*

---

## Cara Menjalankan Lokal

```bash
# Clone repo
git clone https://github.com/pbp-f-kelompok-3/Pinjemin-mobile
cd Pinjemin-mobile

# Install dependencies
flutter pub get

# Jalankan di Chrome (paling cepat)
flutter run -d chrome

# Atau di emulator Android
flutter run
```

**Requirements:** Flutter SDK ≥ 3.13, Dart SDK ≥ 3.13
