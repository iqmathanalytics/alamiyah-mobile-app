// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_feed_link.dart';

LiveFeedLink _$LiveFeedLinkFromJson(Map<String, dynamic> json) => LiveFeedLink(
      id: json['id'] as String,
      title: json['title'] as String,
      youtubeUrl: json['youtubeUrl'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isLiveNow: json['isLiveNow'] as bool? ?? false,
      addedBy: json['addedBy'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$LiveFeedLinkToJson(LiveFeedLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'youtubeUrl': instance.youtubeUrl,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'isFeatured': instance.isFeatured,
      'isLiveNow': instance.isLiveNow,
      'addedBy': instance.addedBy,
      'addedAt': instance.addedAt.toIso8601String(),
    };
