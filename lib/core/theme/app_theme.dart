import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'alamiyah_colors.dart';
import 'display_prefs.dart';

class AppTheme {
  AppTheme._();

  static ThemeData fromPrefs(DisplayPrefs prefs) {
    final brand = prefs.theme.palette.withAccent(prefs.accent.color);
    final brightness =
        prefs.theme.isDark ? Brightness.dark : Brightness.light;
    final scaffold = prefs.theme == AppThemeId.midnight
        ? const Color(0xFF0B141A)
        : prefs.theme == AppThemeId.darkGreen
            ? const Color(0xFF121F1A)
            : brand.surfaceElevated;
    final onPrimary = brand.brandPrimary.computeLuminance() > 0.45
        ? brand.onAccent
        : const Color(0xFFF7F4EE);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand.brandPrimary,
        brightness: brightness,
        primary: brand.brandPrimary,
        secondary: brand.brandSecondary,
        surface: brand.surfaceElevated,
      ),
      scaffoldBackgroundColor: scaffold,
      extensions: [
        brand,
        AlamiyahDisplay.fromPrefs(prefs),
      ],
    );
    return _withTypography(base, brand, onPrimary);
  }

  static ThemeData light() => fromPrefs(const DisplayPrefs());

  static ThemeData dark() =>
      fromPrefs(const DisplayPrefs(theme: AppThemeId.darkGreen));

  static ThemeData _withTypography(
    ThemeData base,
    AlamiyahColors brand,
    Color onPrimary,
  ) {
    final ui = GoogleFonts.dmSansTextTheme(base.textTheme).apply(
      bodyColor: brand.arabicEmphasis,
      displayColor: brand.brandPrimary,
    );
    return base.copyWith(
      textTheme: ui,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: brand.brandPrimary,
        ),
        iconTheme: IconThemeData(color: brand.brandPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brand.cardBackground,
        elevation: 0,
        height: 70,
        indicatorColor: brand.chipBackground,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.dmSans(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? brand.brandPrimary : brand.brandSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? brand.brandPrimary : brand.brandSecondary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: brand.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        shadowColor: brand.softShadow,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brand.cardBackground,
        selectedColor: brand.brandPrimary,
        disabledColor: brand.cardBackground,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: brand.brandPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: onPrimary,
        ),
        side: BorderSide(
          color: brand.brandPrimary.withValues(alpha: 0.28),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand.brandPrimary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brand.brandPrimary,
          side: BorderSide(color: brand.brandPrimary.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.brandSecondary,
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brand.cardBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brand.chipBackground),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: brand.brandPrimary.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brand.brandPrimary, width: 1.4),
        ),
        hintStyle: GoogleFonts.dmSans(color: brand.brandSecondary),
      ),
      dividerTheme: DividerThemeData(
        color: brand.brandPrimary.withValues(alpha: 0.08),
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brand.brandPrimary,
        contentTextStyle: GoogleFonts.dmSans(color: onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand.brandPrimary,
        linearTrackColor: brand.chipBackground,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: brand.brandPrimary,
        thumbColor: brand.accentGold,
        inactiveTrackColor: brand.chipBackground,
        overlayColor: brand.accentGold.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brand.accentGold;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return brand.brandSecondary.withValues(alpha: 0.7);
          }
          return null;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: brand.brandSecondary,
        titleTextStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          color: brand.brandPrimary,
          fontSize: 15,
        ),
        subtitleTextStyle: GoogleFonts.dmSans(
          color: brand.brandSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  static TextStyle arabicStyle(
    BuildContext context, {
    double fontSize = 26,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final colors = context.alamiyahColors;
    final display = context.alamiyahDisplay;
    final size = fontSize * display.fontScale;
    final resolved = color ?? colors.arabicEmphasis;
    return switch (display.arabicFont) {
      ArabicFontId.uthmani => GoogleFonts.scheherazadeNew(
          fontSize: size + 2,
          height: 1.8,
          fontWeight: fontWeight,
          color: resolved,
        ),
      ArabicFontId.indopak => GoogleFonts.notoNastaliqUrdu(
          fontSize: size,
          height: 2.1,
          fontWeight: fontWeight,
          color: resolved,
        ),
    };
  }
}
