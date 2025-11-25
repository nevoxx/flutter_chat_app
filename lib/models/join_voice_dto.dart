class JoinVoiceDto {
  final String token;
  final String serverUrl;
  final String turnUrl;

  const JoinVoiceDto({
    required this.token,
    required this.serverUrl,
    required this.turnUrl,
  });

  factory JoinVoiceDto.fromJson(Map<String, dynamic> json) {
    return JoinVoiceDto(
      token: json['token'] as String,
      serverUrl: json['serverUrl'] as String,
      turnUrl: json['turnUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'serverUrl': serverUrl,
      'turnUrl': turnUrl,
    };
  }
}



