import 'attachment.dart';
import 'role.dart';
import 'user_connection_state.dart';

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
  final UserConnectionState? connectionState;

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
    this.connectionState,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle both direct user object and nested API response structure
    final userData = json.containsKey('user') ? json['user'] as Map<String, dynamic> : json;
    final connectionStateData = json.containsKey('connectionState') ? json['connectionState'] as Map<String, dynamic>? : null;
    
    return User(
      id: userData['id'] as String,
      username: userData['username'] as String,
      displayName: userData['displayName'] as String,
      createdAt: DateTime.parse(userData['createdAt'] as String),
      updatedAt: DateTime.parse(userData['updatedAt'] as String),
      isSystemUser: userData['isSystemUser'] as int,
      roles:
          (userData['roles'] as List<dynamic>?)
              ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profilePicture: userData['profilePicture'] != null
          ? Attachment.fromJson(userData['profilePicture'] as Map<String, dynamic>)
          : null,
      permissions:
          (userData['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      connectionState: connectionStateData != null
          ? UserConnectionState.fromJson(connectionStateData)
          : null,
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
      'connectionState': connectionState?.toJson(),
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
    UserConnectionState? connectionState,
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
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
