import 'package:alamiyah/data/models/models.dart';
import 'package:alamiyah/features/home/domain/feed_layout.dart';
import 'package:flutter_test/flutter_test.dart';

ContentItem _item({
  required String id,
  required String category,
  ContentType type = ContentType.text,
  String? arabic,
  bool featured = false,
}) {
  return ContentItem(
    id: id,
    type: type,
    title: id,
    category: category,
    tags: const [],
    arabicText: arabic,
    authorId: 'a',
    authorName: 'Alamiyah',
    status: ContentStatus.published,
    createdAt: DateTime(2026, 1, 1),
    featured: featured,
  );
}

void main() {
  test('composeFeed mixes dhikr, media, quotes, and leftover plains', () {
    final items = [
      _item(id: 'feat', category: 'morning', arabic: 'أ', featured: true),
      _item(id: 'dhikr', category: 'morning', arabic: 'ب'),
      _item(id: 'vid', category: 'videos', type: ContentType.video),
      _item(id: 'img', category: 'videos', type: ContentType.image),
      _item(id: 'q1', category: 'reflections', arabic: 'ج'),
      _item(id: 'plain', category: 'names'),
    ];
    final cats = [
      const Category(
        id: 'videos',
        name: 'Videos',
        iconRef: 'play',
        colorHint: '#112233',
        sortOrder: 1,
      ),
    ];

    final blocks = composeFeed(
      items: items,
      categories: cats,
      featuredId: 'feat',
    );

    expect(blocks.whereType<DailyDhikrBlock>(), hasLength(1));
    expect(blocks.whereType<MediaPairBlock>(), hasLength(1));
    expect(blocks.whereType<QuoteBlock>(), isNotEmpty);
    expect(
      blocks.expand((b) => switch (b) {
            DailyDhikrBlock(:final item) => [item.id],
            QuoteBlock(:final item) => [item.id],
            MediaPairBlock(:final items) => items.map((e) => e.id),
            SpotlightBlock(:final items) => items.map((e) => e.id),
            PlainBlock(:final item) => [item.id],
          }),
      isNot(contains('feat')),
    );
  });
}
