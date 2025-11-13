import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/users_provider.dart';
import '../users/user_list_widget.dart';

class UsersDrawerWidget extends ConsumerWidget {
  final String? currentUserId;

  const UsersDrawerWidget({
    super.key,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Drawer(
      child: SafeArea(
        child: usersAsync.when(
          data: (users) => UserListWidget(
            users: users,
            isCollapsed: false,
            onToggleCollapse: () {
              // Close the drawer on mobile
              Navigator.of(context).pop();
            },
            currentUserId: currentUserId ?? 'me',
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text('Error loading users')),
        ),
      ),
    );
  }
}

