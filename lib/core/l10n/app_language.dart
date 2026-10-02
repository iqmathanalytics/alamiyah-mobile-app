enum AppLanguage { en, es, fr, ar, tr, ms, bn, ur }

extension AppLanguageX on AppLanguage {
  String get code => name;

  String get nativeName => switch (this) {
        AppLanguage.en => 'English',
        AppLanguage.es => 'Español',
        AppLanguage.fr => 'Français',
        AppLanguage.ar => 'العربية',
        AppLanguage.tr => 'Türkçe',
        AppLanguage.ms => 'Bahasa Melayu',
        AppLanguage.bn => 'বাংলা',
        AppLanguage.ur => 'اردو',
      };

  bool get isRtl => this == AppLanguage.ar || this == AppLanguage.ur;
}
