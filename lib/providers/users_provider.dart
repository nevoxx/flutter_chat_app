import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connected_user.dart';
import '../services/api_service.dart';

final usersProvider =
    StateNotifierProvider<UsersController, AsyncValue<List<ConnectedUser>>>((
      ref,
    ) {
      return UsersController(ref);
    });

class UsersController extends StateNotifier<AsyncValue<List<ConnectedUser>>> {
  final Ref ref;

  UsersController(this.ref) : super(const AsyncValue.data([]));

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      final connectedUsers = await apiService.fetchUsers();
      state = AsyncValue.data(connectedUsers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
