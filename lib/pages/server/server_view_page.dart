import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel.dart';
import '../../providers/channels_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/socket_provider.dart';
import '../../services/socket_service.dart';
import '../../widgets/messages/message_input_widget.dart';
import '../../widgets/channels/channel_list_widget.dart';
import '../../widgets/users/user_list_widget.dart';
import '../../widgets/chat/messages_area_widget.dart';
import '../../widgets/server/channels_drawer_widget.dart';
import '../../widgets/server/users_drawer_widget.dart';
import '../../widgets/server/server_header_widget.dart';
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
      ref.read(socketProvider.notifier).disconnect();
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
    final selectedChannelId = ref.read(selectedChannelProvider);
    if (selectedChannelId == null) return;

    final socketService = ref.read(socketServiceProvider);
    socketService.sendChatMessage(
      channelId: selectedChannelId,
      content: content,
    );
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

    final channels = ref.watch(channelsProvider);
    final usersAsync = ref.watch(usersProvider);
    final selectedChannelId = ref.watch(selectedChannelProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.requireValue.id;
    ref.listen<String?>(selectedChannelProvider, (previous, next) {
      if (next != null && next != previous) {
        _loadMessagesForChannel(next);
      }
    });

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

    return Scaffold(
      appBar: ServerHeaderWidget(
        currentChannel: currentChannel,
        isDesktop: isDesktop,
        onLogout: () => _logout(context),
      ),
      body: Row(
        children: [
          if (isDesktop) ...[
            ChannelListWidget(
              channels: channels,
              selectedChannelId: selectedChannelId,
              onChannelSelected: _onChannelSelected,
              onAddChannel: () {},
            ),
            const VerticalDivider(width: 1),
          ],

          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: MessagesAreaWidget(currentUserId: currentUserId),
                ),
                MessageInputWidget(onSendMessage: _onSendMessage),
              ],
            ),
          ),

          if (isDesktop) ...[
            const VerticalDivider(width: 1),
            usersAsync.when(
              data: (users) => UserListWidget(
                users: users,
                isCollapsed: _usersSidebarCollapsed,
                onToggleCollapse: _onToggleUsersSidebar,
                currentUserId: currentUserId,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ],
      ),
      drawer: (!isDesktop)
          ? ChannelsDrawerWidget(
              onChannelSelected: _onChannelSelected,
              onAddChannel: () {},
            )
          : null,
      endDrawer: (!isDesktop)
          ? UsersDrawerWidget(currentUserId: currentUserId)
          : null,
    );
  }
}
