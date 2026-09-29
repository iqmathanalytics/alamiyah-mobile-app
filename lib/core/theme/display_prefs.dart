import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../motion/app_motion.dart';
import 'alamiyah_colors.dart';

enum AppThemeId { lightGreen, darkGreen, sepiaWarm, midnight }

enum AccentId { gold, brass, sage, clay, teal, rose }

enum AppearanceMode { system, day, night, auto }

enum AsrSchool { earlier, later }

enum ArabicFontId { uthmani, indopak }

enum ChimeId { droplet, wind, bell }

extension AppThemeIdX on AppThemeId {
  String get label => switch (this) {
        AppThemeId.lightGreen => 'Light Green',
        AppThemeId.darkGreen => 'Dark Green',
        AppThemeId.sepiaWarm => 'Parchment',
        AppThemeId.midnight => 'Midnight',
      };

  String get subtitle => switch (this) {
        AppThemeId.lightGreen => 'Sage over cream',
        AppThemeId.darkGreen => 'Forest night',
        AppThemeId.sepiaWarm => 'Warm reading light',
        AppThemeId.midnight => 'Deep harbor teal',
      };

  bool get isDark =>
      this == AppThemeId.darkGreen || this == AppThemeId.midnight;

  AlamiyahColors get palette => switch (this) {
        AppThemeId.lightGreen => AlamiyahColors.lightGreen,
        AppThemeId.darkGreen => AlamiyahColors.darkGreen,
        AppThemeId.sepiaWarm => AlamiyahColors.sepiaWarm,
        AppThemeId.midnight => AlamiyahColors.midnight,
      };
}

extension AccentIdX on AccentId {
  String get label => switch (this) {
        AccentId.gold => 'Gold',
        AccentId.brass => 'Brass',
        AccentId.sage => 'Sage',
        AccentId.clay => 'Clay',
        AccentId.teal => 'Teal',
        AccentId.rose => 'Rose',
      };

  Color get color => switch (this) {
        AccentId.gold => const Color(0xFFC4A35A),
        AccentId.brass => const Color(0xFFB08D57),
        AccentId.sage => const Color(0xFF8FAF88),
        AccentId.clay => const Color(0xFFC17F5A),
        AccentId.teal => const Color(0xFF5E9A94),
        AccentId.rose => const Color(0xFFB57A86),
      };
}

extension AppearanceModeX on AppearanceMode {
  String get label => switch (this) {
        AppearanceMode.system => 'System',
        AppearanceMode.day => 'Day',
        AppearanceMode.night => 'Night',
        AppearanceMode.auto => 'Auto',
      };

  String get subtitle => switch (this) {
        AppearanceMode.system => 'Follow the phone setting',
        AppearanceMode.day => 'Stay in a light reading palette',
        AppearanceMode.night => 'Stay in a dark reading palette',
        AppearanceMode.auto => 'Night between Maghrib and Fajr',
      };
}

extension AsrSchoolX on AsrSchool {
  String get label => switch (this) {
        AsrSchool.earlier => 'Earlier Asr',
        AsrSchool.later => 'Later Asr',
      };

  String get subtitle => switch (this) {
        AsrSchool.earlier => 'Shafi\'i, Maliki, Hanbali',
        AsrSchool.later => 'Hanafi',
      };
}

extension ArabicFontIdX on ArabicFontId {
  String get label => switch (this) {
        ArabicFontId.uthmani => 'Uthmani',
        ArabicFontId.indopak => 'IndoPak',
      };
}

extension ChimeIdX on ChimeId {
  String get label => switch (this) {
        ChimeId.droplet => 'Droplet',
        ChimeId.wind => 'Wind',
        ChimeId.bell => 'Bell',
      };

  String get asset => switch (this) {
        ChimeId.droplet => 'sounds/chime_droplet.wav',
        ChimeId.wind => 'sounds/chime_wind.wav',
        ChimeId.bell => 'sounds/chime_bell.wav',
      };
}

@immutable
class DisplayPrefs {
  const DisplayPrefs({
    this.theme = AppThemeId.lightGreen,
    this.fontScale = 1.0,
    this.accent = AccentId.gold,
    this.arabicFont = ArabicFontId.uthmani,
    this.appearance = AppearanceMode.day,
    this.asrSchool = AsrSchool.earlier,
    this.showBothAsr = false,
    this.reduceMotion = false,
    this.soundEffects = true,
    this.chime = ChimeId.droplet,
  });

