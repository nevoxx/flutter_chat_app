import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel.dart';
import '../../providers/server_info_provider.dart';
import '../ui/theme_toggle_button.dart';

class ServerHeaderWidget extends ConsumerWidget implements PreferredSizeWidget {
  final Channel currentChannel;
  final bool isDesktop;
  final VoidCallback onLogout;

  const ServerHeaderWidget({
    super.key,
    required this.currentChannel,
    required this.isDesktop,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverInfoAsync = ref.watch(serverInfoProvider);
    final serverName = serverInfoAsync.valueOrNull?.name ?? 'Server';

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Server name section (desktop only)
              if (isDesktop) ...[
                Container(
                width: 250,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        serverName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.wifi, size: 18, color: Colors.green),
                  ],
                ),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ],
              // Rest of AppBar with channel name and actions
              Expanded(
                child: Container(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Menu button for mobile
                    if (!isDesktop)
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu),
                          tooltip: 'Show Channels',
                        ),
                      ),
                    if (!isDesktop) const SizedBox(width: 4),
                    const Icon(Icons.tag, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentChannel.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Users button for mobile
                    if (!isDesktop)
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          icon: const Icon(Icons.people),
                          tooltip: 'Show Members',
                        ),
                      ),
                    // Theme toggle button
                    const ThemeToggleButton(),
                    // Logout button
                    IconButton(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
