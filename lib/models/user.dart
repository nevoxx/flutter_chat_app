import 'attachment.dart';
import 'role.dart';

class User {
  final String id;
  final String username;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isSystemUser;
  final List<Role> roles;
  final Attachment? profilePicture;
  final List<String> permissions;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    required this.isSystemUser,
    required this.roles,
    this.profilePicture,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSystemUser: json['isSystemUser'] as int,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profilePicture: json['profilePicture'] != null
          ? Attachment.fromJson(json['profilePicture'] as Map<String, dynamic>)
          : null,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSystemUser': isSystemUser,
      'roles': roles.map((e) => e.toJson()).toList(),
      'profilePicture': profilePicture?.toJson(),
      'permissions': permissions,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isSystemUser,
    List<Role>? roles,
    Attachment? profilePicture,
    List<String>? permissions,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystemUser: isSystemUser ?? this.isSystemUser,
      roles: roles ?? this.roles,
      profilePicture: profilePicture ?? this.profilePicture,
      permissions: permissions ?? this.permissions,
    );
  }
}
