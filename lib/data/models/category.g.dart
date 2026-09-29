// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconRef: json['iconRef'] as String,
      colorHint: json['colorHint'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconRef': instance.iconRef,
      'colorHint': instance.colorHint,
      'sortOrder': instance.sortOrder,
    };
