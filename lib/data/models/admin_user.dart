import 'package:json_annotation/json_annotation.dart';

part 'admin_user.g.dart';

enum AdminRole { owner, contributor }

@JsonSerializable()
class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final bool isActive;
  final DateTime? createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserToJson(this);

  bool get isOwner => role == AdminRole.owner;

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    AdminRole? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
