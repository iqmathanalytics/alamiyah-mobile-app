import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/alamiyah_colors.dart';
import '../../../shared/widgets/animated_filter_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/crescent_refresh.dart';
import '../../../shared/widgets/feed_skeleton.dart';
import '../../../shared/widgets/section_label.dart';
import '../../bookmarks/providers/bookmark_controller.dart';
import '../../guide/tour_targets.dart';
import '../../library/category_contents.dart';
import '../../library/library_catalog.dart';
import '../domain/feed_layout.dart';
import '../providers/feed_providers.dart';
import 'home_hijri_prayer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredContentProvider);
    final publishedAsync = ref.watch(publishedContentProvider);
    final composedAsync = ref.watch(composedFeedProvider);
    final selectedId = ref.watch(feedFilterProvider).categoryId;
    final selected = selectedId == null ? null : collectionById(selectedId);
    final bookmarks = ref.watch(bookmarkControllerProvider);
    final colors = context.alamiyahColors;

    // Only full-screen skeleton on first load — never when filtering chips.
    final initialLoading =
        (!publishedAsync.hasValue && publishedAsync.isLoading) ||
            (!featuredAsync.hasValue && featuredAsync.isLoading);
    final loadError = publishedAsync.error ?? featuredAsync.error;

    Future<void> refresh() async {
      ref.invalidate(featuredContentProvider);
      ref.invalidate(publishedContentProvider);
      await Future.wait([
        ref.read(featuredContentProvider.future),
        ref.read(publishedContentProvider.future),
      ]);
    }

    return Scaffold(
      appBar: const AlamiyahAppBar(),
      body: initialLoading
          ? const FeedSkeleton(key: ValueKey('skeleton'))
          : loadError != null && !publishedAsync.hasValue
              ? ListView(
                  key: const ValueKey('error'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Could not load feed',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('$loadError'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              : CustomScrollView(
                  key: const ValueKey('feed'),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    CrescentRefreshControl(onRefresh: refresh),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: HomeHijriPrayerCard(key: TourTargets.feed),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: featuredAsync.when(
                          data: (item) {
                            if (item == null) return const SizedBox.shrink();
                            return FeaturedHeroCard(
                              item: item,
                              onTap: () =>
                                  context.push('/content/${item.id}'),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (e, _) =>
                              Text('Could not load featured: $e'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                        child: SectionLabel(context.s.categories),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        key: TourTargets.categories,
                        height: 46,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: libraryCollections.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final item = libraryCollections[index];
                            return AnimatedFilterChip(
                              label: item.title,
                              selected: selectedId == item.id,
                              onSelected: (_) => ref
                                  .read(feedFilterProvider.notifier)
                                  .selectCategory(item.id),
                            );
                          },
                        ),
                      ),
                    ),
                    if (selected != null)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        sliver: SliverToBoxAdapter(
                          child: CategoryContents(collection: selected),
                        ),
                      )
                    else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                        child: SectionLabel(context.s.forYou),
                      ),
                    ),
                    ..._feedSlivers(
                      context: context,
                      composedAsync: composedAsync,
                      filterKey: 'all',
                      bookmarks: bookmarks,
                      onBookmark: (id) => ref
                          .read(bookmarkControllerProvider.notifier)
                          .toggle(id),
                    ),
                    ],
                  ],
                ),
    );
  }
}

List<Widget> _feedSlivers({
  required BuildContext context,
  required AsyncValue<List<FeedBlock>> composedAsync,
  required String filterKey,
  required Set<String> bookmarks,
  required ValueChanged<String> onBookmark,
}) {
  return [
    composedAsync.when(
      data: (blocks) {
        if (blocks.isEmpty) {
          return SliverFillRemaining(
            key: ValueKey('empty-$filterKey'),
            hasScrollBody: false,
            child: AnimatedOpacity(
              opacity: 1,
              duration: AppMotion.of(context, AppMotion.micro),
              child: const SoftEmptyState(
                icon: Icons.spa_outlined,
                title: 'No content in this view yet',
                body:
                    'Pull to refresh, or publish something from Admin.',
              ),
            ),
          );
        }
        return SliverPadding(
          key: ValueKey('feed-$filterKey'),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverList.separated(
            itemCount: blocks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.screen),
                switchInCurve: AppMotion.curve,
                switchOutCurve: AppMotion.curve,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey('$filterKey-${blocks[index].runtimeType}-$index'),
                  child: _FeedBlockView(
                    block: blocks[index],
                    bookmarks: bookmarks,
                    onBookmark: onBookmark,
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Could not load feed: $e'),
        ),
      ),
    ),
  ];
}

class _FeedBlockView extends StatelessWidget {
  const _FeedBlockView({
    required this.block,
    required this.bookmarks,
    required this.onBookmark,
  });

  final FeedBlock block;
  final Set<String> bookmarks;
  final ValueChanged<String> onBookmark;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return switch (block) {
      DailyDhikrBlock(:final item) => DailyDhikrCard(
          item: item,
          isBookmarked: bookmarks.contains(item.id),
          onBookmark: () => onBookmark(item.id),
          onTap: () => context.push('/content/${item.id}'),
        ),
      QuoteBlock(:final item) => QuoteCard(
          item: item,
          isBookmarked: bookmarks.contains(item.id),
          onBookmark: () => onBookmark(item.id),
          onTap: () => context.push('/content/${item.id}'),
        ),
      MediaPairBlock(:final items) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: ContentCard(
                  item: items[i],
                  compact: true,
                  isBookmarked: bookmarks.contains(items[i].id),
                  onBookmark: () => onBookmark(items[i].id),
                  onTap: () => context.push('/content/${items[i].id}'),
                ),
              ),
            ],
          ],
        ),
      SpotlightBlock(:final categoryName, :final items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From $categoryName',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: colors.brandSecondary,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              ContentCard(
                item: items[i],
                isBookmarked: bookmarks.contains(items[i].id),
                onBookmark: () => onBookmark(items[i].id),
                onTap: () => context.push('/content/${items[i].id}'),
              ),
            ],
          ],
        ),
      PlainBlock(:final item) => ContentCard(
          item: item,
          isBookmarked: bookmarks.contains(item.id),
          onBookmark: () => onBookmark(item.id),
          onTap: () => context.push('/content/${item.id}'),
        ),
    };
  }
}
