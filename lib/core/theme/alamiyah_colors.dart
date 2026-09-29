import 'package:flutter/material.dart';

/// Brand tokens exposed via ThemeExtension so more palettes can be added later.
///
/// To add a theme: define a new [AlamiyahColors] const, map it in
/// [AlamiyahColors.forId], and add an [AppThemeId] value.
@immutable
class AlamiyahColors extends ThemeExtension<AlamiyahColors> {
  const AlamiyahColors({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.accentGold,
    required this.onAccent,
    required this.surfaceElevated,
    required this.cardBackground,
    required this.softShadow,
    required this.chipBackground,
    required this.arabicEmphasis,
  });

  final Color brandPrimary;
  final Color brandSecondary;
  final Color accentGold;
  final Color onAccent;
  final Color surfaceElevated;
  final Color cardBackground;
  final Color softShadow;
  final Color chipBackground;
  final Color arabicEmphasis;

  static const lightGreen = AlamiyahColors(
    brandPrimary: Color(0xFF2F5D4A),
    brandSecondary: Color(0xFF7BA882),
    accentGold: Color(0xFFC4A35A),
    onAccent: Color(0xFF1E3D32),
    surfaceElevated: Color(0xFFF7F4EE),
    cardBackground: Color(0xFFFFFFFF),
    softShadow: Color(0x1A2F5D4A),
    chipBackground: Color(0xFFE6EFE8),
    arabicEmphasis: Color(0xFF1E3D32),
  );

  static const darkGreen = AlamiyahColors(
    brandPrimary: Color(0xFF8FBF9B),
    brandSecondary: Color(0xFF5A8F7B),
    accentGold: Color(0xFFD4B86A),
    onAccent: Color(0xFF1E3D32),
    surfaceElevated: Color(0xFF1A2E26),
    cardBackground: Color(0xFF243830),
    softShadow: Color(0x40000000),
    chipBackground: Color(0xFF2C443A),
    arabicEmphasis: Color(0xFFE8F0EA),
  );

  static const sepiaWarm = AlamiyahColors(
    brandPrimary: Color(0xFF5C4632),
    brandSecondary: Color(0xFFA1845C),
    accentGold: Color(0xFFC4A35A),
    onAccent: Color(0xFF3F2F1E),
    surfaceElevated: Color(0xFFF4EDE0),
    cardBackground: Color(0xFFFFF8EE),
    softShadow: Color(0x1A5C4632),
    chipBackground: Color(0xFFEDE3D0),
    arabicEmphasis: Color(0xFF3F2F1E),
  );

  static const midnight = AlamiyahColors(
    brandPrimary: Color(0xFF8FB8C4),
    brandSecondary: Color(0xFF4A7A88),
    accentGold: Color(0xFFD4B86A),
    onAccent: Color(0xFF0E1A22),
    surfaceElevated: Color(0xFF0E1A22),
    cardBackground: Color(0xFF16262F),
    softShadow: Color(0x66000000),
    chipBackground: Color(0xFF1E3340),
    arabicEmphasis: Color(0xFFE4EEF2),
  );

  AlamiyahColors withAccent(Color accent) {
    return copyWith(
      accentGold: accent,
      onAccent: accent.computeLuminance() > 0.45
          ? const Color(0xFF1E3D32)
          : const Color(0xFFF7F4EE),
    );
  }

  @override
  AlamiyahColors copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? accentGold,
    Color? onAccent,
    Color? surfaceElevated,
    Color? cardBackground,
    Color? softShadow,
    Color? chipBackground,
    Color? arabicEmphasis,
  }) {
    return AlamiyahColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      accentGold: accentGold ?? this.accentGold,
      onAccent: onAccent ?? this.onAccent,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      cardBackground: cardBackground ?? this.cardBackground,
      softShadow: softShadow ?? this.softShadow,
      chipBackground: chipBackground ?? this.chipBackground,
      arabicEmphasis: arabicEmphasis ?? this.arabicEmphasis,
    );
  }

  @override
  AlamiyahColors lerp(ThemeExtension<AlamiyahColors>? other, double t) {
    if (other is! AlamiyahColors) return this;
    return AlamiyahColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      softShadow: Color.lerp(softShadow, other.softShadow, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      arabicEmphasis: Color.lerp(arabicEmphasis, other.arabicEmphasis, t)!,
    );
  }
}

extension AlamiyahColorsX on BuildContext {
  AlamiyahColors get alamiyahColors =>
      Theme.of(this).extension<AlamiyahColors>() ?? AlamiyahColors.lightGreen;
}
