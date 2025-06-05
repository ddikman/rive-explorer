import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/file_info_panel.dart';
import '../widgets/rive_preview_panel.dart';
import '../widgets/content_explorer_panel.dart';
import '../widgets/selection_control_panel.dart';
import '../providers/explorer_state_provider.dart';
import '../../upload/providers/upload_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class ExplorerPage extends ConsumerWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-select first artboard when a new file is loaded
    ref.listen(uploadNotifierProvider, (previous, current) {
      if (previous?.riveFileData != current.riveFileData &&
          current.riveFileData != null &&
          current.riveFileData!.artboards.isNotEmpty) {
        // Reset explorer state and select first artboard
        ref.read(explorerStateProvider.notifier).reset();
        // Use mounted check to ensure context is still valid
        if (context.mounted) {
          Future.microtask(() {
            if (context.mounted) {
              ref.read(explorerStateProvider.notifier).selectArtboard(
                  current.riveFileData!.artboards.first, context);
            }
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.layers,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Rive Explorer'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => AppNavigation.goToUpload(context),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload New'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Row(
        children: [
          // Left sidebar - File info and content explorer
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // File info panel
                FileInfoPanel(),
                Divider(height: 1),
                // Selection control panel
                SelectionControlPanel(),
                Divider(height: 1),
                // Content explorer panel
                Expanded(
                  child: ContentExplorerPanel(),
                ),
              ],
            ),
          ),
          // Vertical divider
          VerticalDivider(width: 1),
          // Right panel - Rive preview
          Expanded(
            flex: 3,
            child: RivePreviewPanel(),
          ),
        ],
      ),
    );
  }
}
