import 'channel.dart';
import 'attachment.dart';
import 'user.dart';

class Message {
  final String content;
  final String channelId;
  final String userId;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deletedByUserId;
  final Channel? channel;
  final User? user;
  final List<Attachment> attachments;

  const Message({
    required this.content,
    required this.channelId,
    required this.userId,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserId,
    this.channel,
    this.user,
    required this.attachments,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      channelId: json['channelId'] as String,
      userId: json['userId'] as String,
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      deletedByUserId: json['deletedByUserId'] as String?,
      channel: json['channel'] != null
          ? Channel.fromJson(json['channel'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'channelId': channelId,
      'userId': userId,
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedByUserId': deletedByUserId,
      'channel': channel?.toJson(),
      'user': user?.toJson(),
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }

  Message copyWith({
    String? content,
    String? channelId,
    String? userId,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedByUserId,
    Channel? channel,
    User? user,
    List<Attachment>? attachments,
  }) {
    return Message(
      content: content ?? this.content,
      channelId: channelId ?? this.channelId,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedByUserId: deletedByUserId ?? this.deletedByUserId,
      channel: channel ?? this.channel,
      user: user ?? this.user,
      attachments: attachments ?? this.attachments,
    );
  }
}
