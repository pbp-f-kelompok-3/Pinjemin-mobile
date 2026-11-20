import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/session_provider.dart';
import '../widgets/soft_blobs.dart';
import 'sso_webview_screen.dart';

/// Opens the SSO UI page and resolves with the ticket, or null if cancelled.
typedef SsoLauncher = Future<String?> Function(
  BuildContext context,
  String loginUrl,
  String callbackPrefix,
);

Future<String?> openSsoWebView(
  BuildContext context,
  String loginUrl,
  String callbackPrefix,
) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => SsoWebViewScreen(
        loginUrl: loginUrl,
        callbackPrefix: callbackPrefix,
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.launchSso = openSsoWebView});

  final SsoLauncher launchSso;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final auth = AuthService(context.read<CookieRequest>());
    final session = context.read<SessionProvider>();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final loginUrl = await auth.fetchLoginUrl();
      if (!mounted) return;
      final ticket = await widget.launchSso(
        context,
        loginUrl,
        auth.callbackPrefix,
      );
      if (ticket == null) return; // user closed the SSO page
      final profile = await auth.exchangeTicket(ticket);
      session.setProfile(profile);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SoftBlobs(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 56,
                      semanticLabel: 'Pinjemin',
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Masuk ke Pinjemin',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pinjam dan pinjamkan barang sesama mahasiswa UI.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      _ErrorBanner(message: _error!),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _login,
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_outlined),
                      label: Text(
                        _loading ? 'Menghubungkan...' : 'Masuk dengan SSO UI',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Khusus mahasiswa Universitas Indonesia. Akunmu dibuat '
                      'otomatis saat pertama kali masuk.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium!.copyWith(color: error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
