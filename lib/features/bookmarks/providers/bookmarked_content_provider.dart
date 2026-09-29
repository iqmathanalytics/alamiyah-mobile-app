import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/services/service_providers.dart';
import 'bookmark_controller.dart';

final bookmarkedContentProvider =
    FutureProvider.autoDispose<List<ContentItem>>((ref) async {
  final ids = ref.watch(bookmarkControllerProvider);
  if (ids.isEmpty) return const [];

  final all = await ref.watch(contentRepositoryProvider).fetchContent();
  final byId = {for (final item in all) item.id: item};
  return ids
      .map((id) => byId[id])
      .whereType<ContentItem>()
      .toList();
});
