import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../services/auth_service.dart';
import '../services/session_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// First route of the app. Checks the stored session once, then shows the
/// login or home screen depending on [SessionProvider].
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<Profile?> _restore;

  @override
  void initState() {
    super.initState();
    _restore = _restoreSession();
  }

  Future<Profile?> _restoreSession() async {
    final session = context.read<SessionProvider>();
    final profile =
        await AuthService(context.read<CookieRequest>()).restoreSession();
    if (profile != null) session.setProfile(profile);
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<SessionProvider>().isLoggedIn;

    return FutureBuilder<Profile?>(
      future: _restore,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? snapshot.error.toString()
              : kNetworkErrorMessage;
          return _RestoreError(
            message: message,
            onRetry: () => setState(() {
              _restore = _restoreSession();
            }),
          );
        }
        return loggedIn ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}

class _RestoreError extends StatelessWidget {
  const _RestoreError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
