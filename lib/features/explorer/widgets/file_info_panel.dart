import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../upload/providers/upload_provider.dart';
import '../../../core/theme/app_theme.dart';

class FileInfoPanel extends ConsumerWidget {
  const FileInfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final riveFileData = uploadState.riveFileData;

    if (riveFileData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'File Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'No file loaded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    // Calculate totals
    final totalAnimations = riveFileData.artboards
        .fold<int>(0, (sum, artboard) => sum + artboard.animations.length);
    final totalStateMachines = riveFileData.artboards
        .fold<int>(0, (sum, artboard) => sum + artboard.stateMachines.length);

    // Calculate file size (approximation)
    final fileSizeKB = (riveFileData.fileName.length * 1024) ~/ 1024;
    final fileSizeDisplay = fileSizeKB < 1024
        ? '${fileSizeKB}KB'
        : '${(fileSizeKB / 1024).toStringAsFixed(1)}MB';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insert_drive_file,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'File Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'File Name', riveFileData.fileName),
          _buildInfoRow(context, 'File Size', fileSizeDisplay),
          _buildInfoRow(
              context, 'Uploaded', _formatUploadTime(riveFileData.uploadedAt)),
          _buildInfoRow(
              context, 'Artboards', '${riveFileData.artboards.length}'),
          _buildInfoRow(context, 'Animations', '$totalAnimations'),
          _buildInfoRow(context, 'State Machines', '$totalStateMachines'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUploadTime(DateTime uploadedAt) {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
