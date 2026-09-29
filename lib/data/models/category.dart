import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconRef,
    required this.colorHint,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String iconRef;
  final String colorHint;
  final int sortOrder;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
