import 'package:flutter/material.dart';

abstract final class TelegramColors {
  static const Color blue = Color(0xFF3390EC);
  static const Color blueDarkMode = Color(0xFF5288C1);
  static const Color lightBg = Color(0xFFE7EBF0);
  static const Color lightHeader = Color(0xFFF6F6F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color subtitle = Color(0xFF707579);
  static const Color divider = Color(0xFFDADCE0);
  static const Color darkBg = Color(0xFF0E1621);
  static const Color darkHeader = Color(0xFF17212B);
  static const Color darkSurface = Color(0xFF17212B);
  static const Color darkSurfaceHigh = Color(0xFF242F3D);
}

ThemeData telegramLightTheme() {
  const primary = TelegramColors.blue;
  final scheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFC5E4FA),
    onPrimaryContainer: const Color(0xFF0A3D6B),
    secondary: primary,
    onSecondary: Colors.white,
    surface: TelegramColors.lightSurface,
    onSurface: const Color(0xFF222222),
    onSurfaceVariant: TelegramColors.subtitle,
    outline: TelegramColors.divider,
    outlineVariant: const Color(0xFFE8E8E8),
    error: const Color(0xFFE53935),
    onError: Colors.white,
  );

  return _baseTheme(
    brightness: Brightness.light,
    scheme: scheme,
    scaffold: TelegramColors.lightBg,
    appBar: TelegramColors.lightHeader,
    drawer: TelegramColors.lightSurface,
    elevatedSurface: TelegramColors.lightSurface,
  );
}

ThemeData telegramDarkTheme() {
  const primary = TelegramColors.blueDarkMode;
  final scheme = ColorScheme.dark(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF2B5278),
    onPrimaryContainer: const Color(0xFFE1EFFE),
    secondary: primary,
    onSecondary: Colors.white,
    surface: TelegramColors.darkSurface,
    onSurface: const Color(0xFFE8E8E8),
    onSurfaceVariant: const Color(0xFF8D969C),
    outline: const Color(0xFF3E4C59),
    outlineVariant: const Color(0xFF2F3B47),
    error: const Color(0xFFFF6B6B),
    onError: const Color(0xFF1A1A1A),
  );

  return _baseTheme(
    brightness: Brightness.dark,
    scheme: scheme,
    scaffold: TelegramColors.darkBg,
    appBar: TelegramColors.darkHeader,
    drawer: TelegramColors.darkHeader,
    elevatedSurface: TelegramColors.darkSurfaceHigh,
  );
}

ThemeData _baseTheme({
  required Brightness brightness,
  required ColorScheme scheme,
  required Color scaffold,
  required Color appBar,
  required Color drawer,
  required Color elevatedSurface,
}) {
  final primary = scheme.primary;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffold,
    splashColor: primary.withValues(alpha: 0.14),
    highlightColor: primary.withValues(alpha: 0.08),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: appBar,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: primary, size: 24),
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: primary,
      textColor: scheme.onSurface,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
        letterSpacing: -0.2,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 14,
        color: scheme.onSurfaceVariant,
        height: 1.35,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: drawer, elevation: 2),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: elevatedSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: elevatedSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF3A3F45),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
