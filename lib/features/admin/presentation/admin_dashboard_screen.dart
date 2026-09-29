import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../data/models/models.dart';
import '../../home/providers/feed_providers.dart';
import '../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.alamiyahColors;
    final stats = ref.watch(adminStatsProvider);
    final listAsync = ref.watch(adminContentListProvider);
    final session = ref.watch(adminSessionProvider);
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];
    final categoryNames = {
      for (final c in categories) c.id: c.name,
    };

    return RefreshIndicator(
      color: colors.brandPrimary,
      onRefresh: () async => ref.invalidate(adminContentListProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.brandPrimary, colors.brandSecondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamu alaikum${session != null ? ', ${session.profile.name.split(' ').first}' : ''}',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Content studio',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.published} published · ${stats.drafts} drafts',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'At a glance',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: colors.brandPrimary,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 12),
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: colors.accentGold,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _StatCard(
                label: 'Total items',
                value: '${stats.total}',
                icon: Icons.inventory_2_outlined,
              ),
              _StatCard(
                label: 'Published',
                value: '${stats.published}',
                icon: Icons.check_circle_outline,
              ),
              _StatCard(
                label: 'Drafts',
                value: '${stats.drafts}',
                icon: Icons.edit_note_outlined,
              ),
              _StatCard(
                label: 'Categories',
                value: '${categories.length}',
                icon: Icons.grid_view_outlined,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'By type',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ContentType.values.map((t) {
              final count = stats.byType[t] ?? 0;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: t == ContentType.video ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.chipBackground),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$count',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: colors.brandSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Text(
            'Create content',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _CreateTile(
            icon: Icons.menu_book_outlined,
            title: 'Text dua / dhikr',
            subtitle: 'Arabic, transliteration, translation',
            onTap: () => context.push('/admin/content/new?type=text'),
          ),
          const SizedBox(height: 8),
          _CreateTile(
            icon: Icons.image_outlined,
            title: 'Image card',
            subtitle: 'Upload a compressed image',
            onTap: () => context.push('/admin/content/new?type=image'),
          ),
          const SizedBox(height: 8),
          _CreateTile(
            icon: Icons.videocam_outlined,
            title: 'Video reminder',
            subtitle: 'Upload file or paste a URL',
            onTap: () => context.push('/admin/content/new?type=video'),
          ),
          const SizedBox(height: 8),
          _CreateTile(
            icon: Icons.live_tv_outlined,
            title: 'Live Feed',
            subtitle: 'YouTube livestreams and watch links',
            onTap: () => context.push('/admin/live'),
          ),
          const SizedBox(height: 22),
          if (session?.profile.isOwner ?? false) const _ZakatLinkField(),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Categories',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.brandPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/admin/content'),
                child: const Text('Manage all'),
              ),
            ],
          ),
          if (stats.byCategory.isEmpty)
            Text(
              'No content yet — create your first item above.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...stats.byCategory.entries.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        categoryNames[e.key] ?? e.key,
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.chipBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${e.value}',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: colors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          listAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('$e', style: TextStyle(color: colors.brandPrimary)),
            ),
            data: (_) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.chipBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.brandSecondary),
          const Spacer(flex: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.dmSans(
                fontSize: 22,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: colors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              height: 1.2,
              color: colors.brandSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTile extends StatelessWidget {
  const _CreateTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.brandPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.brandSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZakatLinkField extends ConsumerStatefulWidget {
  const _ZakatLinkField();

  @override
  ConsumerState<_ZakatLinkField> createState() => _ZakatLinkFieldState();
}

class _ZakatLinkFieldState extends ConsumerState<_ZakatLinkField> {
  final _url = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _url.text.trim();
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('meta').doc('app').set(
        {'zakatUrl': value},
        SetOptions(merge: true),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Charity link saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zakat / charity link',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _url,
          decoration: const InputDecoration(
            hintText: 'https://…',
            border: OutlineInputBorder(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save link'),
          ),
        ),
      ],
    );
  }
}
