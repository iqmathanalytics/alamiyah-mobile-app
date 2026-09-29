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

class AdminLiveFeedFormScreen extends ConsumerStatefulWidget {
  const AdminLiveFeedFormScreen({super.key, this.linkId});

  final String? linkId;

  @override
  ConsumerState<AdminLiveFeedFormScreen> createState() =>
      _AdminLiveFeedFormScreenState();
}

class _AdminLiveFeedFormScreenState
    extends ConsumerState<AdminLiveFeedFormScreen> {
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _description = TextEditingController();
  final _thumb = TextEditingController();
  var _featured = false;
  var _liveNow = false;
  var _loading = true;
  var _saving = false;
  DateTime? _addedAt;
  String? _addedBy;

  @override
  void initState() {
    super.initState();
    _url.addListener(_autofillThumb);
    _bootstrap();
  }

  @override
  void dispose() {
    _url.removeListener(_autofillThumb);
    _title.dispose();
    _url.dispose();
    _description.dispose();
    _thumb.dispose();
    super.dispose();
  }

  void _autofillThumb() {
    final id = Youtube.videoId(_url.text);
    if (id == null) return;
    final auto = Youtube.thumbnailUrl(id);
    if (_thumb.text.isEmpty || _thumb.text.contains('img.youtube.com')) {
      _thumb.text = auto;
    }
  }

  Future<void> _bootstrap() async {
    final id = widget.linkId;
    if (id != null) {
      final items = await ref.read(contentRepositoryProvider).fetchLiveFeed();
      LiveFeedLink? match;
      for (final item in items) {
        if (item.id == id) {
          match = item;
          break;
        }
      }
      if (match != null && mounted) {
        _title.text = match.title;
        _url.text = match.youtubeUrl;
        _description.text = match.description ?? '';
        _thumb.text = match.thumbnailUrl ?? '';
        _featured = match.isFeatured;
        _liveNow = match.isLiveNow;
        _addedAt = match.addedAt;
        _addedBy = match.addedBy;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final url = _url.text.trim();
    if (title.isEmpty || Youtube.videoId(url) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and a valid YouTube link.')),
      );
      return;
    }

    final session = ref.read(adminSessionProvider);
    if (session == null) return;

    setState(() => _saving = true);
    final item = LiveFeedLink(
      id: widget.linkId ?? '',
      title: title,
      youtubeUrl: url,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      thumbnailUrl: _thumb.text.trim().isEmpty ? null : _thumb.text.trim(),
      isFeatured: _featured,
      isLiveNow: _liveNow,
      addedBy: _addedBy ?? session.profile.name,
      addedAt: _addedAt ?? DateTime.now().toUtc(),
    );

    try {
      await ref.read(contentRepositoryProvider).upsertLiveFeed(item);
      ref.invalidate(liveFeedProvider);
      if (mounted) context.pop();
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
    final session = ref.watch(adminSessionProvider);
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/admin');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colors = context.alamiyahColors;
    final thumb = Youtube.resolvedThumbnail(_url.text, _thumb.text);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.linkId == null ? 'Add live link' : 'Edit live link',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: colors.brandPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                if (thumb != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            ColoredBox(color: colors.chipBackground),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'YouTube URL',
                    hintText: 'https://youtu.be/…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _thumb,
                  decoration: const InputDecoration(
                    labelText: 'Thumbnail URL (optional override)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Featured'),
                  subtitle: const Text('Up to two featured items at a time'),
                  value: _featured,
                  onChanged: (v) => setState(() => _featured = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Live now'),
                  subtitle: const Text('Shows a gentle live pulse on the user tab'),
                  value: _liveNow,
                  onChanged: (v) => setState(() => _liveNow = v),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving…' : 'Save'),
                ),
              ],
            ),
    );
  }
}
