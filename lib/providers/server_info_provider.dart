import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/server_info.dart';
import 'channels_provider.dart';
import 'users_provider.dart';

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

