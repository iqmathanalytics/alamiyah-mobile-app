import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/motion/app_motion.dart';
import '../../core/sound/sound_service.dart';
import '../../core/theme/alamiyah_colors.dart';
import '../../core/theme/display_prefs.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _page = 0;

  static const _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _go(int page) async {
    HapticFeedback.selectionClick();
    await SoundService.instance?.tick();
    if (!mounted) return;
    await _controller.animateToPage(
      page,
      duration: AppMotion.of(context, AppMotion.screen),
      curve: AppMotion.curve,
    );
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();
    await SoundService.instance?.settle();
    await ref.read(onboardingCompleteProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final last = _page == _pageCount - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: colors.brandSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _WelcomePage(),
                  _NoLoginPage(),
                  _ThemePage(),
                  _ReadyPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pageCount; i++)
                        AnimatedContainer(
                          duration: AppMotion.of(context, AppMotion.micro),
                          curve: AppMotion.curve,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? colors.brandPrimary
                                : colors.brandSecondary.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: last ? _finish : () => _go(_page + 1),
                      child: Text(last ? 'Begin' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.appName,
            style: GoogleFonts.dmSans(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A calm space for dhikr, dua, and the days of the Hijri year.',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              height: 1.4,
              color: colors.brandSecondary,
            ),
          ),
          const Spacer(),
          Text(
            'Nothing here is rushed. Read, save, and return whenever you like.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NoLoginPage extends StatelessWidget {
  const _NoLoginPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_open_rounded, size: 40, color: colors.accentGold),
          const SizedBox(height: 18),
          Text(
            'No account needed',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Alamiyah opens straight to the feed. Bookmarks, theme, and fasting notes stay on this device — we never ask you to sign in.',
            style: GoogleFonts.dmSans(fontSize: 16, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ThemePage extends ConsumerWidget {
  const _ThemePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPrefsProvider);
    final colors = context.alamiyahColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a reading light',
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can change this anytime from Display.',
            style: GoogleFonts.dmSans(color: colors.brandSecondary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                for (final id in themesFor(dark: false))
                  Material(
                    color: id.palette.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        await ref
                            .read(displayPrefsProvider.notifier)
                            .setTheme(id);
                        await SoundService.instance?.settle();
                      },
                      child: AnimatedContainer(
                        duration: AppMotion.of(context, AppMotion.micro),
                        curve: AppMotion.curve,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: prefs.lightTheme == id
                                ? id.palette.brandPrimary
                                : colors.softShadow,
                            width: prefs.lightTheme == id ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              id.label,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                color: id.palette.brandPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              id.subtitle,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: id.palette.brandSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyPage extends ConsumerWidget {
  const _ReadyPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPrefsProvider);
    final colors = context.alamiyahColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are ready',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Soft sounds confirm bookmarks and page turns. Silence them if you prefer a still room.',
            style: GoogleFonts.dmSans(fontSize: 16, height: 1.45),
          ),
          const SizedBox(height: 24),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Sound effects',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            value: prefs.soundEffects,
            onChanged: (v) async {
              await ref.read(displayPrefsProvider.notifier).setSoundEffects(v);
              if (v) await SoundService.instance?.tick();
            },
          ),
        ],
      ),
    );
  }
}
