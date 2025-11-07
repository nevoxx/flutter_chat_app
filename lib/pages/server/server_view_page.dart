import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/channel.dart';
import '../../providers/channels_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/messages/message_input_widget.dart';
import '../../widgets/channels/channel_list_widget.dart';
import '../../widgets/users/user_list_widget.dart';
import '../../widgets/chat/messages_area_widget.dart';
import '../../widgets/partials/channels_drawer_widget.dart';
import '../../widgets/partials/users_drawer_widget.dart';
import '../../widgets/ui/theme_toggle_button.dart';
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
        title: Row(children: [
          const Icon(Icons.tag, size: 20),
          const SizedBox(width: 8),
          Text(currentChannel.name),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).dividerColor,
            height: 1,
          ),
        ),
        actions: [
          // Users button (mobile/tablet only)
          if (!isDesktop)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.people),
                tooltip: 'Show Members',
              ),
            ),
          // Connection status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Connected',
                  style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Theme toggle button
          const ThemeToggleButton(),
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
                Expanded(
                  child: MessagesAreaWidget(
                    currentUserId: 'me',
                  ),
                ),
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
      drawer: (!isDesktop) 
          ? ChannelsDrawerWidget(
              onChannelSelected: _onChannelSelected,
              onAddChannel: () {
                // TODO: Implement add channel
              },
            )
          : null,
      endDrawer: (!isDesktop) 
          ? UsersDrawerWidget(
              currentUserId: 'me',
            )
          : null,
    );
  }
}
