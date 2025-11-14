import 'user.dart';
import 'connection_state.dart';

class ConnectedUser {
  final User user;
  final ConnectionState connectionState;

  const ConnectedUser({
    required this.user,
    required this.connectionState,
  });

  factory ConnectedUser.fromJson(Map<String, dynamic> json) {
    return ConnectedUser(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      connectionState: ConnectionState.fromJson(
        json['connectionState'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'connectionState': connectionState.toJson(),
    };
  }

}

