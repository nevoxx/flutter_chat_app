import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/users_provider.dart';
import '../users/user_avatar_widget.dart';

class MessageWidget extends ConsumerWidget {
  final Message message;
  final String currentUserId;

  const MessageWidget({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwnMessage = message.userId == currentUserId;
    final accessToken = ref.watch(accessTokenProvider).value;

    // Get user from the users list instead of message.user
    final usersAsync = ref.watch(usersProvider);
    final user = usersAsync.maybeWhen(
      data: (users) {
        try {
          return users.firstWhere((u) => u.id == message.userId);
        } catch (e) {
          // User not found in list, fallback to message.user
          return message.user;
        }
      },
      orElse: () => message.user,
    );

    final displayName = user?.displayName ?? 'Unknown User';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          user != null
              ? UserAvatar(
                  user: user,
                  radius: 16,
                  showOnlineStatus: false,
                  currentUserId: currentUserId,
                  accessToken: accessToken,
                )
              : CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isOwnMessage ? 'You' : displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(message.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Display message content if it exists
                if (message.content != null && message.content!.isNotEmpty)
                  Text(
                    message.content!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                // Display attachments if they exist
                if (message.attachments.isNotEmpty) ...[
                  if (message.content != null && message.content!.isNotEmpty)
                    const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${message.attachments.length} attachment${message.attachments.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
