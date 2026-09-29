import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/section_label.dart';
import '../../home/providers/feed_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  IconData _iconFor(String ref) {
    return switch (ref) {
      'wb_sunny_outlined' => Icons.wb_sunny_outlined,
      'nights_stay_outlined' => Icons.nights_stay_outlined,
      'favorite_border' => Icons.favorite_border,
      'auto_awesome_outlined' => Icons.auto_awesome_outlined,
      'menu_book_outlined' => Icons.menu_book_outlined,
      'play_circle_outline' => Icons.play_circle_outline,
      'brightness_2_outlined' => Icons.brightness_2_outlined,
      _ => Icons.spa_outlined,
    };
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final colors = context.alamiyahColors;

    return Scaffold(
      appBar: const AlamiyahAppBar(title: 'Categories'),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SoftEmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load categories',
          body: '$e',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const SoftEmptyState(
              icon: Icons.grid_view_outlined,
              title: 'No categories yet',
              body:
                  'Create the first admin owner to seed defaults, then pull to refresh.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: categories.length + 1,
            separatorBuilder: (_, index) =>
                SizedBox(height: index == 0 ? 14 : 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionLabel('Browse by theme');
              }
              final cat = categories[index - 1];
              final tint = _parseColor(cat.colorHint);
              return Material(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    ref.read(feedFilterProvider.notifier).setCategory(cat.id);
                    context.go('/home');
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: colors.brandPrimary.withValues(alpha: 0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.softShadow,
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: tint.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(_iconFor(cat.iconRef), color: tint),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.brandPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: colors.brandSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
