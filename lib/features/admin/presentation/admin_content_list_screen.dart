import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/services/service_providers.dart';
import '../../../shared/widgets/animated_filter_chip.dart';
import '../../home/providers/feed_providers.dart';
import '../providers/admin_providers.dart';

class AdminContentListScreen extends ConsumerStatefulWidget {
  const AdminContentListScreen({super.key});

  @override
  ConsumerState<AdminContentListScreen> createState() =>
      _AdminContentListScreenState();
}

class _AdminContentListScreenState
    extends ConsumerState<AdminContentListScreen> {
  String _query = '';
  ContentStatus? _status;
  ContentType? _type;
  String? _category;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final async = ref.watch(adminContentListProvider);
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search title…',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Create',
                onSelected: (t) => context.push('/admin/content/new?type=$t'),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'text', child: Text('Text')),
                  PopupMenuItem(value: 'image', child: Text('Image')),
                  PopupMenuItem(value: 'video', child: Text('Video')),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.add_circle_outline),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              AnimatedFilterChip(
                label: 'All status',
                selected: _status == null,
                onSelected: (_) => setState(() => _status = null),
              ),
              const SizedBox(width: 6),
              ...ContentStatus.values.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AnimatedFilterChip(
                    label: s.name,
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Row(
            children: [
              AnimatedFilterChip(
                label: 'All types',
                selected: _type == null,
                onSelected: (_) => setState(() => _type = null),
              ),
              const SizedBox(width: 6),
              ...ContentType.values.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AnimatedFilterChip(
                    label: t.name,
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (categories.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                AnimatedFilterChip(
                  label: 'All categories',
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                const SizedBox(width: 6),
                ...categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: AnimatedFilterChip(
                      label: c.name,
                      selected: _category == c.id,
                      onSelected: (_) => setState(() => _category = c.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (items) {
              final filtered = items.where((item) {
                if (_status != null && item.status != _status) return false;
                if (_type != null && item.type != _type) return false;
                if (_category != null && item.category != _category) {
                  return false;
                }
                if (_query.isNotEmpty &&
                    !item.title.toLowerCase().contains(_query) &&
                    !item.authorName.toLowerCase().contains(_query)) {
                  return false;
                }
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No matching content'));
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(adminContentListProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Material(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        onTap: () =>
                            context.push('/admin/content/${item.id}'),
                        title: Text(
                          item.title,
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${item.type.name} · ${item.status.name} · ${item.authorName}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            final repo = ref.read(contentRepositoryProvider);
                            switch (action) {
                              case 'publish':
                                await repo.updateContentStatus(
                                  item.id,
                                  ContentStatus.published,
                                );
                              case 'unpublish':
                                await repo.updateContentStatus(
                                  item.id,
                                  ContentStatus.draft,
                                );
                              case 'delete':
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete content?'),
                                    content: Text(
                                      'Permanently delete “${item.title}”? This cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await repo.deleteContent(item.id);
                                }
                            }
                            ref.invalidate(adminContentListProvider);
                            ref.invalidate(publishedContentProvider);
                            ref.invalidate(featuredContentProvider);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'publish',
                              child: Text('Publish'),
                            ),
                            PopupMenuItem(
                              value: 'unpublish',
                              child: Text('Unpublish'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