  final AppThemeId theme;
  final double fontScale;
  final AccentId accent;
  final ArabicFontId arabicFont;
  final AppearanceMode appearance;
  final AsrSchool asrSchool;
  final bool showBothAsr;
  final bool reduceMotion;
  final bool soundEffects;
  final ChimeId chime;

  static const fontStops = [0.85, 1.0, 1.15, 1.35];
  static const fontLabels = ['Small', 'Regular', 'Large', 'Extra'];

  AppThemeId resolvedTheme({
    required Brightness platform,
    DateTime? now,
    DateTime? maghrib,
    DateTime? fajr,
  }) {
    final moment = now ?? DateTime.now();
    final night = switch (appearance) {
      AppearanceMode.day => false,
      AppearanceMode.night => true,
      AppearanceMode.system => platform == Brightness.dark,
      AppearanceMode.auto =>
        maghrib != null &&
            fajr != null &&
            (moment.isAfter(maghrib) || moment.isBefore(fajr)),
    };
    if (night == theme.isDark) return theme;
    if (night) {
      return theme == AppThemeId.sepiaWarm
          ? AppThemeId.midnight
          : AppThemeId.darkGreen;
    }
    return theme == AppThemeId.midnight
        ? AppThemeId.sepiaWarm
        : AppThemeId.lightGreen;
  }

  int get fontStopIndex {
    var best = 1;
    var bestDist = 1.0;
    for (var i = 0; i < fontStops.length; i++) {
      final d = (fontStops[i] - fontScale).abs();
      if (d < bestDist) {
        best = i;
        bestDist = d;
      }
    }
    return best;
  }

  DisplayPrefs copyWith({
    AppThemeId? theme,
    double? fontScale,
    AccentId? accent,
    ArabicFontId? arabicFont,
    AppearanceMode? appearance,
    AsrSchool? asrSchool,
    bool? showBothAsr,
    bool? reduceMotion,
    bool? soundEffects,
    ChimeId? chime,
  }) {
    return DisplayPrefs(
      theme: theme ?? this.theme,
      fontScale: fontScale ?? this.fontScale,
      accent: accent ?? this.accent,
      arabicFont: arabicFont ?? this.arabicFont,
      appearance: appearance ?? this.appearance,
      asrSchool: asrSchool ?? this.asrSchool,
      showBothAsr: showBothAsr ?? this.showBothAsr,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      soundEffects: soundEffects ?? this.soundEffects,
      chime: chime ?? this.chime,
    );
  }

  Map<String, dynamic> toMap() => {
        'theme': theme.name,
        'fontScale': fontScale,
        'accent': accent.name,
        'arabicFont': arabicFont.name,
        'appearance': appearance.name,
        'asrSchool': asrSchool.name,
        'showBothAsr': showBothAsr,
        'reduceMotion': reduceMotion,
        'soundEffects': soundEffects,
        'chime': chime.name,
      };

  factory DisplayPrefs.fromBox(Box<dynamic> box) {
    final raw = box.get(AppConstants.displayPrefsKey);
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      return DisplayPrefs(
        theme: _themeFrom(map['theme'] as String?),
        fontScale: (map['fontScale'] as num?)?.toDouble() ?? 1.0,
        accent: _enumFrom(AccentId.values, map['accent'] as String?) ??
            AccentId.gold,
        arabicFont: _arabicFontFrom(map['arabicFont'] as String?),
        appearance: _enumFrom(
              AppearanceMode.values,
              map['appearance'] as String?,
            ) ??
            AppearanceMode.day,
        asrSchool:
            _enumFrom(AsrSchool.values, map['asrSchool'] as String?) ??
                AsrSchool.earlier,
        showBothAsr: map['showBothAsr'] as bool? ?? false,
        reduceMotion: map['reduceMotion'] as bool? ?? false,
        soundEffects: map['soundEffects'] as bool? ?? true,
        chime: _enumFrom(ChimeId.values, map['chime'] as String?) ??
            ChimeId.droplet,
      );
    }
    return DisplayPrefs(theme: _themeFrom(box.get(AppConstants.themeModeKey) as String?));
  }
}

