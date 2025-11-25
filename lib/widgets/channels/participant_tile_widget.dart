import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/users/user_avatar_widget.dart';

class ParticipantTileWidget extends ConsumerWidget {
  final User user;
  final bool isCurrentUser;

  const ParticipantTileWidget({
    super.key,
    required this.user,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessTokenAsync = ref.watch(accessTokenProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.mic,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          accessTokenAsync.when(
            data: (token) => UserAvatar(
              user: user,
              radius: 14,
              currentUserId: isCurrentUser ? user.id : null,
              accessToken: token,
              dimension: 'small',
            ),
            loading: () => const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => UserAvatar(
              user: user,
              radius: 14,
              currentUserId: isCurrentUser ? user.id : null,
              dimension: 'small',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCurrentUser ? '${user.displayName} (You)' : user.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}



