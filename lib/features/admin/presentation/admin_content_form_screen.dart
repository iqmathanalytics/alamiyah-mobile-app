import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/alamiyah_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/services/service_providers.dart';
import '../../home/providers/feed_providers.dart';
import '../../library/library_catalog.dart';
import '../providers/admin_providers.dart';

class AdminContentFormScreen extends ConsumerStatefulWidget {
  const AdminContentFormScreen({
    super.key,
    this.contentId,
    this.initialType = ContentType.text,
  });

  final String? contentId;
  final ContentType initialType;

  @override
  ConsumerState<AdminContentFormScreen> createState() =>
      _AdminContentFormScreenState();
}

class _AdminContentFormScreenState
    extends ConsumerState<AdminContentFormScreen> {
  final _title = TextEditingController();
  final _arabic = TextEditingController();
  final _translit = TextEditingController();
  final _translation = TextEditingController();
  final _source = TextEditingController();
  final _tags = TextEditingController();
  final _mediaUrl = TextEditingController();
  final _caption = TextEditingController();

  late ContentType _type;
  String? _category;
  String? _section;
  var _status = ContentStatus.draft;
  var _featured = false;
  var _schedule = false;
  DateTime? _scheduledAt;
  var _videoMode = _VideoMode.url;
  var _loading = true;
  var _saving = false;
  String? _existingId;
  String? _existingAuthorId;
  String? _existingAuthorName;
  DateTime? _createdAt;
  String? _uploadedMediaUrl;
  String? _uploadedThumbUrl;
  Timer? _autosave;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _bootstrap();
  }

  @override
  void dispose() {
    _autosave?.cancel();
    for (final c in [
      _title,
      _arabic,
      _translit,
      _translation,
      _source,
      _tags,
      _mediaUrl,
      _caption,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _category ??= libraryCollections.first.id;

    if (widget.contentId != null) {
      final item =
          await ref.read(contentRepositoryProvider).fetchById(widget.contentId!);
      if (item != null) {
        _existingId = item.id;
        _type = item.type;
        _title.text = item.title;
        _arabic.text = item.arabicText ?? '';
        _translit.text = item.transliteration ?? '';
        _translation.text = item.translation ?? item.sourceReference ?? '';
        if (item.type == ContentType.text) {
          _translation.text = item.translation ?? '';
          _source.text = item.sourceReference ?? '';
        } else {
          _caption.text = item.translation ?? '';
        }
        _tags.text = item.tags.join(', ');
        _category = item.category;
        _section = item.section;
        _status = item.status;
        _featured = item.featured;
        _scheduledAt = item.scheduledAt;
        _schedule = item.scheduledAt != null;
        _mediaUrl.text = item.mediaUrl ?? '';
        _uploadedMediaUrl = item.mediaUrl;
        _uploadedThumbUrl = item.thumbnailUrl;
        _existingAuthorId = item.authorId;
        _existingAuthorName = item.authorName;
        _createdAt = item.createdAt;
        if (item.type == ContentType.video &&
            (item.mediaUrl?.contains('http') ?? false) &&
            !(item.mediaUrl?.contains('firebasestorage') ?? false)) {
          _videoMode = _VideoMode.url;
        } else if (item.type == ContentType.video) {
          _videoMode = _VideoMode.upload;
        }
      }
    } else {
      _restoreDraft();
    }

    _wireAutosave();
    if (mounted) setState(() => _loading = false);
  }

  String get _draftKey =>
      'draft_${widget.contentId ?? 'new'}_${_type.name}';

  void _restoreDraft() {
    final box = Hive.box(AppConstants.adminDraftsBox);
    final raw = box.get(_draftKey);
    if (raw is! String) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _title.text = map['title'] as String? ?? '';
      _arabic.text = map['arabic'] as String? ?? '';
      _translit.text = map['translit'] as String? ?? '';
      _translation.text = map['translation'] as String? ?? '';
      _source.text = map['source'] as String? ?? '';
      _tags.text = map['tags'] as String? ?? '';
      _caption.text = map['caption'] as String? ?? '';
      _mediaUrl.text = map['mediaUrl'] as String? ?? '';
      _category = map['category'] as String? ?? _category;
      _section = map['section'] as String? ?? _section;
    } catch (_) {}
  }

  void _wireAutosave() {
    void save() {
      final box = Hive.box(AppConstants.adminDraftsBox);
      box.put(
        _draftKey,
        jsonEncode({
          'title': _title.text,
          'arabic': _arabic.text,
          'translit': _translit.text,
          'translation': _translation.text,
          'source': _source.text,
          'tags': _tags.text,
          'caption': _caption.text,
          'mediaUrl': _mediaUrl.text,
          'category': _category,
          'section': _section,
        }),
      );
    }

    for (final c in [
      _title,
      _arabic,
      _translit,
      _translation,
      _source,
      _tags,
      _caption,
      _mediaUrl,
    ]) {
      c.addListener(() {
        _autosave?.cancel();
        _autosave = Timer(const Duration(milliseconds: 600), save);
      });
    }
  }

  List<String> _parseTags() {
    return _tags.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _saving = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await ref.read(storageServiceProvider).uploadCompressedImage(
            bytes: bytes,
            folder: 'content/images',
          );
      setState(() {
        _uploadedMediaUrl = url;
        _uploadedThumbUrl = url;
        _mediaUrl.text = url;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _saving = true);
    try {
      final bytes = await file.readAsBytes();
      final path =
          'content/videos/${const Uuid().v4()}.${file.name.split('.').last}';
      final url = await ref.read(storageServiceProvider).uploadBytes(
            path: path,
            bytes: bytes,
            contentType: 'video/mp4',
          );
      setState(() {
        _uploadedMediaUrl = url;
        _mediaUrl.text = url;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save({required bool publishNow}) async {
    final session = ref.read(adminSessionProvider);
    if (session == null) return;
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final id = _existingId ?? const Uuid().v4();
      final status = publishNow ? ContentStatus.published : _status;
      final media = _type == ContentType.text
          ? null
          : (_videoMode == _VideoMode.url && _type == ContentType.video
              ? _mediaUrl.text.trim()
              : (_uploadedMediaUrl ?? _mediaUrl.text.trim()));

      final item = ContentItem(
        id: id,
        type: _type,
        title: _title.text.trim(),
        category: collectionById(_category ?? '')?.id ??
            libraryCollections.first.id,
        section: _section,
        tags: _parseTags(),
        arabicText: _type == ContentType.text ? _arabic.text.trim() : null,
        transliteration:
            _type == ContentType.text ? _translit.text.trim() : null,
        translation: _type == ContentType.text
            ? _translation.text.trim()
            : _caption.text.trim(),
        sourceReference:
            _type == ContentType.text ? _source.text.trim() : null,
        mediaUrl: (media == null || media.isEmpty) ? null : media,
        thumbnailUrl: _uploadedThumbUrl,
        authorId: _existingAuthorId ?? session.uid,
        authorName: _existingAuthorName ?? session.profile.name,
        status: status,
        createdAt: _createdAt ?? DateTime.now().toUtc(),
        scheduledAt: _schedule ? _scheduledAt : null,
        featured: _featured,
      );

      await ref.read(contentRepositoryProvider).upsertContent(item);
      await Hive.box(AppConstants.adminDraftsBox).delete(_draftKey);
      ref.invalidate(adminContentListProvider);
      ref.invalidate(publishedContentProvider);
      ref.invalidate(featuredContentProvider);
      ref.invalidate(categoriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(publishNow ? 'Published' : 'Saved')),
        );
        context.go('/admin/content');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final collection = collectionById(_category ?? '') ?? libraryCollections.first;
    final sections = collection.entries.map((entry) => entry.title).toList();
    if (_section != null && !sections.contains(_section)) {
      sections.add(_section!);
    }

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contentId == null ? 'New ${_type.name}' : 'Edit content',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: colors.brandPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: libraryCollections.any((c) => c.id == _category)
                ? _category
                : libraryCollections.first.id,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final item in libraryCollections)
                DropdownMenuItem(
                  value: item.id,
                  child: Text(item.title),
                ),
            ],
            onChanged: (value) => setState(() {
              _category = value;
              final next = collectionById(value ?? '');
              if (next == null ||
                  !next.entries.any((entry) => entry.title == _section)) {
                _section = null;
              }
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _section != null && sections.contains(_section)
                ? _section
                : '',
            decoration: const InputDecoration(
              labelText: 'List',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('This category'),
              ),
              for (final title in sections)
                DropdownMenuItem(
                  value: title,
                  child: Text(title),
                ),
            ],
            onChanged: (value) => setState(() {
              _section = (value == null || value.isEmpty) ? null : value;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tags,
            decoration: const InputDecoration(
              labelText: 'Tags (comma separated)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_type == ContentType.text) ...[
            TextField(
              controller: _arabic,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Arabic text',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              style: GoogleFonts.notoNaskhArabic(fontSize: 22, height: 1.6),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _translit,
              decoration: const InputDecoration(
                labelText: 'Transliteration',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _translation,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _source,
              decoration: const InputDecoration(
                labelText: 'Source / reference',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (_type == ContentType.image) ...[
            TextField(
              controller: _caption,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickAndUploadImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(_uploadedMediaUrl == null
                  ? 'Pick & upload image'
                  : 'Replace image'),
            ),
            if (_uploadedMediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_uploadedMediaUrl!,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
          ],
          if (_type == ContentType.video) ...[
            SegmentedButton<_VideoMode>(
              segments: const [
                ButtonSegment(
                  value: _VideoMode.url,
                  label: Text('URL'),
                  icon: Icon(Icons.link),
                ),
                ButtonSegment(
                  value: _VideoMode.upload,
                  label: Text('Upload'),
                  icon: Icon(Icons.upload_file),
                ),
              ],
              selected: {_videoMode},
              onSelectionChanged: (s) => setState(() => _videoMode = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caption,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Caption / description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_videoMode == _VideoMode.url)
              TextField(
                controller: _mediaUrl,
                decoration: const InputDecoration(
                  labelText: 'YouTube / Vimeo URL',
                  border: OutlineInputBorder(),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickAndUploadVideo,
                icon: const Icon(Icons.videocam_outlined),
                label: Text(_uploadedMediaUrl == null
                    ? 'Pick & upload video'
                    : 'Replace video'),
              ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Featured'),
            value: _featured,
            onChanged: (v) => setState(() => _featured = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Schedule publish'),
            value: _schedule,
            onChanged: (v) async {
              if (!v) {
                setState(() {
                  _schedule = false;
                  _scheduledAt = null;
                });
                return;
              }
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (date == null) return;
              if (!context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time == null) return;
              setState(() {
                _schedule = true;
                _scheduledAt = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ).toUtc();
                _status = ContentStatus.published;
              });
            },
          ),
          if (_scheduledAt != null)
            Text('Scheduled: ${_scheduledAt!.toLocal()}'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () {
                          setState(() => _status = ContentStatus.draft);
                          _save(publishNow: false);
                        },
                  child: const Text('Save draft'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : () => _save(publishNow: true),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publish'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Drafts autosave locally on this device.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

enum _VideoMode { url, upload }
