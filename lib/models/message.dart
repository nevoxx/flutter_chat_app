import 'channel.dart';
import 'attachment.dart';

class Message {
  final String content;
  final String channelId;
  final String userId;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Channel channel;
  final List<Attachment> attachments;

  const Message({
    required this.content,
    required this.channelId,
    required this.userId,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.channel,
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
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
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
      'channel': channel.toJson(),
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }
}
