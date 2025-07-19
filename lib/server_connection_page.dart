import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'socket_provider.dart';

class ServerConnectionPage extends ConsumerWidget {
  const ServerConnectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(socketProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Server')),
      body: Center(
        child: switch (status) {
          SocketStatus.connecting => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Connecting to server..."),
            ],
          ),
          SocketStatus.connected => const Text("Welcome to the server"),
          SocketStatus.disconnected => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text("Disconnected from server"),
            ],
          ),
        },
      ),
    );
  }
}
