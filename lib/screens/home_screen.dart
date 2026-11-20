import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session_provider.dart';
import '../widgets/left_drawer.dart';
import '../widgets/pinjemin_app_bar.dart';

/// Landing page after login. The catalogue modules plug in here later.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const PinjeminAppBar(),
      drawer: const LeftDrawer(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(
            'Halo, ${session.profile?.firstName ?? ''}',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            session.isSeller
                ? 'Kamu sedang di mode Minjemin.'
                : 'Kamu sedang di mode Minjem.',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
