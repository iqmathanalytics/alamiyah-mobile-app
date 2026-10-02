import 'dart:convert';

import 'package:flutter/services.dart';

import '../../features/library/library_catalog.dart';
import '../models/models.dart';
import '../services/demo_content_seed.dart';
import 'content_repository.dart';

class MockContentRepository implements ContentRepository {
  MockContentRepository({this.assetPath = 'assets/mock/sample_content.json'});

  final String assetPath;

  List<ContentItem>? _content;
  List<LiveFeedLink>? _liveFeed;

  Future<void> _ensureLoaded() async {
    if (_content != null) return;
    final raw = await rootBundle.loadString(assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _content = (map['content'] as List<dynamic>)
        .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _liveFeed = (map['liveFeed'] as List<dynamic>)
        .map((e) => LiveFeedLink.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ContentItem>> fetchContent({
    String? categoryId,
    ContentType? type,
    bool publishedOnly = true,
  }) async {
    await _ensureLoaded();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _content!
        .map(alignContentItem)
        .where((c) => !publishedOnly || c.status == ContentStatus.published)
        .where((c) => categoryId == null || c.category == categoryId)
        .where((c) => type == null || c.type == type)
        .toList();
  }

  @override
  Future<ContentItem?> fetchById(String id) async {
    await _ensureLoaded();
    try {
      return alignContentItem(_content!.firstWhere((c) => c.id == id));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Category>> fetchCategories() async {
    return libraryCategories;
  }

  @override
  Future<List<LiveFeedLink>> fetchLiveFeed() async {
    await _ensureLoaded();
    return List.unmodifiable(_liveFeed!);
  }

  @override
  Future<String> upsertLiveFeed(LiveFeedLink item) async {
    await _ensureLoaded();
    final list = _liveFeed!;
    final id = item.id.isEmpty ? 'lf_${list.length + 1}' : item.id;
    final saved = item.copyWith(id: id);
    final index = list.indexWhere((e) => e.id == id);
    if (index >= 0) {
      list[index] = saved;
    } else {
      list.insert(0, saved);
    }
    if (saved.isFeatured) {
      final featured = list.where((e) => e.isFeatured && e.id != id).toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
      for (final extra in featured.skip(1)) {
        final i = list.indexWhere((e) => e.id == extra.id);
        if (i >= 0) list[i] = list[i].copyWith(isFeatured: false);
      }
    }
    return id;
  }

  @override
  Future<void> deleteLiveFeed(String id) async {
    await _ensureLoaded();
    _liveFeed!.removeWhere((e) => e.id == id);
  }

  @override
  Future<ContentItem?> fetchFeatured() async {
    await _ensureLoaded();
    try {
      return alignContentItem(_content!.firstWhere(
        (c) => c.featured && c.status == ContentStatus.published,
      ));
    } catch (_) {
      final published = _content!
          .map(alignContentItem)
          .where((c) => c.status == ContentStatus.published)
          .toList();
      return published.isEmpty ? null : published.first;
    }
  }

  @override
  Future<String> upsertContent(ContentItem item) async {
    await _ensureLoaded();
    final index = _content!.indexWhere((c) => c.id == item.id);
    if (index >= 0) {
      _content![index] = item;
    } else {
      _content!.insert(0, item);
    }
    return item.id;
  }

  @override
  Future<void> updateContentStatus(String id, ContentStatus status) async {
    await _ensureLoaded();
    final index = _content!.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _content![index] = _content![index].copyWith(status: status);
    }
  }

  @override
  Future<void> deleteContent(String id) async {
    await _ensureLoaded();
    _content!.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> wipeAndSeedDemoContent() async {
    await _ensureLoaded();
    _content = DemoContentSeed.build();
  }

  @override
  Future<void> seedDefaultCategoriesIfEmpty() async {
    await syncLibraryCategories();
  }

  @override
  Future<void> syncLibraryCategories() async {
    await _ensureLoaded();
    _content = _content!.map(alignContentItem).toList();
  }
}
