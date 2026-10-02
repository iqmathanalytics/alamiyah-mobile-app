import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../l10n/app_language.dart';
import '../motion/app_motion.dart';
import 'alamiyah_colors.dart';

enum AppThemeId {
  lightGreen,
  sepiaWarm,
  fajr,
  mist,
  henna,
  mint,
  darkGreen,
  midnight,
  maghrib,
  isha,
  oud,
  onyx,
}

enum AccentId { gold, brass, sage, clay, teal, rose }

enum AppearanceMode { system, day, night, auto }

enum AsrSchool { earlier, later }

enum ArabicFontId { uthmani, indopak }

enum ChimeId { droplet, wind, bell }

extension AppThemeIdX on AppThemeId {
  String get label => switch (this) {
        AppThemeId.lightGreen => 'Olive',
        AppThemeId.sepiaWarm => 'Sandstone',
        AppThemeId.fajr => 'Fajr',
        AppThemeId.mist => 'Mist',
        AppThemeId.henna => 'Henna',
        AppThemeId.mint => 'Mint',
        AppThemeId.darkGreen => 'Emerald',
        AppThemeId.midnight => 'Lapis',
        AppThemeId.maghrib => 'Maghrib',
        AppThemeId.isha => 'Isha',
        AppThemeId.oud => 'Oud',
        AppThemeId.onyx => 'Onyx',
      };

  String get subtitle => switch (this) {
        AppThemeId.lightGreen => 'Sage over cream',
        AppThemeId.sepiaWarm => 'Warm paper',
        AppThemeId.fajr => 'Soft dawn rose',
        AppThemeId.mist => 'Cool morning grey',
        AppThemeId.henna => 'Warm clay',
        AppThemeId.mint => 'Fresh garden',
        AppThemeId.darkGreen => 'Forest night',
        AppThemeId.midnight => 'Deep harbor',
        AppThemeId.maghrib => 'After sunset',
        AppThemeId.isha => 'Indigo night',
        AppThemeId.oud => 'Dark wood',
        AppThemeId.onyx => 'True black',
      };

  bool get isDark => switch (this) {
        AppThemeId.darkGreen ||
        AppThemeId.midnight ||
        AppThemeId.maghrib ||
        AppThemeId.isha ||
        AppThemeId.oud ||
        AppThemeId.onyx =>
          true,
        _ => false,
      };

  AlamiyahColors get palette => switch (this) {
        AppThemeId.lightGreen => AlamiyahColors.lightGreen,
        AppThemeId.sepiaWarm => AlamiyahColors.sepiaWarm,
        AppThemeId.fajr => AlamiyahColors.fajr,
        AppThemeId.mist => AlamiyahColors.mist,
        AppThemeId.henna => AlamiyahColors.henna,
        AppThemeId.mint => AlamiyahColors.mint,
        AppThemeId.darkGreen => AlamiyahColors.darkGreen,
        AppThemeId.midnight => AlamiyahColors.midnight,
        AppThemeId.maghrib => AlamiyahColors.maghrib,
        AppThemeId.isha => AlamiyahColors.isha,
        AppThemeId.oud => AlamiyahColors.oud,
        AppThemeId.onyx => AlamiyahColors.onyx,
      };
}

