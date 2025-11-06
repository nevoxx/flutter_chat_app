class UserConnectionState {
  final bool isOnline;
  final DateTime? connectedAt;
  final String? currentChannelId;
  final bool? isAudioMuted;
  final bool? isMicrophoneMuted;

  const UserConnectionState({
    required this.isOnline,
    this.connectedAt,
    this.currentChannelId,
    this.isAudioMuted,
    this.isMicrophoneMuted,
  });

  factory UserConnectionState.fromJson(Map<String, dynamic> json) {
    return UserConnectionState(
      isOnline: json['isOnline'] as bool,
      connectedAt: json['connectedAt'] != null
          ? DateTime.parse(json['connectedAt'] as String)
          : null,
      currentChannelId: json['currentChannelId'] as String?,
      isAudioMuted: json['isAudioMuted'] as bool?,
      isMicrophoneMuted: json['isMicrophoneMuted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOnline': isOnline,
      'connectedAt': connectedAt?.toIso8601String(),
      'currentChannelId': currentChannelId,
      'isAudioMuted': isAudioMuted,
      'isMicrophoneMuted': isMicrophoneMuted,
    };
  }

  UserConnectionState copyWith({
    bool? isOnline,
    DateTime? connectedAt,
    String? currentChannelId,
    bool? isAudioMuted,
    bool? isMicrophoneMuted,
  }) {
    return UserConnectionState(
      isOnline: isOnline ?? this.isOnline,
      connectedAt: connectedAt ?? this.connectedAt,
      currentChannelId: currentChannelId ?? this.currentChannelId,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isMicrophoneMuted: isMicrophoneMuted ?? this.isMicrophoneMuted,
    );
  }
}

