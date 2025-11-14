import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../pages/loading/loading_page.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/user.dart';

final authProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((
  ref,
) {
  return AuthController(ref);
});

// Provider to get the access token
final accessTokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return await storage.getAccessToken();
});

// Provider to get the current user
final currentUserProvider = FutureProvider<User>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  // Let errors propagate so they can be handled properly
  return await apiService.fetchCurrentUser();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> login(String username, String password, String serverUrl) async {
    state = const AsyncValue.loading();
    try {
      final storage = ref.read(storageServiceProvider);

      // Save server URL first
      await storage.setServerUrl(serverUrl);

      // Get the formatted server URL
      final formattedUrl = await storage.getServerUrl();

      final res = await http.post(
        Uri.parse('$formattedUrl/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await storage.setAccessToken(data['accessToken']);
        await storage.setRefreshToken(data['refreshToken']);

        // Invalidate currentUserProvider to trigger fetch after token is saved
        ref.invalidate(currentUserProvider);

        state = const AsyncValue.data(null);

        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoadingPage()),
        );
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearAll();
    state = const AsyncValue.data(null);
  }
}
