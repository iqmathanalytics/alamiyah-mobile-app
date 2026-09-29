import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/motion/app_motion.dart';
import 'core/routing/app_router.dart';
import 'core/sound/sound_service.dart';
import 'core/theme/app_theme.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final prefs = ref.watch(displayPrefsProvider);
    ref.watch(soundServiceProvider);
    final theme = AppTheme.fromPrefs(prefs);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        return AnimatedTheme(
          duration: AppMotion.scaled(
            AppMotion.theme,
            reduceMotion: prefs.reduceMotion,
          ),
          curve: AppMotion.curve,
          data: theme,
          child: BrandIntroOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
