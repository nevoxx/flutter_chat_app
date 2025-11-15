import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel.dart';
import '../../models/user.dart';
import '../../providers/voice_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/auth_provider.dart';
import 'participants_list_widget.dart';

class ChannelListWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceProvider);
    final usersAsync = ref.watch(usersProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    // Listen for voice errors
    ref.listen<VoiceState>(voiceProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice error: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

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
                Icon(
                  Icons.tag,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
                return _buildChannelItem(
                  context,
                  ref,
                  channel,
                  voiceState,
                  usersAsync,
                  currentUserAsync,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelItem(
    BuildContext context,
    WidgetRef ref,
    Channel channel,
    VoiceState voiceState,
    AsyncValue<List<dynamic>> usersAsync,
    AsyncValue<dynamic> currentUserAsync,
  ) {
    final isSelected = selectedChannelId == channel.id;
    final isInVoice =
        voiceState.currentChannelId == channel.id && voiceState.isConnected;
    final isConnecting =
        voiceState.currentChannelId == channel.id && voiceState.isConnecting;
    final voiceController = ref.read(voiceProvider.notifier);

    // Get participant IDs for this channel (includes local participant)
    final participantIds = isInVoice ? voiceState.participantIds : <String>[];

    // Get current user ID
    final currentUserId = currentUserAsync.maybeWhen(
      data: (user) => user.id,
      orElse: () => null,
    );

    // Get user info for participants
    final List<User> participants = usersAsync.maybeWhen(
      data: (users) {
        final participantUsers = <User>[
          ...users
              .where((user) => participantIds.contains(user.user.id))
              .map((user) => user.user),
        ];

        // If current user is in voice but not in the users list, add them
        if (currentUserId != null &&
            participantIds.contains(currentUserId) &&
            !participantUsers.any((u) => u.id == currentUserId)) {
          // Try to get current user from currentUserAsync
          final currentUser = currentUserAsync.maybeWhen(
            data: (user) => user,
            orElse: () => null,
          );
          if (currentUser != null) {
            participantUsers.add(currentUser);
          }
        }

        return participantUsers;
      },
      orElse: () {
        // If users list is not loaded, but we have current user and they're in voice
        if (currentUserId != null && participantIds.contains(currentUserId)) {
          final currentUser = currentUserAsync.maybeWhen(
            data: (user) => user,
            orElse: () => null,
          );
          return currentUser != null ? [currentUser] : <User>[];
        }
        return <User>[];
      },
    );

    return _ChannelItem(
      channel: channel,
      isSelected: isSelected,
      isInVoice: isInVoice,
      isConnecting: isConnecting,
      participants: participants,
      currentUserId: currentUserId,
      onChannelSelected: onChannelSelected,
      onJoinVoice: () async {
        try {
          await voiceController.joinVoice(channel.id);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to join voice: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      },
      onLeaveVoice: () => voiceController.leaveVoice(),
    );
  }
}

class _ChannelItem extends ConsumerStatefulWidget {
  final Channel channel;
  final bool isSelected;
  final bool isInVoice;
  final bool isConnecting;
  final List<User> participants;
  final String? currentUserId;
  final Function(String) onChannelSelected;
  final Future<void> Function() onJoinVoice;
  final VoidCallback onLeaveVoice;

  const _ChannelItem({
    required this.channel,
    required this.isSelected,
    required this.isInVoice,
    required this.isConnecting,
    required this.participants,
    this.currentUserId,
    required this.onChannelSelected,
    required this.onJoinVoice,
    required this.onLeaveVoice,
  });

  @override
  ConsumerState<_ChannelItem> createState() => _ChannelItemState();
}

class _ChannelItemState extends ConsumerState<_ChannelItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            widget.isInVoice ? Icons.volume_up : Icons.tag,
            size: 18,
            color: widget.isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(
            widget.channel.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: widget.isSelected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isConnecting)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (!widget.isInVoice && !widget.isConnecting)
                IconButton(
                  icon: const Icon(Icons.phone, size: 16),
                  onPressed: widget.onJoinVoice,
                  tooltip: 'Join Voice',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 16,
                ),
              if (widget.isInVoice)
                IconButton(
                  icon: const Icon(Icons.call_end, size: 16),
                  onPressed: widget.onLeaveVoice,
                  tooltip: 'Leave Voice',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 16,
                ),
            ],
          ),
          selected: widget.isSelected,
          selectedTileColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF404249)
              : const Color(0xFFE3E5E8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          onTap: () => widget.onChannelSelected(widget.channel.id),
        ),
        // Show participants if in voice
        if (widget.isInVoice)
          ParticipantsListWidget(
            participants: widget.participants,
            currentUserId: widget.currentUserId,
          ),
      ],
    );
  }
}
