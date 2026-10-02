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

  static const fajr = AlamiyahColors(
    brandPrimary: Color(0xFF8A5348),
    brandSecondary: Color(0xFFC49A90),
    accentGold: Color(0xFFC4A35A),
    onAccent: Color(0xFF3A241F),
    surfaceElevated: Color(0xFFF8F1EC),
    cardBackground: Color(0xFFFFFBF8),
    softShadow: Color(0x1A8A5348),
    chipBackground: Color(0xFFF0E4DE),
    arabicEmphasis: Color(0xFF3A241F),
  );

  static const mist = AlamiyahColors(
    brandPrimary: Color(0xFF4E6760),
    brandSecondary: Color(0xFF8AA399),
    accentGold: Color(0xFFB7A26A),
    onAccent: Color(0xFF1E3330),
    surfaceElevated: Color(0xFFF2F5F4),
    cardBackground: Color(0xFFFBFEFD),
    softShadow: Color(0x1A4E6760),
    chipBackground: Color(0xFFE3ECE8),
    arabicEmphasis: Color(0xFF1E3330),
  );

  static const henna = AlamiyahColors(
    brandPrimary: Color(0xFF8C4A32),
    brandSecondary: Color(0xFFC4896A),
    accentGold: Color(0xFFC4A35A),
    onAccent: Color(0xFF3A2216),
    surfaceElevated: Color(0xFFF8F1E8),
    cardBackground: Color(0xFFFFF8F1),
    softShadow: Color(0x1A8C4A32),
    chipBackground: Color(0xFFF0E2D4),
    arabicEmphasis: Color(0xFF3A2216),
  );

  static const mint = AlamiyahColors(
    brandPrimary: Color(0xFF2F6B56),
    brandSecondary: Color(0xFF7EAE98),
    accentGold: Color(0xFFC4A35A),
    onAccent: Color(0xFF16332A),
    surfaceElevated: Color(0xFFF2F8F4),
    cardBackground: Color(0xFFFBFFFC),
    softShadow: Color(0x1A2F6B56),
    chipBackground: Color(0xFFE2F0E8),
    arabicEmphasis: Color(0xFF16332A),
  );

  static const maghrib = AlamiyahColors(
    brandPrimary: Color(0xFFE0B0B4),
    brandSecondary: Color(0xFFB07A84),
    accentGold: Color(0xFFD4B86A),
    onAccent: Color(0xFF241418),
    surfaceElevated: Color(0xFF1A1216),
    cardBackground: Color(0xFF2A1C22),
    softShadow: Color(0x66000000),
    chipBackground: Color(0xFF3A262C),
    arabicEmphasis: Color(0xFFF6E8EA),
  );

  static const isha = AlamiyahColors(
    brandPrimary: Color(0xFFB4C0EA),
    brandSecondary: Color(0xFF7E8CB8),
    accentGold: Color(0xFFD4B86A),
    onAccent: Color(0xFF121628),
    surfaceElevated: Color(0xFF101526),
    cardBackground: Color(0xFF1A2238),
    softShadow: Color(0x66000000),
    chipBackground: Color(0xFF26304A),
    arabicEmphasis: Color(0xFFE6EAF6),
  );

  static const oud = AlamiyahColors(
    brandPrimary: Color(0xFFD4B48A),
    brandSecondary: Color(0xFFA88868),
    accentGold: Color(0xFFC4A35A),
    onAccent: Color(0xFF1A1510),
    surfaceElevated: Color(0xFF16120E),
    cardBackground: Color(0xFF262018),
    softShadow: Color(0x66000000),
    chipBackground: Color(0xFF342C22),
    arabicEmphasis: Color(0xFFF4EADF),
  );

  static const onyx = AlamiyahColors(
    brandPrimary: Color(0xFFE8E4DA),
    brandSecondary: Color(0xFFA8A49C),
    accentGold: Color(0xFFC4A35A),
    onAccent: Color(0xFF101010),
    surfaceElevated: Color(0xFF000000),
    cardBackground: Color(0xFF161616),
    softShadow: Color(0x66000000),
    chipBackground: Color(0xFF242424),
    arabicEmphasis: Color(0xFFF4F1EA),
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
