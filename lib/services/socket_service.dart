import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../models/message.dart';
// import '../models/attachment.dart'; // TODO: Uncomment when attachments are implemented
import '../providers/messages_provider.dart';
import '../providers/socket_provider.dart';

class SocketService {
  final Ref ref;
  bool _listenersSetup = false;

  SocketService(this.ref) {
    // Listen to socket changes and setup listeners when connected
    ref.listen<SocketStatus>(socketProvider, (previous, next) {
      if (next == SocketStatus.connected && !_listenersSetup) {
        _setupEventListeners();
      } else if (next != SocketStatus.connected) {
        _listenersSetup = false;
      }
    });

    // Initialize listeners if already connected
    final socketStatus = ref.read(socketProvider);
    if (socketStatus == SocketStatus.connected && !_listenersSetup) {
      _setupEventListeners();
    }
  }

  IO.Socket? get _socket => ref.read(socketProvider.notifier).socket;

  void _setupEventListeners() {
    final socket = _socket;
    if (socket == null || _listenersSetup) return;

    // TODO: Add more socket event listeners here as needed
    // Example:
    // socket.on('newMessage', (data) {
    //   // Handle incoming message
    //   // ref.read(messagesProvider.notifier).addMessage(message);
    // });

    _listenersSetup = true;
    debugPrint('[SocketService] Event listeners setup complete');
  }

  /// Send a chat message via socket
  void sendChatMessage({
    required String channelId,
    required String content,
    List<String>? attachmentIds,
  }) {
    if (content.trim().isEmpty) return;

    final socket = _socket;
    if (socket == null || !socket.connected) {
      debugPrint('[SocketService] Cannot send message: socket not connected');
      // TODO: Show error to user that socket is not connected
      return;
    }

    // TODO: Implement attachments support
    // final attachmentIdsList = attachmentIds ?? <String>[];

    socket.emitWithAck(
      'sendChatMessage',
      {
        'channelId': channelId,
        'content': content,
        // 'attachmentIds': attachmentIdsList, // TODO: Uncomment when attachments are implemented
      },
      ack: (response) {
        if (response != null && response is Map<String, dynamic>) {
          final data = response['data'];
          if (data != null && data is Map<String, dynamic>) {
            final messageJson = data['message'] as Map<String, dynamic>?;
            // final attachmentJson = data['attachment'] as Map<String, dynamic>?; // TODO: Uncomment when attachments are implemented

            if (messageJson != null) {
              final message = Message.fromJson(messageJson);

              // TODO: Handle attachments when implemented
              // if (attachmentJson != null) {
              //   final attachment = Attachment.fromJson(attachmentJson);
              //   message = message.copyWith(attachments: [attachment]);
              // }

              // Add message to state
              ref.read(messagesProvider.notifier).addMessage(message);
            }
          }
        }
      },
    );
  }
}

// Provider for socket service
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(ref);
});

