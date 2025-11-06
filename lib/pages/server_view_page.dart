import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/message.dart';
import '../models/channel.dart';
import '../models/user.dart';
import '../providers/data_provider.dart';
import '../widgets/message_widget.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/channel_list_widget.dart';
import '../widgets/user_list_widget.dart';
import 'login_page.dart';

class ServerViewPage extends ConsumerStatefulWidget {
  const ServerViewPage({super.key});

  @override
  ConsumerState<ServerViewPage> createState() => _ServerViewPageState();
}

class _ServerViewPageState extends ConsumerState<ServerViewPage> {
  bool _usersSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _initializeDummyMessages();
  }

  void _initializeDummyMessages() {
    // Generate dummy messages for the first channel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final channels = ref.read(channelsProvider);
      if (channels.isNotEmpty) {
        final firstChannel = channels.first;
        final dummyMessages = _generateDummyMessages(firstChannel.id);
        ref.read(messagesProvider.notifier).setMessagesForChannel(
          firstChannel.id,
          dummyMessages,
        );
      }
    });
  }

  List<Message> _generateDummyMessages(String channelId) {
    final messageContents = [
      'Hey everyone! 👋',
      'How\'s it going?',
      'I just finished working on that new feature. It was quite challenging but I think it turned out well. The implementation involved several components and required careful consideration of the user experience.',
      'Nice! 👍',
      'Can someone help me with the API documentation?',
      'Sure, what do you need help with?',
      'I\'m having trouble understanding the authentication flow.',
      'The authentication uses JWT tokens. You need to include the token in the Authorization header as "Bearer <token>".',
      'Thanks for the explanation!',
      'No problem! Let me know if you have any other questions.',
      'This is a really long message that demonstrates how the chat handles messages with lots of text. It should wrap properly and look good in the interface. I hope this helps show the different message lengths!',
      'Short reply.',
      'Another short one.',
      'I\'m working on the mobile app now. The responsive design is looking good so far.',
      'Great progress! 🚀',
      'When will the next release be ready?',
      'We\'re aiming for next Friday.',
      'Perfect timing!',
      'Don\'t forget about the team meeting tomorrow at 10 AM.',
      'Got it, thanks for the reminder!',
    ];

    // Get users from provider
    final usersAsync = ref.read(usersProvider);
    final users = usersAsync.maybeWhen(
      data: (data) => data,
      orElse: () => <User>[],
    );
    
    if (users.isEmpty) {
      return [];
    }

    return List.generate(20, (index) {
      final user = users[index % users.length];

      return Message(
        id: 'msg_$index',
        content: messageContents[index % messageContents.length],
        channelId: channelId,
        userId: user.id,
        createdAt: DateTime.now().subtract(Duration(minutes: 20 - index)),
        updatedAt: DateTime.now().subtract(Duration(minutes: 20 - index)),
        channel: Channel(
          id: channelId,
          name: '',
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDefault: 0,
        ),
        attachments: [],
      );
    });
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
    ref.read(selectedChannelProvider.notifier).state = channelId;
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

    final messages = selectedChannelId != null 
        ? allMessages[selectedChannelId] ?? []
        : [];

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
            child: messages.isEmpty
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
