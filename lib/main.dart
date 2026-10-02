import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/motion/app_motion.dart';
import 'core/routing/app_router.dart';
import 'core/sound/sound_service.dart';
import 'core/l10n/app_language.dart';
import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/alamiyah_widgets.dart';
import 'core/theme/display_prefs.dart';
import 'data/services/fasting_reminder_service.dart';
import 'data/services/fasting_tracker.dart';
import 'data/services/firebase_config.dart';
import 'data/services/hijri_service.dart';
import 'data/services/prayer_times_service.dart';
import 'data/services/service_providers.dart';
import 'firebase_options.dart';
import 'shared/widgets/brand_intro_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.prefsBox);
  await Hive.openBox(AppConstants.bookmarksBox);
  await Hive.openBox(AppConstants.adminDraftsBox);

  if (FirebaseConfig.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await FastingReminderService.instance.init();

  runApp(const ProviderScope(child: AlamiyahApp()));
}

class AlamiyahApp extends ConsumerStatefulWidget {
  const AlamiyahApp({super.key});

  @override
  ConsumerState<AlamiyahApp> createState() => _AlamiyahAppState();
}

class _AlamiyahAppState extends ConsumerState<AlamiyahApp> {
  String? _paletteKey;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (FirebaseConfig.isConfigured) {
        try {
          await ref
              .read(contentRepositoryProvider)
              .seedDefaultCategoriesIfEmpty();
        } catch (e) {
          debugPrint('Category seed skipped: $e');
        }
        // Demo wipe/seed runs after admin sign-in (Firestore write rules).
      } else {
        try {
          final box = Hive.box(AppConstants.prefsBox);
          final seeded =
              box.get(AppConstants.demoSeedVersionKey) ==
                  AppConstants.demoSeedVersion;
          if (!seeded) {
            await ref
                .read(contentRepositoryProvider)
                .wipeAndSeedDemoContent();
            await box.put(
              AppConstants.demoSeedVersionKey,
              AppConstants.demoSeedVersion,
            );
          }
        } catch (e) {
          debugPrint('Mock demo seed skipped: $e');
        }
      }
      final flags = ref.read(calendarFlagsProvider);
      await FastingReminderService.instance.sync(
        enabled: flags.reminders,
        ramadanActive: HijriDate.now().isRamadan || flags.preview,
        location: ref.read(prayerLocationProvider),
      );
      await AlamiyahWidgets.push(
        ref.read(todayPrayersProvider),
        AppStrings(ref.read(displayPrefsProvider).language),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final prefs = ref.watch(displayPrefsProvider);
    final prayers = ref.watch(todayPrayersProvider);
    ref.watch(soundServiceProvider);
    final resolved = prefs.resolvedTheme(
      platform: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      maghrib: prayers.maghrib,
      fajr: prayers.fajr,
    );
    final theme = AppTheme.fromPrefs(prefs.copyWith(theme: resolved));
    final paletteKey = '${resolved.name}|${prefs.accent.name}';
    final animateTheme =
        _paletteKey != null && _paletteKey != paletteKey;
    _paletteKey = paletteKey;

    ref.listen(todayPrayersProvider, (previous, next) {
      AlamiyahWidgets.push(next, AppStrings(prefs.language));
    });
    ref.listen(displayPrefsProvider, (previous, next) {
      if (previous?.language == next.language) return;
      AlamiyahWidgets.push(prayers, AppStrings(next.language));
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.light,
      themeAnimationDuration:
          animateTheme ? AppMotion.theme : Duration.zero,
      themeAnimationCurve: AppMotion.curve,
      locale: Locale(prefs.language.code),
      supportedLocales: [
        for (final language in AppLanguage.values) Locale(language.code),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return BrandIntroOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
