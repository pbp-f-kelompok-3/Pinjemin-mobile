import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'screens/auth_gate.dart';
import 'services/session_provider.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const PinjeminApp());
}

/// Brand colours that have no slot in [ColorScheme]. Read them with
/// `Theme.of(context).extension<PinjeminColors>()!`.
@immutable
class PinjeminColors extends ThemeExtension<PinjeminColors> {
  const PinjeminColors({
    required this.softYellow,
    required this.warmText,
    required this.mutedText,
    required this.hairline,
    required this.fieldFill,
    required this.panelFill,
    required this.segmentTrack,
    required this.positive,
    required this.positiveContainer,
  });

  final Color softYellow;
  final Color warmText;
  final Color mutedText;
  final Color hairline;
  final Color fieldFill;
  final Color panelFill;
  final Color segmentTrack;
  final Color positive;
  final Color positiveContainer;

  static const PinjeminColors light = PinjeminColors(
    softYellow: Color(0xFFF7E9A0),
    warmText: Color(0xFF4A4535),
    mutedText: Color(0xFF6B6B6B),
    hairline: Color(0xFFECE9EA),
    fieldFill: Color(0xFFF4F3F4),
    panelFill: Color(0xFFEEEDED),
    segmentTrack: Color(0xFFF3F3F3),
    positive: Color(0xFF14783A),
    positiveContainer: Color(0xFFDFF5E6),
  );

  @override
  PinjeminColors copyWith() => this;

  @override
  PinjeminColors lerp(ThemeExtension<PinjeminColors>? other, double t) => this;
}

class PinjeminTheme {
  static const Color brandYellow = Color(0xFFFFE100);
  static const Color ink = Color(0xFF1C1C1C);
  static const Color pageBackground = Color(0xFFF8F6F7);
  static const Color error = Color(0xFFC4161C);

  /// Field border at rest: 3.1:1 against the field fill, so empty fields stay visible.
  static const Color fieldOutline = Color(0xFF8A8A8A);

  static ThemeData build() {
    const colors = PinjeminColors.light;
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: brandYellow,
      onPrimary: ink,
      primaryContainer: Color(0xFFF7E9A0),
      onPrimaryContainer: ink,
      secondary: ink,
      onSecondary: Colors.white,
      tertiary: Color(0xFF14783A),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFDFF5E6),
      onTertiaryContainer: Color(0xFF14783A),
      error: error,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: ink,
      onSurfaceVariant: Color(0xFF6B6B6B),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: pageBackground,
      surfaceContainer: Color(0xFFF4F3F4),
      surfaceContainerHigh: Color(0xFFEEEDED),
      surfaceContainerHighest: Color(0xFFF3F3F3),
      outline: fieldOutline,
      outlineVariant: Color(0xFFECE9EA),
      surfaceTint: Colors.transparent,
      shadow: Colors.black,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

    TextStyle heading(TextStyle? s, double size) => s!.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02 * size,
          height: 1.2,
          color: ink,
        );

    final textTheme = text.copyWith(
      headlineLarge: heading(text.headlineLarge, 32),
      headlineMedium: heading(text.headlineMedium, 28),
      titleLarge: text.titleLarge!.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: text.titleMedium!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: text.bodyLarge!.copyWith(
        fontSize: 16,
        height: 1.5,
        color: colors.warmText,
      ),
      bodyMedium: text.bodyMedium!.copyWith(
        fontSize: 15,
        height: 1.5,
        color: colors.warmText,
      ),
      bodySmall: text.bodySmall!.copyWith(
        fontSize: 13,
        height: 1.5,
        color: colors.mutedText,
      ),
      labelLarge: text.labelLarge!.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    );

    OutlineInputBorder fieldBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: pageBackground,
      textTheme: textTheme,
      extensions: const [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        shape: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.hairline),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandYellow,
          foregroundColor: ink,
          disabledBackgroundColor: colors.panelFill,
          disabledForegroundColor: colors.mutedText,
          elevation: 0,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge!.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: ink,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: ink, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge!.copyWith(fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? Colors.white
              : colors.fieldFill,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium!.copyWith(color: colors.mutedText),
        border: fieldBorder(fieldOutline, 1),
        enabledBorder: fieldBorder(fieldOutline, 1),
        focusedBorder: fieldBorder(brandYellow, 2),
        errorBorder: fieldBorder(error, 1),
        focusedErrorBorder: fieldBorder(error, 2),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: ink),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: colors.hairline, thickness: 1),
    );
  }
}

class PinjeminApp extends StatelessWidget {
  const PinjeminApp({super.key, this.request});

  /// Injected in tests; the real app creates its own.
  final CookieRequest? request;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CookieRequest>(create: (_) => request ?? CookieRequest()),
        ChangeNotifierProvider<SessionProvider>(
          create: (_) => SessionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Pinjemin',
        debugShowCheckedModeBanner: false,
        theme: PinjeminTheme.build(),
        home: const AuthGate(),
      ),
    );
  }
}
