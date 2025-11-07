import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final double radius;
  final bool showOnlineStatus;
  final String? currentUserId;
  final String? accessToken;
  final String dimension;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 18,
    this.showOnlineStatus = false,
    this.currentUserId,
    this.accessToken,
    this.dimension = 'small',
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = currentUserId != null && user.id == currentUserId;
    final isOnline = user.connectionState?.isOnline ?? false;
    final baseAvatarUrl = user.profilePicture?.attachmentUrl;
    
    // Append access token and dimension to the URL if available
    String? avatarUrl = baseAvatarUrl;
    if (baseAvatarUrl != null && baseAvatarUrl.isNotEmpty && accessToken != null) {
      avatarUrl = '$baseAvatarUrl?token=$accessToken&dimension=$dimension';
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: isCurrentUser
          ? Theme.of(context).colorScheme.primary
          : Colors.primaries[user.username.hashCode % Colors.primaries.length],
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl) as ImageProvider
          : null,
      onBackgroundImageError: avatarUrl != null && avatarUrl.isNotEmpty
          ? (exception, stackTrace) {
              // Silently fail and show fallback text
            }
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(
              user.displayName[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.75,
              ),
            )
          : null,
    );

    if (!showOnlineStatus) {
      return avatar;
    }

    return Stack(
      children: [
        avatar,
        // Online status indicator
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: radius * 0.7,
            height: radius * 0.7,
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: radius * 0.15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

