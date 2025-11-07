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
    // Auto-select first channel when channels are loaded
    ref.listen(channelsProvider, (previous, next) {
      if (next.isNotEmpty && state.selectedChannelId == null) {
        state = state.copyWith(selectedChannelId: next.first.id);
      }
    });
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

