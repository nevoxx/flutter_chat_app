import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/message.dart';
import '../models/channel.dart';
import '../models/user.dart';
import '../widgets/message_widget.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/channel_list_widget.dart';
import '../widgets/user_list_widget.dart';
import 'login_page.dart';

class ServerViewPage extends StatefulWidget {
  const ServerViewPage({super.key});

  @override
  State<ServerViewPage> createState() => _ServerViewPageState();
}

class _ServerViewPageState extends State<ServerViewPage> {
  String? _selectedChannelId = 'general';
  bool _usersSidebarCollapsed = false;

  // Dummy data
  late List<Channel> _channels;
  late List<User> _users;
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _initializeDummyData();
  }

  void _initializeDummyData() {
    _channels = [
      Channel(
        id: 'general',
        name: 'General',
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: 1,
      ),
      Channel(
        id: 'random',
        name: 'Random',
        sortOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: 0,
      ),
      Channel(
        id: 'help',
        name: 'Help',
        sortOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: 0,
      ),
      Channel(
        id: 'announcements',
        name: 'Announcements',
        sortOrder: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: 0,
      ),
    ];

    _users = [
      User(
        id: '1',
        username: 'user1',
        displayName: 'User 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSystemUser: 0,
        roles: [],
        permissions: [],
      ),
      User(
        id: '2',
        username: 'user2',
        displayName: 'User 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSystemUser: 0,
        roles: [],
        permissions: [],
      ),
      User(
        id: '3',
        username: 'user3',
        displayName: 'User 3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSystemUser: 0,
        roles: [],
        permissions: [],
      ),
      User(
        id: '4',
        username: 'user4',
        displayName: 'User 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSystemUser: 0,
        roles: [],
        permissions: [],
      ),
      User(
        id: '5',
        username: 'user5',
        displayName: 'User 5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSystemUser: 0,
        roles: [],
        permissions: [],
      ),
      User(
        id: 'me',
        username: 'currentuser',
        displayName: 'You',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSystemUser: 0,
        roles: [],
        permissions: [],
      ),
    ];

    _messages = _generateDummyMessages();
  }

  List<Message> _generateDummyMessages() {
    final messages = [
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

    return List.generate(20, (index) {
      final isOwnMessage = index % 3 == 0;
      final user = isOwnMessage
          ? _users.last
          : _users[index % (_users.length - 1)];
      final channel = _channels.first;

      return Message(
        id: 'msg_$index',
        content: messages[index % messages.length],
        channelId: channel.id,
        userId: user.id,
        createdAt: DateTime.now().subtract(Duration(minutes: 20 - index)),
        updatedAt: DateTime.now().subtract(Duration(minutes: 20 - index)),
        channel: channel,
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
    setState(() {
      _selectedChannelId = channelId;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text('# ${_selectedChannelId ?? 'general'}')]),
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
              channels: _channels,
              selectedChannelId: _selectedChannelId,
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
            UserListWidget(
              users: _users,
              isCollapsed: _usersSidebarCollapsed,
              onToggleCollapse: _onToggleUsersSidebar,
              currentUserId: 'me',
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
                  '# ${_selectedChannelId ?? 'general'}',
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageWidget(
                  message: _messages[index],
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
    return Drawer(
      child: SafeArea(
        child: ChannelListWidget(
          channels: _channels,
          selectedChannelId: _selectedChannelId,
          onChannelSelected: _onChannelSelected,
          onAddChannel: () {
            // TODO: Implement add channel
          },
        ),
      ),
    );
  }

  Widget _buildUsersDrawer() {
    return Drawer(
      child: SafeArea(
        child: UserListWidget(
          users: _users,
          isCollapsed: false,
          onToggleCollapse: () {},
          currentUserId: 'me',
        ),
      ),
    );
  }
}