List<AppThemeId> themesFor({required bool dark}) =>
    AppThemeId.values.where((id) => id.isDark == dark).toList();

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
    this.lightTheme = AppThemeId.lightGreen,
    this.darkTheme = AppThemeId.darkGreen,
    this.fontScale = 1.0,
    this.accent = AccentId.gold,
    this.arabicFont = ArabicFontId.uthmani,
    this.appearance = AppearanceMode.day,
    this.asrSchool = AsrSchool.earlier,
    this.showBothAsr = false,
    this.reduceMotion = false,
    this.soundEffects = true,
    this.chime = ChimeId.droplet,
    this.language = AppLanguage.en,
  });

  final AppThemeId theme;
  final AppThemeId lightTheme;
  final AppThemeId darkTheme;
  final double fontScale;
  final AccentId accent;
  final ArabicFontId arabicFont;
  final AppearanceMode appearance;
  final AsrSchool asrSchool;
  final bool showBothAsr;
  final bool reduceMotion;
  final bool soundEffects;
  final ChimeId chime;
  final AppLanguage language;

  static const fontStops = [0.85, 1.0, 1.15, 1.35];
  static const fontLabels = ['Small', 'Regular', 'Large', 'Extra'];

  bool isNightNow({
    required Brightness platform,
    DateTime? now,
    DateTime? maghrib,
    DateTime? fajr,
  }) {
    final moment = now ?? DateTime.now();
    return switch (appearance) {
      AppearanceMode.day => false,
      AppearanceMode.night => true,
      AppearanceMode.system => platform == Brightness.dark,
      AppearanceMode.auto =>
        maghrib != null &&
            fajr != null &&
            (moment.isAfter(maghrib) || moment.isBefore(fajr)),
    };
  }

  AppThemeId resolvedTheme({
    required Brightness platform,
    DateTime? now,
    DateTime? maghrib,
    DateTime? fajr,
  }) {
    final night = isNightNow(
      platform: platform,
      now: now,
      maghrib: maghrib,
      fajr: fajr,
    );
    return switch (appearance) {
      AppearanceMode.system || AppearanceMode.auto =>
        night ? AppThemeId.darkGreen : AppThemeId.lightGreen,
      AppearanceMode.day =>
        lightTheme.isDark ? AppThemeId.lightGreen : lightTheme,
      AppearanceMode.night =>
        darkTheme.isDark ? darkTheme : AppThemeId.darkGreen,
    };
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
    AppThemeId? lightTheme,
    AppThemeId? darkTheme,
    double? fontScale,
    AccentId? accent,
    ArabicFontId? arabicFont,
    AppearanceMode? appearance,
    AsrSchool? asrSchool,
    bool? showBothAsr,
    bool? reduceMotion,
    bool? soundEffects,
    ChimeId? chime,
    AppLanguage? language,
  }) {
    return DisplayPrefs(
      theme: theme ?? this.theme,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      fontScale: fontScale ?? this.fontScale,
      accent: accent ?? this.accent,
      arabicFont: arabicFont ?? this.arabicFont,
      appearance: appearance ?? this.appearance,
      asrSchool: asrSchool ?? this.asrSchool,
      showBothAsr: showBothAsr ?? this.showBothAsr,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      soundEffects: soundEffects ?? this.soundEffects,
      chime: chime ?? this.chime,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() => {
        'theme': theme.name,
        'lightTheme': lightTheme.name,
        'darkTheme': darkTheme.name,
        'fontScale': fontScale,
        'accent': accent.name,
        'arabicFont': arabicFont.name,
        'appearance': appearance.name,
        'asrSchool': asrSchool.name,
        'showBothAsr': showBothAsr,
        'reduceMotion': reduceMotion,
        'soundEffects': soundEffects,
        'chime': chime.name,
        'language': language.name,
      };

  factory DisplayPrefs.fromBox(Box<dynamic> box) {
    final raw = box.get(AppConstants.displayPrefsKey);
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final stored = _themeFrom(map['theme'] as String?);
      return DisplayPrefs(
        theme: stored,
        lightTheme: _themeFrom(
          map['lightTheme'] as String?,
          fallback: stored.isDark ? AppThemeId.lightGreen : stored,
        ),
        darkTheme: _themeFrom(
          map['darkTheme'] as String?,
          fallback: stored.isDark ? stored : AppThemeId.darkGreen,
        ),
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
        language: _enumFrom(AppLanguage.values, map['language'] as String?) ??
            AppLanguage.en,
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

AppThemeId _themeFrom(
  String? name, {
  AppThemeId fallback = AppThemeId.lightGreen,
}) {
  return _enumFrom(AppThemeId.values, name) ?? fallback;
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
    required this.language,
  });

  factory AlamiyahDisplay.fromPrefs(DisplayPrefs prefs) {
    return AlamiyahDisplay(
      fontScale: prefs.fontScale,
      arabicFont: prefs.arabicFont,
      reduceMotion: prefs.reduceMotion,
      language: prefs.language,
    );
  }

  final double fontScale;
  final ArabicFontId arabicFont;
  final bool reduceMotion;
  final AppLanguage language;

  @override
  AlamiyahDisplay copyWith({
    double? fontScale,
    ArabicFontId? arabicFont,
    bool? reduceMotion,
    AppLanguage? language,
  }) {
    return AlamiyahDisplay(
      fontScale: fontScale ?? this.fontScale,
      arabicFont: arabicFont ?? this.arabicFont,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      language: language ?? this.language,
    );
  }

  @override
  AlamiyahDisplay lerp(ThemeExtension<AlamiyahDisplay>? other, double t) {
    if (other is! AlamiyahDisplay) return this;
    return AlamiyahDisplay(
      fontScale: fontScale + (other.fontScale - fontScale) * t,
      arabicFont: t < 0.5 ? arabicFont : other.arabicFont,
      reduceMotion: t < 0.5 ? reduceMotion : other.reduceMotion,
      language: t < 0.5 ? language : other.language,
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
        language: AppLanguage.en,
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

  Future<void> setTheme(AppThemeId theme) => update((p) {
        if (theme.isDark) {
          return p.copyWith(theme: theme, darkTheme: theme);
        }
        return p.copyWith(theme: theme, lightTheme: theme);
      });

  Future<void> setFontScale(double scale) =>
      update((p) => p.copyWith(fontScale: scale));

  Future<void> setAccent(AccentId accent) =>
      update((p) => p.copyWith(accent: accent));

  Future<void> setArabicFont(ArabicFontId font) =>
      update((p) => p.copyWith(arabicFont: font));

  Future<void> setLanguage(AppLanguage language) =>
      update((p) => p.copyWith(language: language));

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
