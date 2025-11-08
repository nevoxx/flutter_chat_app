import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// Users Provider
final usersProvider = StateNotifierProvider<UsersController, AsyncValue<List<User>>>((ref) {
  return UsersController(ref);
});

class UsersController extends StateNotifier<AsyncValue<List<User>>> {
  final Ref ref;

  UsersController(this.ref) : super(const AsyncValue.data([]));

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      final users = await apiService.fetchUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addUser(User user) {
    state.whenData((users) {
      state = AsyncValue.data([...users, user]);
    });
  }

  void updateUser(User user) {
    state.whenData((users) {
      state = AsyncValue.data([
        for (final u in users)
          if (u.id == user.id) user else u
      ]);
    });
  }

  void removeUser(String userId) {
    state.whenData((users) {
      state = AsyncValue.data(users.where((u) => u.id != userId).toList());
    });
  }

  void reset() {
    state = const AsyncValue.data([]);
  }
}

