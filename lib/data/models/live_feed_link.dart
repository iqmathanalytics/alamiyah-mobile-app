import 'package:json_annotation/json_annotation.dart';

part 'live_feed_link.g.dart';

@JsonSerializable()
class LiveFeedLink {
  const LiveFeedLink({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.description,
    this.thumbnailUrl,
    this.isFeatured = false,
    this.isLiveNow = false,
    required this.addedBy,
    required this.addedAt,
  });

  final String id;
  final String title;
  final String youtubeUrl;
  final String? description;
  final String? thumbnailUrl;
  final bool isFeatured;
  final bool isLiveNow;
  final String addedBy;
  final DateTime addedAt;

  LiveFeedLink copyWith({
    String? id,
    String? title,
    String? youtubeUrl,
    String? description,
    String? thumbnailUrl,
    bool? isFeatured,
    bool? isLiveNow,
    String? addedBy,
    DateTime? addedAt,
  }) {
    return LiveFeedLink(
      id: id ?? this.id,
      title: title ?? this.title,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isLiveNow: isLiveNow ?? this.isLiveNow,
      addedBy: addedBy ?? this.addedBy,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory LiveFeedLink.fromJson(Map<String, dynamic> json) =>
      _$LiveFeedLinkFromJson(json);

  Map<String, dynamic> toJson() => _$LiveFeedLinkToJson(this);
}
