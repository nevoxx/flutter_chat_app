import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/socket_provider.dart';
import 'server_view_page.dart';

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketStatus = ref.watch(socketProvider);

    // Navigate to server view when connected, with a few seconds delay for testing
    if (socketStatus == SocketStatus.connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(
          const Duration(milliseconds: 1500),
        ); // 3 seconds delay for testing
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ServerViewPage()),
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecting'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              "Connecting to server...",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait while we establish your connection",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
