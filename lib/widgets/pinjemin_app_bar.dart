import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../services/session_provider.dart';

/// App bar with the Pinjemin logo and a small chip showing the active mode.
class PinjeminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PinjeminAppBar({super.key, this.title});

  /// Optional page name; the logo is shown when null.
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(title!)
          : Image.asset(
              'assets/images/logo.png',
              height: 28,
              semanticLabel: 'Pinjemin',
            ),
      actions: const [
        Padding(padding: EdgeInsets.only(right: 16), child: ModeChip()),
      ],
    );
  }
}

class ModeChip extends StatelessWidget {
  const ModeChip({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.watch<SessionProvider>().modeLabel;
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;
    return Semantics(
      label: 'Mode aktif: $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.softYellow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge!.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}
