import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../pages/loading/loading_page.dart';

final authProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((
  ref,
) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;
  final _storage = const FlutterSecureStorage();

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await http.post(
        Uri.parse('https://api.blubber.me/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);

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
}
