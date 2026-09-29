import '../../../data/models/models.dart';

sealed class FeedBlock {
  const FeedBlock();
}

class DailyDhikrBlock extends FeedBlock {
  const DailyDhikrBlock(this.item);
  final ContentItem item;
}

class QuoteBlock extends FeedBlock {
  const QuoteBlock(this.item);
  final ContentItem item;
}

class MediaPairBlock extends FeedBlock {
  const MediaPairBlock(this.items);
  final List<ContentItem> items;
}

class SpotlightBlock extends FeedBlock {
  const SpotlightBlock({required this.categoryName, required this.items});
  final String categoryName;
  final List<ContentItem> items;
}

class PlainBlock extends FeedBlock {
  const PlainBlock(this.item);
  final ContentItem item;
}

/// Mix featured-adjacent text, media pairs, quotes, and a category spotlight.
List<FeedBlock> composeFeed({
  required List<ContentItem> items,
  required List<Category> categories,
  String? featuredId,
}) {
  final remaining = [
    ...items.where((c) => c.id != featuredId),
  ];
  if (remaining.isEmpty) return const [];

  final blocks = <FeedBlock>[];
  final used = <String>{};

  ContentItem? take(bool Function(ContentItem) test) {
    for (final item in remaining) {
      if (!used.contains(item.id) && test(item)) {
        used.add(item.id);
        return item;
      }
    }
    return null;
  }

  final dhikr = take((c) =>
      c.type == ContentType.text &&
      (c.category == 'morning' || c.category == 'evening'));
  if (dhikr != null) blocks.add(DailyDhikrBlock(dhikr));

  final media = <ContentItem>[];
  while (media.length < 2) {
    final next = take((c) => c.type != ContentType.text);
    if (next == null) break;
    media.add(next);
  }
  if (media.isNotEmpty) blocks.add(MediaPairBlock(media));

  var quotes = 0;
  while (quotes < 2) {
    final quote = take((c) =>
        c.type == ContentType.text && (c.arabicText?.isNotEmpty ?? false));
    if (quote == null) break;
    blocks.add(QuoteBlock(quote));
    quotes++;
  }

  for (final cat in categories) {
    final group = remaining
        .where((c) => !used.contains(c.id) && c.category == cat.id)
        .take(2)
        .toList();
    if (group.length >= 2) {
      for (final item in group) {
        used.add(item.id);
      }
      blocks.add(SpotlightBlock(categoryName: cat.name, items: group));
      break;
    }
  }

  for (final item in remaining) {
    if (used.add(item.id)) blocks.add(PlainBlock(item));
  }
  return blocks;
}
