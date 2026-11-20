import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/auth_service.dart';

/// Opens the SSO UI login page and pops with the ticket once SSO UI redirects
/// to the mobile callback URL. Pops with null when the user goes back.
class SsoWebViewScreen extends StatefulWidget {
  const SsoWebViewScreen({
    super.key,
    required this.loginUrl,
    required this.callbackPrefix,
  });

  final String loginUrl;
  final String callbackPrefix;

  @override
  State<SsoWebViewScreen> createState() => _SsoWebViewScreenState();
}

class _SsoWebViewScreenState extends State<SsoWebViewScreen> {
  late final WebViewController _controller;
  bool _finished = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Catches the redirect before the page loads
          onNavigationRequest: (request) => _catchTicket(request.url)
              ? NavigationDecision.prevent
              : NavigationDecision.navigate,
          // Fallback: Android may skip onNavigationRequest for a redirect after
          // a POST. Loading the callback page is harmless because the server
          // does not validate the ticket there.
          onPageStarted: _catchTicket,
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.loginUrl));
  }

  bool _catchTicket(String url) {
    final ticket = ticketFromCallbackUrl(url, widget.callbackPrefix);
    if (ticket == null) return false;
    if (!_finished && mounted) {
      _finished = true;
      Navigator.of(context).pop(ticket);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login SSO UI')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
