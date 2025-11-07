import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserListWidget extends StatefulWidget {
  final List<User> users;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final String currentUserId;

  const UserListWidget({
    super.key,
    required this.users,
    this.isCollapsed = false,
    required this.onToggleCollapse,
    required this.currentUserId,
  });

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isCollapsed ? 60 : 250,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (!widget.isCollapsed) ...[
                  const Icon(Icons.people),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Users',
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
                      '${widget.users.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  onPressed: widget.onToggleCollapse,
                  icon: Icon(
                    widget.isCollapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                  ),
                  tooltip: widget.isCollapsed ? 'Expand' : 'Collapse',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Users List
          Expanded(
            child: widget.isCollapsed
                ? _buildCollapsedUsersList()
                : _buildExpandedUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedUsersList() {
    return ListView.builder(
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final user = widget.users[index];
        return _buildUserItem(user);
      },
    );
  }

  Widget _buildCollapsedUsersList() {
    return ListView.builder(
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final user = widget.users[index];
        return _buildCollapsedUserItem(user);
      },
    );
  }

  Widget _buildUserItem(User user) {
    final isCurrentUser = user.id == widget.currentUserId;
    final isOnline = user.connectionState?.isOnline ?? false;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: isCurrentUser
                ? Theme.of(context).colorScheme.primary
                : Colors.primaries[user.username.hashCode %
                      Colors.primaries.length],
            child: Text(
              user.displayName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Online status indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
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
        user.displayName,
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        user.username,
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildCollapsedUserItem(User user) {
    final isCurrentUser = user.id == widget.currentUserId;
    final isOnline = user.connectionState?.isOnline ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Center(
            child: CircleAvatar(
              backgroundColor: isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.primaries[user.username.hashCode %
                        Colors.primaries.length],
              child: Text(
                user.displayName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          // Online status indicator
          Positioned(
            bottom: 0,
            right: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
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
    );
  }
}
