import 'package:flutter/material.dart';
import '../../models/channel.dart';

class ChannelListWidget extends StatelessWidget {
  final List<Channel> channels;
  final String? selectedChannelId;
  final Function(String) onChannelSelected;
  final VoidCallback? onAddChannel;

  const ChannelListWidget({
    super.key,
    required this.channels,
    this.selectedChannelId,
    required this.onChannelSelected,
    this.onAddChannel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.tag),
                const SizedBox(width: 8),
                Text(
                  'Channels',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onAddChannel != null)
                  IconButton(
                    onPressed: onAddChannel,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Channel',
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Channels List
          Expanded(
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return _buildChannelItem(channel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelItem(Channel channel) {
    final isSelected = selectedChannelId == channel.id;

    return ListTile(
      title: Text('# ${channel.name}'),
      selected: isSelected,
      onTap: () => onChannelSelected(channel.id),
    );
  }
}
