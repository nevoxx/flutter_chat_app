import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel.dart';
import '../../providers/channels_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/socket_provider.dart';
import '../../providers/server_info_provider.dart';
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
      // Disconnect socket
      ref.read(socketProvider.notifier).disconnect();

      // Clear all stored data
      await ref.read(authProvider.notifier).logout();

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
    final serverInfoAsync = ref.watch(serverInfoProvider);

    // Listen for channel changes outside of build
    ref.listen<String?>(selectedChannelProvider, (previous, next) {
      if (next != null && next != previous) {
        _loadMessagesForChannel(next);
      }
    });

    // Get current channel name
    final currentChannel = channels.firstWhere(
      (ch) => ch.id == selectedChannelId,
      orElse: () => channels.isNotEmpty
          ? channels.first
          : Channel(
              id: '',
              name: 'Unknown',
              sortOrder: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isDefault: 0,
            ),
    );

    // Get server name
    final serverName = serverInfoAsync.valueOrNull?.name ?? 'Server';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: SafeArea(
          child: Row(
            children: [
              // Server name section
              Container(
                width: 250,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        serverName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.wifi, size: 18, color: Colors.green),
                  ],
                ),
              ),
              // Vertical divider
              Container(
                width: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              // Rest of AppBar with channel name and actions
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.tag, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        currentChannel.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      // Users button (mobile/tablet only)
                      if (!isDesktop)
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () =>
                                Scaffold.of(context).openEndDrawer(),
                            icon: const Icon(Icons.people),
                            tooltip: 'Show Members',
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
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
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
                Expanded(child: MessagesAreaWidget(currentUserId: 'me')),
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
      endDrawer: (!isDesktop) ? UsersDrawerWidget(currentUserId: 'me') : null,
    );
  }
}
