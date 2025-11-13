import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/messages_provider.dart';
import '../../providers/app_state_provider.dart';
import '../messages/message_widget.dart';

class MessagesAreaWidget extends ConsumerStatefulWidget {
  final String? currentUserId;

  const MessagesAreaWidget({super.key, this.currentUserId});

  @override
  ConsumerState<MessagesAreaWidget> createState() => _MessagesAreaWidgetState();
}

class _MessagesAreaWidgetState extends ConsumerState<MessagesAreaWidget> {
  final ScrollController _scrollController = ScrollController();
  String? _currentChannelId;
  bool _needsScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomImmediate() {
    if (_scrollController.hasClients && mounted) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        _scrollController.jumpTo(maxScroll);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChannelId = ref.watch(selectedChannelProvider);
    final allMessages = ref.watch(messagesProvider);

    // Detect channel change
    if (selectedChannelId != _currentChannelId) {
      _currentChannelId = selectedChannelId;
      _needsScroll = true;
    }

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
                    data: (messages) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      // Scroll to bottom only when flag is set
                      if (_needsScroll) {
                        _needsScroll = false;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottomImmediate();
                        });
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageWidget(
                            message: messages[index],
                            currentUserId: widget.currentUserId ?? 'me',
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (selectedChannelId != null) {
                                ref
                                    .read(messagesProvider.notifier)
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
