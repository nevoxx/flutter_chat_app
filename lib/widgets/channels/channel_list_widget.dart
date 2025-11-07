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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.tag, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Text Channels',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (onAddChannel != null)
                  IconButton(
                    onPressed: onAddChannel,
                    icon: const Icon(Icons.add, size: 20),
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
                return _buildChannelItem(context, channel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelItem(BuildContext context, Channel channel) {
    final isSelected = selectedChannelId == channel.id;

    return ListTile(
      leading: Icon(
        Icons.tag,
        size: 18,
        color: isSelected 
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        channel.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF404249)
          : const Color(0xFFE3E5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      onTap: () => onChannelSelected(channel.id),
    );
  }
}
