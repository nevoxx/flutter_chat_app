import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';
import '../providers/messages_provider.dart';
import '../providers/socket_provider.dart';
import '../services/api_service.dart';
import 'socket_events.dart';

class SocketService {
  final Ref ref;
  bool _listenersSetup = false;

  SocketService(this.ref) {
    ref.listen<SocketStatus>(socketProvider, (previous, next) {
      if (next == SocketStatus.connected && !_listenersSetup) {
        _setupEventListeners();
      } else if (next != SocketStatus.connected) {
        _listenersSetup = false;
      }
    });

    final socketStatus = ref.read(socketProvider);
    if (socketStatus == SocketStatus.connected && !_listenersSetup) {
      _setupEventListeners();
    }
  }

  IO.Socket? get _socket => ref.read(socketProvider.notifier).socket;

  void _setupEventListeners() {
    final socket = _socket;
    if (socket == null || _listenersSetup) return;

    socket.on(SocketListenEvents.receiveChatMessage, (data) {
      _receiveChatMessage(data);
    });

    _listenersSetup = true;
  }

  Future<String?> _getCurrentUserId() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final user = await apiService.fetchCurrentUser();
      return user.id;
    } catch (e) {
      return null;
    }
  }

  void _receiveChatMessage(dynamic data) {
    try {
      Map<String, dynamic>? messageJson;

      if (data is Map<String, dynamic>) {
        messageJson = data['message'] as Map<String, dynamic>?;

        if (messageJson == null &&
            data.containsKey('id') &&
            data.containsKey('channelId')) {
          messageJson = data;
        }
      } else if (data is List && data.isNotEmpty) {
        final firstItem = data[0];
        if (firstItem is Map<String, dynamic>) {
          messageJson =
              firstItem['message'] as Map<String, dynamic>? ?? firstItem;
        }
      }

      if (messageJson == null) {
        return;
      }

      final message = Message.fromJson(messageJson);
      ref.read(messagesProvider.notifier).addMessage(message);

      _getCurrentUserId().then((currentUserId) {
        final isFromCurrentUser =
            currentUserId != null && message.userId == currentUserId;

        if (!isFromCurrentUser) {
          // TODO: Implement notifications
        }
      });
    } catch (e) {
      // Silently handle errors
    }
  }

  void sendChatMessage({required String channelId, required String content}) {
    if (content.trim().isEmpty) return;

    final socket = _socket;
    if (socket == null || !socket.connected) {
      return;
    }

    socket.emitWithAck(
      SocketPublishEvents.sendChatMessage,
      {'channelId': channelId, 'content': content},
      ack: (response) {
        if (response != null && response is Map<String, dynamic>) {
          final data = response['data'];
          if (data != null && data is Map<String, dynamic>) {
            final messageJson = data['message'] as Map<String, dynamic>?;

            if (messageJson != null) {
              final message = Message.fromJson(messageJson);
              ref.read(messagesProvider.notifier).addMessage(message);
            }
          }
        }
      },
    );
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(ref);
});
