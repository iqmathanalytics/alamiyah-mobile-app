import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../features/admin/presentation/admin_content_form_screen.dart';
import '../../features/admin/presentation/admin_content_list_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_gate_screen.dart';
import '../../features/admin/presentation/admin_live_feed_form_screen.dart';
import '../../features/admin/presentation/admin_live_feed_screen.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/admin_users_screen.dart';
import '../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/content/presentation/content_detail_screen.dart';
import '../../features/display/presentation/display_settings_screen.dart';
import '../../features/library/library_section_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/live_feed/presentation/live_feed_screen.dart';
import '../../features/onboarding/onboarding_controller.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'page_transitions.dart';

final _rootKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingCompleteProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: onboardingDone ? '/home' : '/welcome',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!onboardingDone && loc != '/welcome') return '/welcome';
      if (onboardingDone && loc == '/welcome') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => noAnimPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                pageBuilder: (context, state) => noAnimPage(
                  key: state.pageKey,
                  child: const CategoriesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                pageBuilder: (context, state) => noAnimPage(
                  key: state.pageKey,
                  child: const CalendarScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/live',
                pageBuilder: (context, state) => noAnimPage(
                  key: state.pageKey,
                  child: const LiveFeedScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                pageBuilder: (context, state) => noAnimPage(
                  key: state.pageKey,
                  child: const BookmarksScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/qibla',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          playSwoosh: true,
          child: const QiblaScreen(),
        ),
      ),
      GoRoute(
        path: '/library/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          playSwoosh: true,
          child: LibrarySectionScreen(
            collectionId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/display',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          playSwoosh: true,
          child: const DisplaySettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/content/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlidePage(
            key: state.pageKey,
            playSwoosh: true,
            child: ContentDetailScreen(contentId: id),
          );
        },
      ),
      GoRoute(
        path: '/admin/live/new',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const AdminLiveFeedFormScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/live/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlidePage(
            key: state.pageKey,
            child: AdminLiveFeedFormScreen(linkId: id),
          );
        },
      ),
      GoRoute(
        path: '/admin/live',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const AdminLiveFeedScreen(),
        ),
      ),
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const AdminGateScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/content/new',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) {
          final typeName = state.uri.queryParameters['type'] ?? 'text';
          final type = ContentType.values.firstWhere(
            (t) => t.name == typeName,
            orElse: () => ContentType.text,
          );
          return fadeSlidePage(
            key: state.pageKey,
            child: AdminContentFormScreen(initialType: type),
          );
        },
      ),
      GoRoute(
        path: '/admin/content/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlidePage(
            key: state.pageKey,
            child: AdminContentFormScreen(contentId: id),
          );
        },
      ),
      ShellRoute(
        parentNavigatorKey: _rootKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/home',
            pageBuilder: (context, state) => noAnimPage(
              key: state.pageKey,
              child: const AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/content',
            pageBuilder: (context, state) => noAnimPage(
              key: state.pageKey,
              child: const AdminContentListScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/users',
            pageBuilder: (context, state) => noAnimPage(
              key: state.pageKey,
              child: const AdminUsersScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
