import '../models/models.dart';

/// Content access — mock (Phase 1) or Firestore (Phase 2).
abstract class ContentRepository {
  Future<List<ContentItem>> fetchContent({
    String? categoryId,
    ContentType? type,
    bool publishedOnly = true,
  });

  Future<ContentItem?> fetchById(String id);

  Future<List<Category>> fetchCategories();

  Future<List<LiveFeedLink>> fetchLiveFeed();

  Future<String> upsertLiveFeed(LiveFeedLink item);

  Future<void> deleteLiveFeed(String id);

  Future<ContentItem?> fetchFeatured();

  /// Admin: upsert content document. Returns document id.
  Future<String> upsertContent(ContentItem item);

  /// Admin: change status (publish / unpublish).
  Future<void> updateContentStatus(String id, ContentStatus status);

  /// Admin: permanently delete a content document.
  Future<void> deleteContent(String id);

  /// Wipe all content docs and write the demo library.
  Future<void> wipeAndSeedDemoContent();

  Future<void> seedDefaultCategoriesIfEmpty();

  /// Rewrite older category ids onto the current library list.
  Future<void> syncLibraryCategories();
}
