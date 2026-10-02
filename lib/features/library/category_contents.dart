import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/content_card.dart';
import '../bookmarks/providers/bookmark_controller.dart';
import '../home/providers/feed_providers.dart';
import 'library_catalog.dart';
import 'library_section_screen.dart';

/// The chosen collection, shown in place: its lists, then the pieces filed there.
class CategoryContents extends ConsumerWidget {
  const CategoryContents({super.key, required this.collection});

  final LibraryCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final published = ref.watch(publishedContentProvider).asData?.value ??
        const [];
    final bookmarks = ref.watch(bookmarkControllerProvider);
    final items = published
        .where((item) => item.category == collection.id)
        .toList();
    final entryTitles = collection.entries.map((entry) => entry.title).toSet();
    final unfiled = items
        .where((item) => item.section == null || !entryTitles.contains(item.section))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in collection.entries) ...[
          LibraryEntryCard(entry: entry),
          const SizedBox(height: 10),
          for (final item in items.where((item) => item.section == entry.title)) ...[
            ContentCard(
              item: item,
              isBookmarked: bookmarks.contains(item.id),
              onBookmark: () => ref
                  .read(bookmarkControllerProvider.notifier)
                  .toggle(item.id),
              onTap: () => context.push('/content/${item.id}'),
            ),
            const SizedBox(height: 10),
          ],
        ],
        for (final item in unfiled) ...[
          ContentCard(
            item: item,
            isBookmarked: bookmarks.contains(item.id),
            onBookmark: () =>
                ref.read(bookmarkControllerProvider.notifier).toggle(item.id),
            onTap: () => context.push('/content/${item.id}'),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
