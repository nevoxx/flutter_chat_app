import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/channel.dart';
import '../../providers/channels_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/messages/message_widget.dart';
import '../../widgets/messages/message_input_widget.dart';
import '../../widgets/channels/channel_list_widget.dart';
import '../../widgets/users/user_list_widget.dart';
import '../auth/login_page.dart';

class ServerViewPage extends ConsumerStatefulWidget {
  const ServerViewPage({super.key});

  @override
  ConsumerState<ServerViewPage> createState() => _ServerViewPageState();
}

class _ServerViewPageState extends ConsumerState<ServerViewPage> {
  bool _usersSidebarCollapsed = false;
  String? _lastLoadedChannelId;

  @override
  void initState() {
    super.initState();
    // Load messages for the first channel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedChannelId = ref.read(selectedChannelProvider);
      if (selectedChannelId != null) {
        _loadMessagesForChannel(selectedChannelId);
      }
    });
  }

  void _loadMessagesForChannel(String channelId) {
    if (_lastLoadedChannelId != channelId) {
      _lastLoadedChannelId = channelId;
      ref.read(messagesProvider.notifier).fetchMessagesForChannel(channelId);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  void _onChannelSelected(String channelId) {
    ref.read(appStateProvider.notifier).setSelectedChannel(channelId);
    _loadMessagesForChannel(channelId);
  }

  void _onSendMessage(String content) {
    // TODO: Implement actual message sending
    print('Sending message: $content');
  }

  void _onToggleUsersSidebar() {
    setState(() {
      _usersSidebarCollapsed = !_usersSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    // Watch providers
    final channels = ref.watch(channelsProvider);
    final usersAsync = ref.watch(usersProvider);
    final selectedChannelId = ref.watch(selectedChannelProvider);

    // Get current channel name
    final currentChannel = channels.firstWhere(
      (ch) => ch.id == selectedChannelId,
      orElse: () => channels.isNotEmpty ? channels.first : Channel(
        id: '',
        name: 'Unknown',
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: 0,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text('# ${currentChannel.name}')]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Connection status indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Connected',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
          // Logout button
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Row(
        children: [
          // Channels Sidebar
          if (isDesktop) ...[
            ChannelListWidget(
              channels: channels,
              selectedChannelId: selectedChannelId,
              onChannelSelected: _onChannelSelected,
              onAddChannel: () {
                // TODO: Implement add channel
              },
            ),
            const VerticalDivider(width: 1),
          ],

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Messages Area
                Expanded(child: _buildMessagesArea()),
                // Message Input
                MessageInputWidget(onSendMessage: _onSendMessage),
              ],
            ),
          ),

          // Users Sidebar
          if (isDesktop) ...[
            const VerticalDivider(width: 1),
            usersAsync.when(
              data: (users) => UserListWidget(
                users: users,
                isCollapsed: _usersSidebarCollapsed,
                onToggleCollapse: _onToggleUsersSidebar,
                currentUserId: 'me',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ],
      ),
      // Mobile/Tablet Drawers
      drawer: (!isDesktop) ? _buildChannelsDrawer() : null,
      endDrawer: (!isDesktop) ? _buildUsersDrawer() : null,
    );
  }

  Widget _buildMessagesArea() {
    final channels = ref.watch(channelsProvider);
    final selectedChannelId = ref.watch(selectedChannelProvider);
    final allMessages = ref.watch(messagesProvider);
    
    final currentChannel = channels.firstWhere(
      (ch) => ch.id == selectedChannelId,
      orElse: () => channels.isNotEmpty ? channels.first : Channel(
        id: '',
        name: 'Unknown',
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: 0,
      ),
    );

    final messagesAsync = selectedChannelId != null 
        ? allMessages[selectedChannelId]
        : null;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Channel Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  '# ${currentChannel.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (MediaQuery.of(context).size.width <= 900) ...[
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.people),
                      tooltip: 'Users',
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                                currentUserId: 'me',
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

  Widget _buildChannelsDrawer() {
    final channels = ref.watch(channelsProvider);
    final selectedChannelId = ref.watch(selectedChannelProvider);

    return Drawer(
      child: SafeArea(
        child: ChannelListWidget(
          channels: channels,
          selectedChannelId: selectedChannelId,
          onChannelSelected: _onChannelSelected,
          onAddChannel: () {
            // TODO: Implement add channel
          },
        ),
      ),
    );
  }

  Widget _buildUsersDrawer() {
    final usersAsync = ref.watch(usersProvider);

    return Drawer(
      child: SafeArea(
        child: usersAsync.when(
          data: (users) => UserListWidget(
            users: users,
            isCollapsed: false,
            onToggleCollapse: () {},
            currentUserId: 'me',
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error loading users')),
        ),
      ),
    );
  }
}
