import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/messages_provider.dart';
import '../../providers/app_state_provider.dart';
import '../messages/message_widget.dart';

class MessagesAreaWidget extends ConsumerWidget {
  final String? currentUserId;

  const MessagesAreaWidget({
    super.key,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChannelId = ref.watch(selectedChannelProvider);
    final allMessages = ref.watch(messagesProvider);

    final messagesAsync = selectedChannelId != null 
        ? allMessages[selectedChannelId]
        : null;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Messages List
          Expanded(
            child: messagesAsync == null
                ? Center(
                    child: Text(
                      'Select a channel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : messagesAsync.when(
                    data: (messages) => messages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return MessageWidget(
                                message: messages[index],
                                currentUserId: currentUserId ?? 'me',
                              );
                            },
                          ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading messages',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (selectedChannelId != null) {
                                ref.read(messagesProvider.notifier)
                                    .fetchMessagesForChannel(selectedChannelId);
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

