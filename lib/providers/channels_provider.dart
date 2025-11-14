import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';

// Channels Provider
final channelsProvider =
    StateNotifierProvider<ChannelsController, List<Channel>>((ref) {
      return ChannelsController();
    });

class ChannelsController extends StateNotifier<List<Channel>> {
  ChannelsController() : super([]);

  void setChannels(List<Channel> channels) {
    // Sort channels by sortOrder
    final sortedChannels = [...channels]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = sortedChannels;
  }

  void addChannel(Channel channel) {
    state = [...state, channel];
    _sortChannels();
  }

  void updateChannel(Channel channel) {
    state = [
      for (final c in state)
        if (c.id == channel.id) channel else c,
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
