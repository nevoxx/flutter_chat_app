import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'channels_provider.dart';

// App State Model
class AppState {
  final String? selectedChannelId;
  final bool usersSidebarCollapsed;

  const AppState({
    this.selectedChannelId,
    this.usersSidebarCollapsed = false,
  });

  AppState copyWith({
    String? selectedChannelId,
    bool? usersSidebarCollapsed,
  }) {
    return AppState(
      selectedChannelId: selectedChannelId ?? this.selectedChannelId,
      usersSidebarCollapsed: usersSidebarCollapsed ?? this.usersSidebarCollapsed,
    );
  }
}

// App State Provider
final appStateProvider = StateNotifierProvider<AppStateController, AppState>((ref) {
  return AppStateController(ref);
});

class AppStateController extends StateNotifier<AppState> {
  final Ref ref;

  AppStateController(this.ref) : super(const AppState()) {
    // Check for already loaded channels
    final initialChannels = ref.read(channelsProvider);
    _selectDefaultChannel(initialChannels);
    
    // Listen for future channel changes
    ref.listen(channelsProvider, (previous, next) {
      _selectDefaultChannel(next);
    });
  }
  
  void _selectDefaultChannel(List channels) {
    if (channels.isNotEmpty && state.selectedChannelId == null) {
      // Try to find the first channel with isDefault == 1
      try {
        final defaultChannel = channels.firstWhere((channel) => channel.isDefault == 1);
        state = state.copyWith(selectedChannelId: defaultChannel.id);
      }
      // No default channel found, use the first one
      catch (e) {
        state = state.copyWith(selectedChannelId: channels.first.id);
      }
    }
  }

  void setSelectedChannel(String? channelId) {
    state = state.copyWith(selectedChannelId: channelId);
  }

  void toggleUsersSidebar() {
    state = state.copyWith(usersSidebarCollapsed: !state.usersSidebarCollapsed);
  }

  void setUsersSidebarCollapsed(bool collapsed) {
    state = state.copyWith(usersSidebarCollapsed: collapsed);
  }
}

// Convenience providers for backward compatibility
final selectedChannelProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).selectedChannelId;
});

