import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../domain/feed_layout.dart';

class FeedFilter {
  const FeedFilter({this.categoryId});

  final String? categoryId;

  FeedFilter copyWith({String? categoryId, bool clearCategory = false}) {
    return FeedFilter(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }
}

class FeedFilterNotifier extends Notifier<FeedFilter> {
  @override
  FeedFilter build() => const FeedFilter();

  void selectCategory(String? categoryId) {
    if (categoryId == null || state.categoryId == categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void setCategory(String categoryId) {
    state = FeedFilter(categoryId: categoryId);
  }
}

final feedFilterProvider =
    NotifierProvider<FeedFilterNotifier, FeedFilter>(FeedFilterNotifier.new);

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(contentRepositoryProvider).fetchCategories();
});

final featuredContentProvider = FutureProvider<ContentItem?>((ref) {
  return ref.watch(contentRepositoryProvider).fetchFeatured();
});

/// Full published feed — fetched once; category chips filter this in memory.
final publishedContentProvider = FutureProvider<List<ContentItem>>((ref) {
  return ref.watch(contentRepositoryProvider).fetchContent();
});

/// Filtered view of [publishedContentProvider] — no network round-trip on chip tap.
final feedContentProvider = Provider<AsyncValue<List<ContentItem>>>((ref) {
  final filter = ref.watch(feedFilterProvider);
  final all = ref.watch(publishedContentProvider);
  return all.whenData((items) {
    final categoryId = filter.categoryId;
    if (categoryId == null) return items;
    return items.where((c) => c.category == categoryId).toList();
  });
});

final contentByIdProvider =
    FutureProvider.family<ContentItem?, String>((ref, id) {
  return ref.watch(contentRepositoryProvider).fetchById(id);
});

final composedFeedProvider = Provider<AsyncValue<List<FeedBlock>>>((ref) {
  final itemsAsync = ref.watch(feedContentProvider);
  final categoriesAsync = ref.watch(categoriesProvider);
  final featured = ref.watch(featuredContentProvider).asData?.value;

  if (itemsAsync.hasError) {
    return AsyncValue.error(
      itemsAsync.error!,
      itemsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (categoriesAsync.hasError) {
    return AsyncValue.error(
      categoriesAsync.error!,
      categoriesAsync.stackTrace ?? StackTrace.current,
    );
  }

  final items = itemsAsync.asData?.value;
  final categories = categoriesAsync.asData?.value;
  if (items == null || categories == null) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    composeFeed(
      items: items,
      categories: categories,
      featuredId: featured?.id,
    ),
  );
});

final relatedContentProvider =
    FutureProvider.family<List<ContentItem>, String>((ref, id) async {
  final item = await ref.watch(contentByIdProvider(id).future);
  if (item == null) return const [];
  final list = await ref.watch(publishedContentProvider.future);
  final sameCategory = <ContentItem>[];
  final tagged = <ContentItem>[];
  for (final other in list) {
    if (other.id == id) continue;
    if (other.category == item.category) {
      sameCategory.add(other);
    } else if (other.tags.any(item.tags.contains)) {
      tagged.add(other);
    }
  }
  final mixed = [...sameCategory, ...tagged];
  if (mixed.isNotEmpty) {
    return mixed.take(6).toList();
  }
  return list.where((c) => c.id != id).take(4).toList();
});

final liveFeedProvider = FutureProvider<List<LiveFeedLink>>((ref) {
  return ref.watch(contentRepositoryProvider).fetchLiveFeed();
});
