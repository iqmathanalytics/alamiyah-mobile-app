import 'package:json_annotation/json_annotation.dart';

part 'content_item.g.dart';

enum ContentType { text, image, video }

enum ContentStatus { draft, published }

@JsonSerializable()
class ContentItem {
  const ContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.tags,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.sourceReference,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.featured = false,
  });

  final String id;
  final ContentType type;
  final String title;
  final String category;
  final List<String> tags;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? sourceReference;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String authorId;
  final String authorName;
  final ContentStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool featured;

  factory ContentItem.fromJson(Map<String, dynamic> json) =>
      _$ContentItemFromJson(json);

  Map<String, dynamic> toJson() => _$ContentItemToJson(this);

  ContentItem copyWith({
    String? id,
    ContentType? type,
    String? title,
    String? category,
    List<String>? tags,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? sourceReference,
    String? mediaUrl,
    String? thumbnailUrl,
    String? authorId,
    String? authorName,
    ContentStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? featured,
    bool clearScheduledAt = false,
  }) {
    return ContentItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      sourceReference: sourceReference ?? this.sourceReference,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt:
          clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      featured: featured ?? this.featured,
    );
  }
}
