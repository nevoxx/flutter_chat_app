import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerViewPage extends StatefulWidget {
  const ServerViewPage({super.key});

  @override
  State<ServerViewPage> createState() => _ServerViewPageState();
}

class _ServerViewPageState extends State<ServerViewPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedChannel = 'general';
  bool _usersSidebarCollapsed = false;

  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog
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
      // Clear stored tokens
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');

      // Navigate back to login page
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text('# ${_selectedChannel ?? 'general'}')]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Simple connection indicator
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
            _buildChannelsSidebar(),
            const VerticalDivider(width: 1),
          ],

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Messages Area
                Expanded(child: _buildMessagesArea()),
                // Message Input
                _buildMessageInput(),
              ],
            ),
          ),

          // Users Sidebar
          if (isDesktop) ...[
            const VerticalDivider(width: 1),
            _buildUsersSidebar(),
          ],
        ],
      ),
      // Mobile/Tablet Drawers
      drawer: (!isDesktop) ? _buildChannelsDrawer() : null,
      endDrawer: (!isDesktop) ? _buildUsersDrawer() : null,
    );
  }

  Widget _buildChannelsSidebar() {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.tag),
                const SizedBox(width: 8),
                Text(
                  'Channels',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: Add channel functionality
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Channel',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Channels List
          Expanded(
            child: ListView(
              children: [
                _buildChannelItem('general', 'General'),
                _buildChannelItem('random', 'Random'),
                _buildChannelItem('help', 'Help'),
                _buildChannelItem('announcements', 'Announcements'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelsDrawer() {
    return Drawer(child: _buildChannelsSidebar());
  }

  Widget _buildChannelItem(String id, String name) {
    final isSelected = _selectedChannel == id;
    return ListTile(
      title: Text('# $name'),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedChannel = id;
        });
      },
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
                  '# ${_selectedChannel ?? 'general'}',
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
              itemCount: 20, // Dummy messages
              itemBuilder: (context, index) {
                return _buildMessageItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(int index) {
    final isOwnMessage = index % 3 == 0;
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

    final message = messages[index % messages.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isOwnMessage
                ? Theme.of(context).colorScheme.primary
                : Colors.primaries[index % Colors.primaries.length],
            child: Text(
              isOwnMessage ? 'Me' : 'U${index + 1}',
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
                      isOwnMessage ? 'You' : 'User ${index + 1}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                // TODO: Send message functionality
                _messageController.clear();
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              // TODO: Send message functionality
              _messageController.clear();
            },
            icon: const Icon(Icons.send),
            tooltip: 'Send Message',
          ),
        ],
      ),
    );
  }

  Widget _buildUsersSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _usersSidebarCollapsed ? 60 : 250,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (!_usersSidebarCollapsed) ...[
                  const Icon(Icons.people),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Online Users',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '5',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  onPressed: () {
                    setState(() {
                      _usersSidebarCollapsed = !_usersSidebarCollapsed;
                    });
                  },
                  icon: Icon(
                    _usersSidebarCollapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                  ),
                  tooltip: _usersSidebarCollapsed ? 'Expand' : 'Collapse',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Users List
          Expanded(
            child: _usersSidebarCollapsed
                ? _buildCollapsedUsersList()
                : _buildExpandedUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedUsersList() {
    return ListView(
      children: [
        _buildUserItem('User 1', true),
        _buildUserItem('User 2', true),
        _buildUserItem('User 3', false),
        _buildUserItem('User 4', true),
        _buildUserItem('User 5', true),
        _buildUserItem('You', true, isCurrentUser: true),
      ],
    );
  }

  Widget _buildCollapsedUsersList() {
    return ListView(
      children: [
        _buildCollapsedUserItem('User 1', true),
        _buildCollapsedUserItem('User 2', true),
        _buildCollapsedUserItem('User 3', false),
        _buildCollapsedUserItem('User 4', true),
        _buildCollapsedUserItem('User 5', true),
        _buildCollapsedUserItem('You', true, isCurrentUser: true),
      ],
    );
  }

  Widget _buildCollapsedUserItem(
    String name,
    bool isOnline, {
    bool isCurrentUser = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Center(
            child: CircleAvatar(
              backgroundColor: isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.primaries[name.hashCode % Colors.primaries.length],
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    width: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersDrawer() {
    return Drawer(child: _buildUsersSidebar());
  }

  Widget _buildUserItem(
    String name,
    bool isOnline, {
    bool isCurrentUser = false,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: isCurrentUser
                ? Theme.of(context).colorScheme.primary
                : Colors.primaries[name.hashCode % Colors.primaries.length],
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: isOnline ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }
}
