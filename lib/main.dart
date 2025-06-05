import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Rive text engine to prevent LateInitializationError
  // This fixes issues with Rive files containing text elements
  await RiveFile.initializeText();

  runApp(const ProviderScope(child: RiveExplorerApp()));
}

class RiveExplorerApp extends ConsumerWidget {
  const RiveExplorerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Rive Explorer',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
