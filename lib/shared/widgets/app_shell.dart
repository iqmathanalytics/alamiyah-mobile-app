import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/sound/sound_service.dart';
import '../../core/theme/alamiyah_colors.dart';
import '../../features/guide/guided_tour_overlay.dart';
import '../../features/guide/tour_targets.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    if (index != navigationShell.currentIndex) {
      HapticFeedback.selectionClick();
      SoundService.instance?.swoosh();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    if (navigationShell.currentIndex != 0) {
      navigationShell.goBranch(0);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.alamiyahColors;
    final onHome = navigationShell.currentIndex == 0;
    // On Home with nothing to pop: allow the system to exit the app.
    final canExit = onHome && !GoRouter.of(context).canPop();

    return PopScope(
      canPop: canExit,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context);
      },
      child: GuidedTourHost(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: navigationShell,
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: colors.softShadow,
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              key: TourTargets.bottomNav,
              height: 70,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              indicatorColor: colors.chipBackground,
              backgroundColor: Colors.transparent,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Categories',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.videocam_outlined),
                  selectedIcon: Icon(Icons.videocam_rounded),
                  label: 'Live',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded),
                  label: 'Saved',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlamiyahAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AlamiyahAppBar({
    super.key,
    this.title,
    this.showDisplaySettings = true,
  });

  final String? title;
  final bool showDisplaySettings;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final isHome = title == null;

    return AppBar(
      toolbarHeight: 68,
      centerTitle: false,
      titleSpacing: 20,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          context.push('/admin');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? AppConstants.appName,
              style: GoogleFonts.dmSans(
                fontSize: isHome ? 24 : 22,
                fontWeight: FontWeight.w700,
                color: colors.brandPrimary,
                letterSpacing: -0.4,
              ),
            ),
            if (isHome) ...[
              const SizedBox(height: 2),
              Text(
                'Dhikr · Dua · Calm',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: colors.brandSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (showDisplaySettings)
          Padding(
            key: TourTargets.display,
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: 'Display settings',
              style: IconButton.styleFrom(
                backgroundColor: colors.chipBackground,
                foregroundColor: colors.brandPrimary,
              ),
              onPressed: () => context.push('/display'),
              icon: const Icon(Icons.palette_outlined),
            ),
          ),
      ],
    );
  }
}
