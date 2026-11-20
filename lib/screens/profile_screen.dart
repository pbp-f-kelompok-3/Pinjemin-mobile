import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/profile.dart';
import '../services/session_provider.dart';
import '../widgets/left_drawer.dart';
import '../widgets/pinjemin_app_bar.dart';

/// The logged-in user's own profile, read from [SessionProvider].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<SessionProvider>().profile;

    return Scaffold(
      appBar: const PinjeminAppBar(title: 'Profil'),
      drawer: const LeftDrawer(),
      body: profile == null
          ? const Center(child: Text('Profil belum dimuat. Coba buka lagi.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                _ProfileHeader(profile: profile),
                const SizedBox(height: 24),
                _CompletenessCard(completeness: profile.completeness),
                const SizedBox(height: 16),
                _AboutCard(profile: profile),
              ],
            ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.radius = 44});

  final Profile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = profile.photoUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      onForegroundImageError: photoUrl != null ? (_, _) {} : null,
      child: Text(
        profile.displayName[0].toUpperCase(),
        style: theme.textTheme.headlineMedium,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;
    final details = [
      if (profile.npm.isNotEmpty) profile.npm,
      if (profile.angkatan != null) 'Angkatan ${profile.angkatan}',
    ].join(' · ');

    return Column(
      children: [
        ProfileAvatar(profile: profile),
        const SizedBox(height: 12),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            details,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(color: colors.mutedText),
          ),
        ],
      ],
    );
  }
}

class _CompletenessCard extends StatelessWidget {
  const _CompletenessCard({required this.completeness});

  final Completeness completeness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Kelengkapan profil', style: theme.textTheme.titleMedium),
                ),
                Text('${completeness.percent}%', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: completeness.percent / 100,
                minHeight: 8,
                backgroundColor: colors.panelFill,
                semanticsLabel: 'Kelengkapan profil',
              ),
            ),
            const SizedBox(height: 12),
            for (final check in completeness.checks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      check.done ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                      size: 20,
                      color: check.done ? colors.positive : colors.mutedText,
                      semanticLabel: check.done ? 'Sudah' : 'Belum',
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(check.label, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tentang kamu', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.phone_outlined, label: 'WhatsApp', value: profile.phone),
            _InfoRow(
              icon: Icons.place_outlined,
              label: 'Titik temu favorit',
              value: profile.location,
            ),
            _InfoRow(icon: Icons.notes_outlined, label: 'Bio', value: profile.bio),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;
    final empty = value.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.mutedText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  empty ? 'Belum diisi' : value,
                  style: empty
                      ? theme.textTheme.bodyMedium!.copyWith(color: colors.mutedText)
                      : theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
