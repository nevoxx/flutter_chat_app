import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/channels_provider.dart';
import '../../providers/app_state_provider.dart';
import '../channels/channel_list_widget.dart';

class ChannelsDrawerWidget extends ConsumerWidget {
  final Function(String) onChannelSelected;
  final VoidCallback? onAddChannel;

  const ChannelsDrawerWidget({
    super.key,
    required this.onChannelSelected,
    this.onAddChannel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = ref.watch(channelsProvider);
    final selectedChannelId = ref.watch(selectedChannelProvider);

    return Drawer(
      child: SafeArea(
        child: ChannelListWidget(
          channels: channels,
          selectedChannelId: selectedChannelId,
          onChannelSelected: onChannelSelected,
          onAddChannel: onAddChannel ?? () {
            // Default empty callback
          },
        ),
      ),
    );
  }
}

