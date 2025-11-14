class SocketListenEvents {
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connectError = 'connect_error';
  static const String receiveChatMessage = 'receiveChatMessage';
  static const String receivePoke = 'receivePoke';
  static const String receiveKick = 'receiveKick';
  static const String updateUser = 'updateUser';
  static const String updateMessage = 'updateMessage';
  static const String updateChannels = 'updateChannels';
  static const String receiveUserIsTyping = 'receiveUserIsTyping';
  static const String receiveUserAudioMuteStatusChanged = 'receiveUserAudioMuteStatusChanged';
  static const String receiveUserMicrophoneStatusChanged = 'receiveUserMicrophoneStatusChanged';
}

class SocketPublishEvents {
  static const String sendChatMessage = 'sendChatMessage';
  static const String sendPoke = 'sendPoke';
  static const String sendKick = 'sendKick';
  static const String sendUserIsTyping = 'sendUserIsTyping';
  static const String sendUserAudioMuteStatusChanged = 'sendUserAudioMuteStatusChanged';
  static const String sendUserMicrophoneStatusChanged = 'sendUserMicrophoneStatusChanged';
}

