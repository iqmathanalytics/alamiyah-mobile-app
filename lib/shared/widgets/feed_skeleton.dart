import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/alamiyah_colors.dart';

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final base = colors.chipBackground;
    final highlight = colors.cardBackground;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, _) => Container(
                width: 100,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < 4; i++) ...[
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
