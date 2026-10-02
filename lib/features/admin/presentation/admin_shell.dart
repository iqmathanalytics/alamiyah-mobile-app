import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/alamiyah_colors.dart';
import '../../../data/services/service_providers.dart';
import '../../home/providers/feed_providers.dart';
import '../providers/admin_providers.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  var _seedAttempted = false;
  var _categoriesSynced = false;

  int _indexFor(String location) {
    if (location.startsWith('/admin/users')) return 2;
    if (location.startsWith('/admin/content')) return 1;
    return 0;
  }

  String _titleFor(int index) {
    return switch (index) {
      1 => 'Content',
      2 => 'Admins',
      _ => 'Dashboard',
    };
  }

  void _handleBack(BuildContext context, int index) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    if (index != 0) {
      context.go('/admin/home');
      return;
    }
    context.go('/home');
  }

  Future<void> _syncCategories() async {
    if (_categoriesSynced) return;
    _categoriesSynced = true;
    try {
      await ref.read(contentRepositoryProvider).syncLibraryCategories();
      ref.invalidate(adminContentListProvider);
      ref.invalidate(publishedContentProvider);
      ref.invalidate(featuredContentProvider);
      ref.invalidate(categoriesProvider);
    } catch (e) {
      debugPrint('Category sync skipped: $e');
      _categoriesSynced = false;
    }
  }

  Future<void> _maybeSeedDemo() async {
    if (_seedAttempted) return;
    _seedAttempted = true;
    final box = Hive.box(AppConstants.prefsBox);
    if (box.get(AppConstants.demoSeedVersionKey) ==
        AppConstants.demoSeedVersion) {
      return;
    }
    try {
      await ref.read(contentRepositoryProvider).wipeAndSeedDemoContent();
      await box.put(
        AppConstants.demoSeedVersionKey,
        AppConstants.demoSeedVersion,
      );
      ref.invalidate(adminContentListProvider);
      ref.invalidate(publishedContentProvider);
      ref.invalidate(featuredContentProvider);
      ref.invalidate(categoriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo library refreshed')),
        );
      }
    } catch (e) {
      debugPrint('Admin demo seed failed: $e');
      _seedAttempted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final session = ref.watch(adminSessionProvider);
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFor(location);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/admin');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeSeedDemo();
      await _syncCategories();
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context, index);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 64,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleFor(index),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: colors.brandPrimary,
                ),
              ),
              Text(
                '${session.profile.name} · ${session.profile.role.name}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: colors.brandSecondary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Display settings',
              onPressed: () => context.push('/display'),
              icon: Icon(Icons.palette_outlined, color: colors.brandPrimary),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: () async {
                await ref.read(adminAuthServiceProvider).signOut();
                if (context.mounted) context.go('/admin');
              },
              icon: Icon(Icons.logout_rounded, color: colors.brandPrimary),
            ),
          ],
        ),
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          height: 68,
          selectedIndex: index,
          indicatorColor: colors.chipBackground,
          onDestinationSelected: (i) {
            HapticFeedback.selectionClick();
            switch (i) {
              case 0:
                context.go('/admin/home');
              case 1:
                context.go('/admin/content');
              case 2:
                if (session.profile.isOwner) {
                  context.go('/admin/users');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Owners only')),
                  );
                }
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            const NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books_rounded),
              label: 'Content',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.group_outlined,
                color: session.profile.isOwner ? null : Colors.grey,
              ),
              selectedIcon: const Icon(Icons.group_rounded),
              label: 'Admins',
            ),
          ],
        ),
      ),
    );
  }
}
