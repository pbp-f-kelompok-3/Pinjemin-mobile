import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../screens/barang/daftar_barang_page.dart';
import '../screens/help_center_screen.dart';
import '../screens/kategori/browse_page.dart';
import '../screens/lokasi/peta_barang_page.dart';
import '../screens/profile_screen.dart';
import '../screens/transaksi/daftar_transaksi_page.dart';
import '../services/session_provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  /// Opens [page] on top of the home screen, so drawer pages never pile up.
  static void _openFromHome(BuildContext context, Widget page) {
    final navigator = _backToHome(context);
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }

  /// Closes the drawer and pops back to the home screen, the first route
  /// (shown by AuthGate).
  static NavigatorState _backToHome(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    return navigator;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<SessionProvider>().profile;
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      (profile?.displayName ?? 'P')[0].toUpperCase(),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? 'Pinjemin',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (profile != null && profile.npm.isNotEmpty)
                          Text(
                            profile.npm,
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: colors.mutedText),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Beranda'),
              onTap: () => _backToHome(context),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Jelajahi Barang'),
              onTap: () => _openFromHome(context, const BrowsePage()),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Barang Saya'),
              onTap: () => _openFromHome(context, DaftarBarangPage()),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Transaksi'),
              onTap: () => _openFromHome(context, const DaftarTransaksiPage()),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Peta Barang'),
              onTap: () => _openFromHome(context, const PetaBarangPage()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () => _openFromHome(context, const ProfileScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Bantuan'),
              onTap: () => _openFromHome(context, const HelpCenterScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
