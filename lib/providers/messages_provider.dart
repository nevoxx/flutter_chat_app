import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import 'users_provider.dart';

// Messages Provider (per channel with loading states)
final messagesProvider = StateNotifierProvider<MessagesController, Map<String, AsyncValue<List<Message>>>>((ref) {
  return MessagesController(ref);
});

class MessagesController extends StateNotifier<Map<String, AsyncValue<List<Message>>>> {
  final Ref ref;

  MessagesController(this.ref) : super({});

  Future<void> fetchMessagesForChannel(String channelId) async {
    // Set loading state for this channel
    state = {
      ...state,
      channelId: const AsyncValue.loading(),
    };

    try {
      final apiService = ref.read(apiServiceProvider);
      final messages = await apiService.fetchMessages(channelId);
      
      // Sort messages by creation date (oldest first)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      state = {
        ...state,
        channelId: AsyncValue.data(messages),
      };
    } catch (e, st) {
      state = {
        ...state,
        channelId: AsyncValue.error(e, st),
      };
    }
  }

  void addMessage(Message message) {
    final channelMessagesAsync = state[message.channelId];
    channelMessagesAsync?.whenData((messages) {
      state = {
        ...state,
        message.channelId: AsyncValue.data([...messages, message]),
      };
    });
  }

  void updateMessage(Message message) {
    final channelMessagesAsync = state[message.channelId];
    channelMessagesAsync?.whenData((messages) {
      state = {
        ...state,
        message.channelId: AsyncValue.data([
          for (final m in messages)
            if (m.id == message.id) message else m
        ]),
      };
    });
  }

  void removeMessage(String channelId, String messageId) {
    final channelMessagesAsync = state[channelId];
    channelMessagesAsync?.whenData((messages) {
      state = {
        ...state,
        channelId: AsyncValue.data(
          messages.where((m) => m.id != messageId).toList(),
        ),
      };
    });
  }

  void setMessagesForChannel(String channelId, List<Message> messages) {
    state = {
      ...state,
      channelId: AsyncValue.data(messages),
    };
  }

  AsyncValue<List<Message>>? getMessagesForChannel(String channelId) {
    return state[channelId];
  }

  void clearChannel(String channelId) {
    final newState = Map<String, AsyncValue<List<Message>>>.from(state);
    newState.remove(channelId);
    state = newState;
  }

  void reset() {
    state = {};
  }
}

