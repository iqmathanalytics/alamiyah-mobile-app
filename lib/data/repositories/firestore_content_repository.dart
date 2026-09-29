import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import '../services/demo_content_seed.dart';
import 'content_repository.dart';

class FirestoreContentRepository implements ContentRepository {
  FirestoreContentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _content =>
      _db.collection('content');
  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection('categories');
  CollectionReference<Map<String, dynamic>> get _liveFeed =>
      _db.collection('live_feed');

  ContentItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    // Tolerate Timestamp values if rules/clients wrote them that way.
    final created = data['createdAt'];
    if (created is Timestamp) {
      data['createdAt'] = created.toDate().toIso8601String();
    }
    final scheduled = data['scheduledAt'];
    if (scheduled is Timestamp) {
      data['scheduledAt'] = scheduled.toDate().toIso8601String();
    }
    return ContentItem.fromJson(data);
  }

  @override
  Future<List<ContentItem>> fetchContent({
    String? categoryId,
    ContentType? type,
    bool publishedOnly = true,
  }) async {
    // Avoid composite-index requirements: filter simply, sort in memory.
    Query<Map<String, dynamic>> query = _content;
    if (publishedOnly) {
      query = query.where('status', isEqualTo: 'published');
    }

    final snap = await query.get();
    var items = snap.docs.map(_fromDoc).toList();

    if (categoryId != null) {
      items = items.where((c) => c.category == categoryId).toList();
    }
    if (type != null) {
      items = items.where((c) => c.type == type).toList();
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (publishedOnly) {
      final now = DateTime.now().toUtc();
      items = items
          .where((c) => c.scheduledAt == null || !c.scheduledAt!.isAfter(now))
          .toList();
    }
    return items;
  }

  @override
  Future<ContentItem?> fetchById(String id) async {
    final doc = await _content.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final snap = await _categories.get();
    final cats = snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return Category.fromJson(data);
    }).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return cats;
  }

  LiveFeedLink _liveFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    final added = data['addedAt'];
    if (added is Timestamp) {
      data['addedAt'] = added.toDate().toIso8601String();
    }
    return LiveFeedLink.fromJson(data);
  }

  @override
  Future<List<LiveFeedLink>> fetchLiveFeed() async {
    final snap = await _liveFeed.get();
    final items = snap.docs.map(_liveFromDoc).toList()
      ..sort((a, b) {
        if (a.isLiveNow != b.isLiveNow) return a.isLiveNow ? -1 : 1;
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        return b.addedAt.compareTo(a.addedAt);
      });
    return items;
  }

  @override
  Future<String> upsertLiveFeed(LiveFeedLink item) async {
    final id = item.id.isEmpty ? _liveFeed.doc().id : item.id;
    final payload = item.copyWith(id: id).toJson();
    await _liveFeed.doc(id).set(payload, SetOptions(merge: true));
    if (item.isFeatured) {
      await _capFeatured(id);
    }
    return id;
  }

  Future<void> _capFeatured(String keepId) async {
    final snap = await _liveFeed.where('isFeatured', isEqualTo: true).get();
    if (snap.docs.length <= 2) return;
    final others = snap.docs.where((d) => d.id != keepId).toList();
    others.sort((a, b) {
      final aAt = a.data()['addedAt'];
      final bAt = b.data()['addedAt'];
      final aDate = aAt is Timestamp
          ? aAt.toDate()
          : DateTime.tryParse('$aAt') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = bAt is Timestamp
          ? bAt.toDate()
          : DateTime.tryParse('$bAt') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    for (final extra in others.skip(1)) {
      await extra.reference.update({'isFeatured': false});
    }
  }

  @override
  Future<void> deleteLiveFeed(String id) async {
    await _liveFeed.doc(id).delete();
  }

  @override
  Future<ContentItem?> fetchFeatured() async {
    final published = await fetchContent(publishedOnly: true);
    if (published.isEmpty) return null;
    try {
      return published.firstWhere((c) => c.featured);
    } catch (_) {
      return published.first;
    }
  }

  @override
  Future<String> upsertContent(ContentItem item) async {
    final id = item.id.isEmpty ? _content.doc().id : item.id;
    final payload = item.copyWith(id: id).toJson();
    await _content.doc(id).set(payload, SetOptions(merge: true));
    return id;
  }

  @override
  Future<void> updateContentStatus(String id, ContentStatus status) async {
    await _content.doc(id).update({'status': status.name});
  }

  @override
  Future<void> deleteContent(String id) async {
    await _content.doc(id).delete();
  }

  @override
  Future<void> wipeAndSeedDemoContent() async {
    await seedDefaultCategoriesIfEmpty();
    final existing = await _content.get();
    final demoIds = DemoContentSeed.build().map((e) => e.id).toSet();

    for (final doc in existing.docs) {
      if (demoIds.contains(doc.id)) continue;
      try {
        await doc.reference.delete();
      } catch (_) {
        // Older rules blocked delete — hide from the public feed instead.
        await doc.reference.set({
          'status': ContentStatus.draft.name,
          'featured': false,
        }, SetOptions(merge: true));
      }
    }

    final demos = DemoContentSeed.build();
    for (final item in demos) {
      await _content.doc(item.id).set(item.toJson());
    }
  }

  @override
  Future<void> seedDefaultCategoriesIfEmpty() async {
    final existing = await _categories.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    const defaults = [
      Category(
        id: 'morning',
        name: 'Morning Adhkar',
        iconRef: 'wb_sunny_outlined',
        colorHint: '#7BA882',
        sortOrder: 1,
      ),
      Category(
        id: 'evening',
        name: 'Evening Adhkar',
        iconRef: 'nights_stay_outlined',
        colorHint: '#3D6B5A',
        sortOrder: 2,
      ),
      Category(
        id: 'situational',
        name: 'Situational Duas',
        iconRef: 'favorite_border',
        colorHint: '#C4A35A',
        sortOrder: 3,
      ),
      Category(
        id: 'names',
        name: 'Names of Allah',
        iconRef: 'auto_awesome_outlined',
        colorHint: '#5A8F7B',
        sortOrder: 4,
      ),
      Category(
        id: 'reflections',
        name: 'Reflections',
        iconRef: 'menu_book_outlined',
        colorHint: '#8FA894',
        sortOrder: 5,
      ),
      Category(
        id: 'video',
        name: 'Video Reminders',
        iconRef: 'play_circle_outline',
        colorHint: '#2F5D4A',
        sortOrder: 6,
      ),
      Category(
        id: 'ramadan',
        name: 'Ramadan Specials',
        iconRef: 'brightness_2_outlined',
        colorHint: '#B8956A',
        sortOrder: 7,
      ),
    ];

    final batch = _db.batch();
    for (final cat in defaults) {
      batch.set(_categories.doc(cat.id), cat.toJson());
    }
    await batch.commit();
  }
}
