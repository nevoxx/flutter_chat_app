import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

enum SocketStatus { disconnected, connecting, connected }

final socketProvider = StateNotifierProvider<SocketController, SocketStatus>((
  ref,
) {
  return SocketController(ref);
});

class SocketController extends StateNotifier<SocketStatus> {
  final Ref ref;
  IO.Socket? _socket;
  final _storage = FlutterSecureStorage();

  SocketController(this.ref) : super(SocketStatus.disconnected) {
    _init();
  }

  Future<void> _init() async {
    state = SocketStatus.connecting;

    final token = await _storage.read(key: 'accessToken');

    if (token == null) {
      state = SocketStatus.disconnected;
      return;
    }

    _socket = IO.io(
      'https://api.blubber.me',
      IO.OptionBuilder()
          .setPath('/server')
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      state = SocketStatus.connected;
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[Socket] Disconnected: $reason');
      state = SocketStatus.disconnected;
    });

    _socket!.onError((error) {
      debugPrint('[Socket] Error: $error');
    });

    _socket!.onConnectError((error) {
      debugPrint('[Socket] ConnectError: $error');
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    state = SocketStatus.disconnected;
  }

  Future<void> reconnect() async {
    if (state == SocketStatus.connecting) return;

    _socket?.disconnect();
    state = SocketStatus.disconnected;

    // Wait a bit before reconnecting
    await Future.delayed(const Duration(seconds: 1));

    await _init();
  }

  IO.Socket? get socket => _socket;
}
