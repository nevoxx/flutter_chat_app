import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

/// A button widget to toggle between light and dark themes
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    return IconButton(
      onPressed: () {
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}

