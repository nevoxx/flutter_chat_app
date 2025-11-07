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
    final onlineUsers = widget.users
        .where((u) => u.connectionState?.isOnline ?? false)
        .length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isCollapsed ? 60 : 250,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (!widget.isCollapsed) ...[
                  Icon(
                    Icons.people,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Members — $onlineUsers',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  onPressed: widget.onToggleCollapse,
                  icon: Icon(
                    widget.isCollapsed
                        ? Icons.chevron_left
                        : Icons.chevron_right,
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
            radius: 18,
            backgroundColor: isCurrentUser
                ? Theme.of(context).colorScheme.primary
                : Colors.primaries[user.username.hashCode %
                      Colors.primaries.length],
            child: Text(
              user.displayName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          // Online status indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isOnline
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        user.displayName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        user.username,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildCollapsedUserItem(User user) {
    final isCurrentUser = user.id == widget.currentUserId;
    final isOnline = user.connectionState?.isOnline ?? false;

    return Tooltip(
      message: '${user.displayName} (${user.username})',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: [
            Center(
              child: CircleAvatar(
                radius: 16,
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
              right: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
