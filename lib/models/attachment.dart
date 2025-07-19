class Attachment {
  final String id;
  final String type;
  final String modelId;
  final String modelType;
  final String mimeType;
  final String filename;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String attachmentUrl;

  const Attachment({
    required this.id,
    required this.type,
    required this.modelId,
    required this.modelType,
    required this.mimeType,
    required this.filename,
    required this.createdAt,
    required this.updatedAt,
    required this.attachmentUrl,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      type: json['type'] as String,
      modelId: json['modelId'] as String,
      modelType: json['modelType'] as String,
      mimeType: json['mimeType'] as String,
      filename: json['filename'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      attachmentUrl: json['attachmentUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'modelId': modelId,
      'modelType': modelType,
      'mimeType': mimeType,
      'filename': filename,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'attachmentUrl': attachmentUrl,
    };
  }
}
