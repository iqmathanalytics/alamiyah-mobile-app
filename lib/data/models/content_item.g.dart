// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_item.dart';

ContentItem _$ContentItemFromJson(Map<String, dynamic> json) => ContentItem(
      id: json['id'] as String,
      type: _$ContentTypeEnumMap.entries
          .firstWhere((e) => e.value == json['type'])
          .key,
      title: json['title'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      arabicText: json['arabicText'] as String?,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      sourceReference: json['sourceReference'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      status: () {
        final raw = json['status'] as String? ?? 'draft';
        // Legacy softDeleted docs map to draft until wiped.
        if (raw == 'softDeleted') return ContentStatus.draft;
        return _$ContentStatusEnumMap.entries
            .firstWhere(
              (e) => e.value == raw,
              orElse: () =>
                  const MapEntry(ContentStatus.draft, 'draft'),
            )
            .key;
      }(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      featured: json['featured'] as bool? ?? false,
    );

Map<String, dynamic> _$ContentItemToJson(ContentItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ContentTypeEnumMap[instance.type]!,
      'title': instance.title,
      'category': instance.category,
      'tags': instance.tags,
      'arabicText': instance.arabicText,
      'transliteration': instance.transliteration,
      'translation': instance.translation,
      'sourceReference': instance.sourceReference,
      'mediaUrl': instance.mediaUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'status': _$ContentStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'featured': instance.featured,
    };

const _$ContentTypeEnumMap = {
  ContentType.text: 'text',
  ContentType.image: 'image',
  ContentType.video: 'video',
};

const _$ContentStatusEnumMap = {
  ContentStatus.draft: 'draft',
  ContentStatus.published: 'published',
};
