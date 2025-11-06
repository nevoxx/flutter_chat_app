import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';
import '../models/message.dart';
import '../models/server_info.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Server Info Provider
final serverInfoProvider = StateNotifierProvider<ServerInfoController, AsyncValue<ServerInfo?>>((ref) {
  return ServerInfoController(ref);
});

class ServerInfoController extends StateNotifier<AsyncValue<ServerInfo?>> {
  final Ref ref;

  ServerInfoController(this.ref) : super(const AsyncValue.data(null));

  Future<void> fetchServerInfo() async {
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      final serverInfo = await apiService.fetchServerInfo();
      state = AsyncValue.data(serverInfo);
      
      // Update channels provider with fetched channels
      ref.read(channelsProvider.notifier).setChannels(serverInfo.channels);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Channels Provider
final channelsProvider = StateNotifierProvider<ChannelsController, List<Channel>>((ref) {
  return ChannelsController();
});

class ChannelsController extends StateNotifier<List<Channel>> {
  ChannelsController() : super([]);

  void setChannels(List<Channel> channels) {
    // Sort channels by sortOrder
    final sortedChannels = [...channels]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = sortedChannels;
  }

  void addChannel(Channel channel) {
    state = [...state, channel];
    _sortChannels();
  }

  void updateChannel(Channel channel) {
    state = [
      for (final c in state)
        if (c.id == channel.id) channel else c
    ];
    _sortChannels();
  }

  void removeChannel(String channelId) {
    state = state.where((c) => c.id != channelId).toList();
  }

  void _sortChannels() {
    state = [...state]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void reset() {
    state = [];
  }
}

// Users Provider
final usersProvider = StateNotifierProvider<UsersController, AsyncValue<List<User>>>((ref) {
  return UsersController(ref);
});

class UsersController extends StateNotifier<AsyncValue<List<User>>> {
  final Ref ref;

  UsersController(this.ref) : super(const AsyncValue.data([]));

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      final users = await apiService.fetchUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addUser(User user) {
    state.whenData((users) {
      state = AsyncValue.data([...users, user]);
    });
  }

  void updateUser(User user) {
    state.whenData((users) {
      state = AsyncValue.data([
        for (final u in users)
          if (u.id == user.id) user else u
      ]);
    });
  }

  void removeUser(String userId) {
    state.whenData((users) {
      state = AsyncValue.data(users.where((u) => u.id != userId).toList());
    });
  }

  void reset() {
    state = const AsyncValue.data([]);
  }
}

// Messages Provider (per channel)
final messagesProvider = StateNotifierProvider<MessagesController, Map<String, List<Message>>>((ref) {
  return MessagesController();
});

class MessagesController extends StateNotifier<Map<String, List<Message>>> {
  MessagesController() : super({});

  void addMessage(Message message) {
    final channelMessages = state[message.channelId] ?? [];
    state = {
      ...state,
      message.channelId: [...channelMessages, message],
    };
  }

  void updateMessage(Message message) {
    final channelMessages = state[message.channelId] ?? [];
    state = {
      ...state,
      message.channelId: [
        for (final m in channelMessages)
          if (m.id == message.id) message else m
      ],
    };
  }

  void removeMessage(String channelId, String messageId) {
    final channelMessages = state[channelId] ?? [];
    state = {
      ...state,
      channelId: channelMessages.where((m) => m.id != messageId).toList(),
    };
  }

  void setMessagesForChannel(String channelId, List<Message> messages) {
    state = {
      ...state,
      channelId: messages,
    };
  }

  List<Message> getMessagesForChannel(String channelId) {
    return state[channelId] ?? [];
  }

  void clearChannel(String channelId) {
    final newState = Map<String, List<Message>>.from(state);
    newState.remove(channelId);
    state = newState;
  }

  void reset() {
    state = {};
  }
}

// Selected Channel Provider
final selectedChannelProvider = StateProvider<String?>((ref) {
  // Auto-select first channel when channels are loaded
  final channels = ref.watch(channelsProvider);
  if (channels.isNotEmpty) {
    return channels.first.id;
  }
  return null;
});

