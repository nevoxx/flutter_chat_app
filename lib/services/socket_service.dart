import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../models/message.dart';
// import '../models/attachment.dart'; // TODO: Uncomment when attachments are implemented
import '../providers/messages_provider.dart';
import '../providers/socket_provider.dart';
import 'socket_events.dart';
import 'storage_service.dart';

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

    // Listen for incoming chat messages
    socket.on(SocketListenEvents.receiveChatMessage, (data) {
      _receiveChatMessage(data);
    });

    _listenersSetup = true;
    debugPrint('[SocketService] Event listeners setup complete');
  }

  Future<String?> _getCurrentUserId() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getAccessToken();
      if (token == null) return null;

      // Decode JWT token to get user ID
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed for base64 decoding
      final normalizedPayload = payload.padRight(
        (payload.length + 3) ~/ 4 * 4,
        '=',
      );

      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedJson =
          jsonDecode(utf8.decode(decodedBytes)) as Map<String, dynamic>;

      // Try common JWT claim names for user ID
      return decodedJson['userId'] as String? ??
          decodedJson['user_id'] as String? ??
          decodedJson['sub'] as String? ??
          decodedJson['id'] as String?;
    } catch (e) {
      debugPrint('[SocketService] Error decoding JWT token: $e');
      return null;
    }
  }

  void _receiveChatMessage(dynamic data) {
    try {
      debugPrint('[SocketService] Received chat message event');
      debugPrint('[SocketService] Data type: ${data.runtimeType}');
      debugPrint('[SocketService] Data: $data');

      Map<String, dynamic>? messageJson;

      if (data is Map<String, dynamic>) {
        // Try direct message property
        messageJson = data['message'] as Map<String, dynamic>?;

        // If message is not found, maybe data itself is the message
        if (messageJson == null &&
            data.containsKey('id') &&
            data.containsKey('channelId')) {
          messageJson = data;
        }
      } else if (data is List && data.isNotEmpty) {
        // Handle array format
        final firstItem = data[0];
        if (firstItem is Map<String, dynamic>) {
          messageJson =
              firstItem['message'] as Map<String, dynamic>? ?? firstItem;
        }
      }

      if (messageJson == null) {
        debugPrint('[SocketService] Could not extract message from data');
        return;
      }

      debugPrint('[SocketService] Parsing message: $messageJson');
      final message = Message.fromJson(messageJson);
      debugPrint(
        '[SocketService] Successfully parsed message with ID: ${message.id}',
      );

      // Add message to state
      ref.read(messagesProvider.notifier).addMessage(message);

      // Get current user ID from JWT token
      _getCurrentUserId().then((currentUserId) {
        // If message is not from current user
        final isFromCurrentUser =
            currentUserId != null && message.userId == currentUserId;

        if (!isFromCurrentUser) {
          // TODO: Play sound notification
          // ReceiveMessage.play();

          // TODO: Flash frame/window
          // flashFrame();

          // TODO: Set app badge if app is in background
          // if (!document.hasFocus() && navigator.setAppBadge) {
          //   navigator.setAppBadge(chatState.unreadMessages);
          // }
        }
      });
    } catch (e, st) {
      debugPrint('[SocketService] Error handling receiveChatMessage: $e');
      debugPrint('[SocketService] Stack trace: $st');
    }
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
      SocketPublishEvents.sendChatMessage,
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
