import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/connected_user.dart';
import '../../providers/auth_provider.dart';
import 'user_avatar_widget.dart';

class UserListWidget extends ConsumerStatefulWidget {
  final List<ConnectedUser> users;
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
  ConsumerState<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends ConsumerState<UserListWidget> {
  @override
  Widget build(BuildContext context) {
    // Sort users: online users first, then by display name
    final sortedUsers = List<ConnectedUser>.from(widget.users)
      ..sort((a, b) {
        final aOnline = a.connectionState.isOnline;
        final bOnline = b.connectionState.isOnline;

        // First, sort by online status (online users first)
        if (aOnline != bOnline) {
          return bOnline ? 1 : -1; // Online users come first
        }

        // Then, sort by display name
        return a.user.displayName.toLowerCase().compareTo(
          b.user.displayName.toLowerCase(),
        );
      });

    final onlineUsers = sortedUsers
        .where((u) => u.connectionState.isOnline)
        .length;

    return Container(
      width: widget.isCollapsed ? 60 : 250,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // Header
          Container(
            padding: widget.isCollapsed
                ? const EdgeInsets.symmetric(horizontal: 6, vertical: 8)
                : const EdgeInsets.all(16),
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
                ? _buildCollapsedUsersList(sortedUsers)
                : _buildExpandedUsersList(sortedUsers),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedUsersList(List<ConnectedUser> sortedUsers) {
    return ListView.builder(
      itemCount: sortedUsers.length,
      itemBuilder: (context, index) {
        final connectedUser = sortedUsers[index];
        return _buildUserItem(connectedUser);
      },
    );
  }

  Widget _buildCollapsedUsersList(List<ConnectedUser> sortedUsers) {
    return ListView.builder(
      itemCount: sortedUsers.length,
      itemBuilder: (context, index) {
        final connectedUser = sortedUsers[index];
        return _buildCollapsedUserItem(connectedUser);
      },
    );
  }

  Widget _buildUserItem(ConnectedUser connectedUser) {
    final user = connectedUser.user;
    final isCurrentUser = user.id == widget.currentUserId;
    final accessToken = ref.watch(accessTokenProvider).value;

    return ListTile(
      leading: UserAvatar(
        user: user,
        radius: 18,
        showOnlineStatus: true,
        currentUserId: widget.currentUserId,
        accessToken: accessToken,
        connectionState: connectedUser.connectionState,
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

  Widget _buildCollapsedUserItem(ConnectedUser connectedUser) {
    final user = connectedUser.user;
    final accessToken = ref.watch(accessTokenProvider).value;

    return Tooltip(
      message: '${user.displayName} (${user.username})',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: UserAvatar(
            user: user,
            radius: 16,
            showOnlineStatus: true,
            currentUserId: widget.currentUserId,
            accessToken: accessToken,
            connectionState: connectedUser.connectionState,
          ),
        ),
      ),
    );
  }
}
