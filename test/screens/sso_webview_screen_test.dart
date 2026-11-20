import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/screens/login_screen.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../helpers/fake_webview.dart';
import '../helpers/fakes.dart';

void main() {
  const loginUrl = 'https://sso.ui.ac.id/cas2/login?service=x';
  final callback = api('/akun/api/sso/callback/');
  late FakeWebViewPlatform platform;

  setUpAll(setUpTestEnvironment);
  setUp(() {
    platform = FakeWebViewPlatform();
    WebViewPlatform.instance = platform;
  });

  /// Opens the SSO screen from a button and records what it pops with.
  Future<List<String?>> openSso(WidgetTester tester) async {
    final results = <String?>[];
    await tester.pumpWidget(
      wrapWithApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  results.add(await openSsoWebView(context, loginUrl, callback)),
              child: const Text('open'),
            ),
          ),
        ),
        request: FakeCookieRequest(),
      ),
    );
    await tester.tap(find.text('open'));
    // The progress bar animates forever, so pump the route transition by time
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return results;
  }

  testWidgets('loads the SSO login page with a progress bar', (tester) async {
    await openSso(tester);

    expect(find.text('Login SSO UI'), findsOneWidget);
    expect(platform.lastController!.loadedUri, Uri.parse(loginUrl));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    platform.lastDelegate!.onPageFinished!(loginUrl);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('lets normal SSO pages through', (tester) async {
    await openSso(tester);

    final decision = await platform.lastDelegate!.onNavigationRequest!(
      const NavigationRequest(url: 'https://sso.ui.ac.id/cas2/login', isMainFrame: true),
    );
    expect(decision, NavigationDecision.navigate);
    expect(find.text('Login SSO UI'), findsOneWidget);
  });

  testWidgets('catches the callback redirect and pops with the ticket', (tester) async {
    final results = await openSso(tester);

    final decision = await platform.lastDelegate!.onNavigationRequest!(
      NavigationRequest(url: '$callback?ticket=ST-7', isMainFrame: true),
    );
    // A second signal for the same redirect must not pop twice
    platform.lastDelegate!.onPageStarted!('$callback?ticket=ST-7');
    await tester.pumpAndSettle();

    expect(decision, NavigationDecision.prevent);
    expect(results, ['ST-7']);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('falls back to onPageStarted when the redirect is not reported', (tester) async {
    final results = await openSso(tester);

    platform.lastDelegate!.onPageStarted!('$callback?ticket=ST-8');
    await tester.pumpAndSettle();

    expect(results, ['ST-8']);
  });

  testWidgets('going back returns null', (tester) async {
    final results = await openSso(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(results, [null]);
  });
}
