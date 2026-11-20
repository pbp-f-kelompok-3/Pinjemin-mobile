import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/screens/menu.dart';
import 'package:pinjemin_mobile/screens/barang/daftar_barang_page.dart';
import 'package:pinjemin_mobile/screens/transaksi/daftar_transaksi_page.dart';
import 'package:pinjemin_mobile/screens/lokasi/peta_barang_page.dart';
import 'package:pinjemin_mobile/screens/kategori/browse_page.dart';
import 'package:pinjemin_mobile/screens/accounts/login_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Header drawer
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF00897B)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.swap_horiz, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text(
                  'Pinjemin',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Pinjam & sewa barang sesama mahasiswa UI',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Navigasi
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Beranda'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Jelajahi Barang'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const BrowsePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Barang Saya'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DaftarBarangPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Transaksi'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DaftarTransaksiPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Peta Barang'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const PetaBarangPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