ArabicFontId _arabicFontFrom(String? name) {
  return switch (name) {
    'indopak' => ArabicFontId.indopak,
    'uthmani' || 'naskh' || 'amiri' || 'scheherazade' || null =>
      ArabicFontId.uthmani,
    _ => ArabicFontId.uthmani,
  };
}

AppThemeId _themeFrom(String? name) {
  return _enumFrom(AppThemeId.values, name) ?? AppThemeId.lightGreen;
}

T? _enumFrom<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

/// Typography + motion prefs on the Theme so widgets can read without Riverpod.
@immutable
class AlamiyahDisplay extends ThemeExtension<AlamiyahDisplay> {
  const AlamiyahDisplay({
    required this.fontScale,
    required this.arabicFont,
    required this.reduceMotion,
  });

  factory AlamiyahDisplay.fromPrefs(DisplayPrefs prefs) {
    return AlamiyahDisplay(
      fontScale: prefs.fontScale,
      arabicFont: prefs.arabicFont,
      reduceMotion: prefs.reduceMotion,
    );
  }

  final double fontScale;
  final ArabicFontId arabicFont;
  final bool reduceMotion;

  @override
  AlamiyahDisplay copyWith({
    double? fontScale,
    ArabicFontId? arabicFont,
    bool? reduceMotion,
  }) {
    return AlamiyahDisplay(
      fontScale: fontScale ?? this.fontScale,
      arabicFont: arabicFont ?? this.arabicFont,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  @override
  AlamiyahDisplay lerp(ThemeExtension<AlamiyahDisplay>? other, double t) {
    if (other is! AlamiyahDisplay) return this;
    return AlamiyahDisplay(
      fontScale: fontScale + (other.fontScale - fontScale) * t,
      arabicFont: t < 0.5 ? arabicFont : other.arabicFont,
      reduceMotion: t < 0.5 ? reduceMotion : other.reduceMotion,
    );
  }
}

extension AlamiyahDisplayX on BuildContext {
  AlamiyahDisplay get alamiyahDisplay =>
      Theme.of(this).extension<AlamiyahDisplay>() ??
      const AlamiyahDisplay(
        fontScale: 1,
        arabicFont: ArabicFontId.uthmani,
        reduceMotion: false,
      );

  double contentSize(double base) => base * alamiyahDisplay.fontScale;
}

class DisplayPrefsController extends Notifier<DisplayPrefs> {
  Box<dynamic> get _box => Hive.box(AppConstants.prefsBox);

  @override
  DisplayPrefs build() {
    final prefs = DisplayPrefs.fromBox(_box);
    AppMotion.reduceMotion = prefs.reduceMotion;
    return prefs;
  }

  Future<void> update(DisplayPrefs Function(DisplayPrefs) fn) async {
    final next = fn(state);
    state = next;
    AppMotion.reduceMotion = next.reduceMotion;
    await _box.put(AppConstants.displayPrefsKey, next.toMap());
    await _box.put(AppConstants.themeModeKey, next.theme.name);
  }

  Future<void> setTheme(AppThemeId theme) =>
      update((p) => p.copyWith(theme: theme));

  Future<void> setFontScale(double scale) =>
      update((p) => p.copyWith(fontScale: scale));

  Future<void> setAccent(AccentId accent) =>
      update((p) => p.copyWith(accent: accent));

  Future<void> setArabicFont(ArabicFontId font) =>
      update((p) => p.copyWith(arabicFont: font));

  Future<void> setAppearance(AppearanceMode mode) =>
      update((p) => p.copyWith(appearance: mode));

  Future<void> setAsrSchool(AsrSchool school) =>
      update((p) => p.copyWith(asrSchool: school));

  Future<void> setShowBothAsr(bool value) =>
      update((p) => p.copyWith(showBothAsr: value));

  Future<void> setReduceMotion(bool value) =>
      update((p) => p.copyWith(reduceMotion: value));

  Future<void> setSoundEffects(bool value) =>
      update((p) => p.copyWith(soundEffects: value));

  Future<void> setChime(ChimeId chime) =>
      update((p) => p.copyWith(chime: chime));
}

final displayPrefsProvider =
    NotifierProvider<DisplayPrefsController, DisplayPrefs>(
  DisplayPrefsController.new,
);

/// Kept so older call sites compiling in mixins still type-check during edits.
typedef AppThemeMode = AppThemeId;
