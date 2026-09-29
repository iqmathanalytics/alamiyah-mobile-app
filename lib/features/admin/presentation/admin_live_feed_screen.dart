import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../core/utils/youtube.dart';
import '../../../data/models/models.dart';
import '../../../data/services/service_providers.dart';
import '../../home/providers/feed_providers.dart';
import '../providers/admin_providers.dart';

class AdminLiveFeedScreen extends ConsumerWidget {
  const AdminLiveFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(adminSessionProvider);
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/admin');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colors = context.alamiyahColors;
    final async = ref.watch(liveFeedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Live Feed',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: colors.brandPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/live/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add link'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(liveFeedProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No YouTube links yet.\nAdd a livestream or reminder video.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: colors.brandPrimary,
            onRefresh: () async => ref.invalidate(liveFeedProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final thumb = Youtube.resolvedThumbnail(
                  item.youtubeUrl,
                  item.thumbnailUrl,
                );
                return Material(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/admin/live/${item.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 88,
                              height: 56,
                              child: thumb == null
                                  ? ColoredBox(color: colors.chipBackground)
                                  : Image.network(
                                      thumb,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => ColoredBox(
                                        color: colors.chipBackground,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w600,
                                    color: colors.brandPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    if (item.isLiveNow)
                                      _Chip(
                                        label: 'Live',
                                        color: colors.brandPrimary,
                                      ),
                                    if (item.isFeatured)
                                      _Chip(
                                        label: 'Featured',
                                        color: colors.accentGold,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () => _confirmDelete(context, ref, item),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: colors.brandSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LiveFeedLink item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this link?'),
        content: Text(item.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(contentRepositoryProvider).deleteLiveFeed(item.id);
    ref.invalidate(liveFeedProvider);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
