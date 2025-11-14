import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/socket_provider.dart';
import '../../providers/server_info_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/socket_service.dart';
import '../server/server_view_page.dart';
import '../auth/login_page.dart';

class LoadingPage extends ConsumerStatefulWidget {
  const LoadingPage({super.key});

  @override
  ConsumerState<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  bool _isLoadingData = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    ref.read(socketServiceProvider);
  }

  Future<void> _checkAndLoadData() async {
    final socketStatus = ref.read(socketProvider);

    if (socketStatus == SocketStatus.connected && !_isLoadingData) {
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      await ref.read(currentUserProvider.future);
      await ref.read(serverInfoProvider.notifier).fetchServerInfo();
      await ref.read(usersProvider.notifier).fetchUsers();

      final serverInfo = ref.read(serverInfoProvider);
      final users = ref.read(usersProvider);

      if (serverInfo.hasError) {
        throw serverInfo.error ?? Exception('Failed to load server info');
      }

      if (users.hasError) {
        throw users.error ?? Exception('Failed to load users');
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ServerViewPage()),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoadingData = false;
      });
    }
  }

  void _retryLoading() {
    _loadData();
  }

  Future<void> _logout() async {
    ref.read(socketProvider.notifier).disconnect();
    await ref.read(authProvider.notifier).logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketStatus = ref.watch(socketProvider);

    ref.listen<SocketStatus>(socketProvider, (previous, next) {
      if (next == SocketStatus.connected && !_isLoadingData && !_hasError) {
        _checkAndLoadData();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Connecting')),
      body: Center(
        child: _hasError ? _buildErrorView() : _buildLoadingView(socketStatus),
      ),
    );
  }

  Widget _buildLoadingView(SocketStatus socketStatus) {
    String statusText;
    String descriptionText;

    switch (socketStatus) {
      case SocketStatus.disconnected:
        statusText = "Disconnected";
        descriptionText = "Unable to connect to server";
        break;
      case SocketStatus.connecting:
        statusText = "Connecting to server...";
        descriptionText = "Please wait while we establish your connection";
        break;
      case SocketStatus.connected:
        statusText = _isLoadingData ? "Loading data..." : "Connected";
        descriptionText = _isLoadingData
            ? "Fetching user data, channels and users"
            : "Preparing your workspace";
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(statusText, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text(
          descriptionText,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          const Text(
            "Error Loading Data",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? "An unknown error occurred",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _retryLoading,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
