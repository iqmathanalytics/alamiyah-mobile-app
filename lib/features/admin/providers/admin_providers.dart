import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/services/admin_auth_service.dart';
import '../../../data/services/firebase_config.dart';
import '../../../data/services/service_providers.dart';

final firebaseReadyProvider = Provider<bool>((ref) {
  return FirebaseConfig.isConfigured;
});

final adminAuthStateProvider = StreamProvider<AdminSession?>((ref) {
  return ref.watch(adminAuthServiceProvider).authStateChanges();
});

final adminSessionProvider = Provider<AdminSession?>((ref) {
  return ref.watch(adminAuthStateProvider).asData?.value;
});

final adminContentListProvider =
    FutureProvider.autoDispose<List<ContentItem>>((ref) async {
  final session = ref.watch(adminSessionProvider);
  final items = await ref.watch(contentRepositoryProvider).fetchContent(
        publishedOnly: false,
      );
  if (session == null) return [];
  if (session.profile.isOwner) return items;
  return items.where((c) => c.authorId == session.uid).toList();
});

final adminStatsProvider = Provider.autoDispose<AdminStats>((ref) {
  final async = ref.watch(adminContentListProvider);
  return async.maybeWhen(
    data: AdminStats.fromItems,
    orElse: () => AdminStats.empty,
  );
});

class AdminStats {
  const AdminStats({
    required this.total,
    required this.byType,
    required this.byCategory,
    required this.drafts,
    required this.published,
  });

  final int total;
  final Map<ContentType, int> byType;
  final Map<String, int> byCategory;
  final int drafts;
  final int published;

  static const empty = AdminStats(
    total: 0,
    byType: {},
    byCategory: {},
    drafts: 0,
    published: 0,
  );

  factory AdminStats.fromItems(List<ContentItem> items) {
    final byType = <ContentType, int>{};
    final byCategory = <String, int>{};
    var drafts = 0;
    var published = 0;
    for (final item in items) {
      byType[item.type] = (byType[item.type] ?? 0) + 1;
      byCategory[item.category] = (byCategory[item.category] ?? 0) + 1;
      switch (item.status) {
        case ContentStatus.draft:
          drafts++;
        case ContentStatus.published:
          published++;
      }
    }
    return AdminStats(
      total: items.length,
      byType: byType,
      byCategory: byCategory,
      drafts: drafts,
      published: published,
    );
  }
}

final adminUsersProvider =
    FutureProvider.autoDispose<List<AdminUser>>((ref) async {
  return ref.watch(adminAuthServiceProvider).listAdmins();
});
