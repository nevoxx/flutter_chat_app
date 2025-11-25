import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'participant_tile_widget.dart';

class ParticipantsListWidget extends StatelessWidget {
  final List<User> participants;
  final String? currentUserId;

  const ParticipantsListWidget({
    super.key,
    required this.participants,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 8,
        bottom: 8,
        top: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: participants.map((user) {
          final isCurrentUser = currentUserId != null && user.id == currentUserId;
          return ParticipantTileWidget(
            user: user,
            isCurrentUser: isCurrentUser,
          );
        }).toList(),
      ),
    );
  }
}



