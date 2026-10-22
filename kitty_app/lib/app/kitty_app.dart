import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/config/app_constants.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/providers/settings_controller.dart';

import '../shared/widgets/feedback/connectivity_banner_wrapper.dart';

/// Root application widget configured with Riverpod, GoRouter declarative routing,
/// dual-surface luxury theme, and global offline network awareness.
class KittyApp extends ConsumerWidget {
  const KittyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        return ColoredBox(
          color: const Color(0xFFFAF7F2), // Warm Gold Canvas: eliminates cold-launch blank frame
          child: ConnectivityBannerWrapper(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
