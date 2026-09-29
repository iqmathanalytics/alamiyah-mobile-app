import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/bookmark_controller.dart';
import '../providers/bookmarked_content_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(bookmarkControllerProvider);
    final async = ref.watch(bookmarkedContentProvider);
    final colors = context.alamiyahColors;

    return Scaffold(
      appBar: const AlamiyahAppBar(title: 'Saved'),
      body: ids.isEmpty
          ? const SoftEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'Nothing saved yet',
              body:
                  'Bookmark duas and reminders from the feed — they stay on this device.',
            )
          : async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => SoftEmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Could not load saved items',
                body: '$e',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(bookmarkedContentProvider),
              ),
              data: (saved) {
                if (saved.isEmpty) {
                  return const SoftEmptyState(
                    icon: Icons.bookmark_remove_outlined,
                    title: 'Saved items unavailable',
                    body:
                        'Clear old bookmarks and save again from the feed.',
                  );
                }
                return RefreshIndicator(
                  color: colors.brandPrimary,
                  onRefresh: () async =>
                      ref.invalidate(bookmarkedContentProvider),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    itemCount: saved.length + 1,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: index == 0 ? 14 : 14),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SectionLabel(
                          'On this device',
                          trailing: Text(
                            '${saved.length}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: colors.brandSecondary),
                          ),
                        );
                      }
                      final item = saved[index - 1];
                      return ContentCard(
                        item: item,
                        enableHero: false,
                        isBookmarked: true,
                        onBookmark: () => ref
                            .read(bookmarkControllerProvider.notifier)
                            .toggle(item.id),
                        onTap: () => context.push('/content/${item.id}'),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
