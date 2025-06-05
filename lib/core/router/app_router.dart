import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/upload/pages/upload_page.dart';
import '../../features/explorer/pages/explorer_page.dart';

part 'app_router.g.dart';

// Router configuration
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/upload',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/upload',
        name: 'upload',
        builder: (context, state) => const UploadPage(),
      ),
      GoRoute(
        path: '/explorer',
        name: 'explorer',
        builder: (context, state) => const ExplorerPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/upload'),
              child: const Text('Go to Upload'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Extension for convenient navigation
extension AppRouterExtension on GoRouter {
  void goToUpload() => go('/upload');
  void goToExplorer() => go('/explorer');
}

// Helper functions for navigation
class AppNavigation {
  static void goToUpload(BuildContext context) {
    context.go('/upload');
  }

  static void goToExplorer(BuildContext context) {
    context.go('/explorer');
  }

  static void pushToExplorer(BuildContext context) {
    context.push('/explorer');
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static bool canPop(BuildContext context) {
    return context.canPop();
  }
}
