// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: _$AdminRoleEnumMap.entries
          .firstWhere((e) => e.value == json['role'])
          .key,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': _$AdminRoleEnumMap[instance.role]!,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$AdminRoleEnumMap = {
  AdminRole.owner: 'owner',
  AdminRole.contributor: 'contributor',
};
