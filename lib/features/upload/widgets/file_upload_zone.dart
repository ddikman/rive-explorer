import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/upload_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../models/rive_file_data.dart';

class FileUploadZone extends ConsumerStatefulWidget {
  const FileUploadZone({super.key});

  @override
  ConsumerState<FileUploadZone> createState() => _FileUploadZoneState();
}

class _FileUploadZoneState extends ConsumerState<FileUploadZone> {
  final bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);

    // Show upload progress or processing state
    if (uploadState.status == UploadStatus.uploading ||
        uploadState.status == UploadStatus.processing) {
      return _buildProgressView(context, uploadState);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _isDragOver
            ? AppColors.uploadZoneBackground.withValues(alpha: 0.8)
            : AppColors.uploadZoneBackground.withValues(alpha: 0.4),
        border: Border.all(
          color: _isDragOver
              ? AppColors.uploadZoneBorder
              : AppColors.uploadZoneBorder.withValues(alpha: 0.5),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Upload a Rive file',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Drag & drop a .riv file here, or click to select',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Supported format:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '.riv',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Browse Files'),
                ),
                if (uploadState.status == UploadStatus.error) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            uploadState.errorMessage ?? 'Upload failed',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.error,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressView(BuildContext context, UploadState uploadState) {
    final statusText = uploadState.status == UploadStatus.uploading
        ? 'Uploading...'
        : 'Processing Rive file...';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.uploadZoneBackground.withValues(alpha: 0.4),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.8),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              statusText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 200,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: uploadState.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(uploadState.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['riv'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          // Use file name as path for web compatibility
          await _handleFile(file.name, file.name, file.bytes!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFile(
      String fileName, String filePath, Uint8List fileBytes) async {
    try {
      final uploadNotifier = ref.read(uploadNotifierProvider.notifier);

      // Process the file using the upload provider
      await uploadNotifier.uploadFile(filePath, fileName, fileBytes);

      // Check if processing was successful
      final uploadState = ref.read(uploadNotifierProvider);
      if (uploadState.status == UploadStatus.success && mounted) {
        // Navigate to explorer page
        AppNavigation.goToExplorer(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
