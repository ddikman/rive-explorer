import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/rive_file_data.dart';
import '../../upload/providers/upload_provider.dart';
import '../providers/console_provider.dart';
import '../providers/explorer_state_provider.dart';

class RivePreviewPanel extends ConsumerStatefulWidget {
  const RivePreviewPanel({super.key});

  @override
  ConsumerState<RivePreviewPanel> createState() => _RivePreviewPanelState();
}

class _RivePreviewPanelState extends ConsumerState<RivePreviewPanel> {
  RiveAnimationController? _controller;
  StateMachineController? _stateMachineController;
  bool _isPlaying = false;
  BoxFit _fit = BoxFit.contain;
  Alignment _alignment = Alignment.center;
  String? _currentArtboardName;
  String? _currentStateMachineName;
  String? _currentAnimationName;

  @override
  void initState() {
    super.initState();
    print('🎬 RivePreviewPanel: initState called');
  }

  @override
  void dispose() {
    print('🎬 RivePreviewPanel: dispose called');
    _cleanupControllers();
    super.dispose();
  }

  void _cleanupControllers() {
    print('🎬 RivePreviewPanel: Cleaning up controllers');
    _controller?.dispose();
    _stateMachineController?.dispose();
    _controller = null;
    _stateMachineController = null;
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final explorerState = ref.watch(explorerStateProvider);
    final riveFileData = uploadState.riveFileData;

    // Listen for selection changes and cleanup controllers
    ref.listen(explorerStateProvider, (previous, current) {
      if (previous?.selectedArtboard != current.selectedArtboard ||
          previous?.selectedStateMachine != current.selectedStateMachine ||
          previous?.selectedAnimation != current.selectedAnimation) {
        print('🎬 RivePreviewPanel: Selection changed, cleaning up');
        _cleanupControllers();
        _currentArtboardName = null;
        _currentStateMachineName = null;
        _currentAnimationName = null;
        setState(() {
          _isPlaying = false;
        });
      }
    });

    return Column(
      children: [
        // Preview controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.preview,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Animation Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  if (explorerState.selectedArtboard != null) ...[
                    Chip(
                      label: Text(explorerState.selectedArtboard!.name),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (explorerState.selectedStateMachine != null) ...[
                    Chip(
                      label: Text(explorerState.selectedStateMachine!.name),
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (explorerState.selectedAnimation != null) ...[
                    Chip(
                      label: Text(explorerState.selectedAnimation!.name),
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Timeline Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: riveFileData != null ? _stopAnimation : null,
                    tooltip: 'Stop',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: riveFileData != null ? _togglePlayback : null,
                    tooltip: _isPlaying ? 'Pause' : 'Play',
                    style: IconButton.styleFrom(
                      backgroundColor: _isPlaying ? AppColors.success : Colors.transparent,
                      foregroundColor: _isPlaying ? Colors.white : Colors.white,
                      side: _isPlaying ? null : const BorderSide(color: Colors.white, width: 2),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.restart_alt),
                    onPressed: riveFileData != null ? _restartAnimation : null,
                    tooltip: 'Restart',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: riveFileData != null ? _showFullscreen : null,
                    tooltip: 'Fullscreen',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Preview area
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: riveFileData != null ? _buildRivePreview(riveFileData, explorerState) : _buildEmptyPreview(),
            ),
          ),
        ),
        // Settings panel
        Container(
          height: 180, // Fixed height to ensure consistent visibility
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.settings,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Display Settings',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    // Status indicator moved to header for better visibility
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isPlaying
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _isPlaying ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                        ),
                      ),
                      child: Text(
                        _isPlaying ? 'Playing' : 'Paused',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _isPlaying ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingRow(
                  context,
                  'Fit Mode',
                  DropdownButton<BoxFit>(
                    value: _fit,
                    isDense: true,
                    items: const [
                      DropdownMenuItem(value: BoxFit.contain, child: Text('Contain')),
                      DropdownMenuItem(value: BoxFit.cover, child: Text('Cover')),
                      DropdownMenuItem(value: BoxFit.fill, child: Text('Fill')),
                      DropdownMenuItem(value: BoxFit.fitWidth, child: Text('Fit Width')),
                      DropdownMenuItem(value: BoxFit.fitHeight, child: Text('Fit Height')),
                      DropdownMenuItem(value: BoxFit.scaleDown, child: Text('Scale Down')),
                      DropdownMenuItem(value: BoxFit.none, child: Text('None')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fit = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  context,
                  'Alignment',
                  _buildAlignmentGrid(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRivePreview(RiveFileData riveFileData, ExplorerStateData explorerState) {
    try {
      // Log the preview operation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(consoleProvider.notifier).logRiveOperation(
              'Building preview for ${riveFileData.fileName}',
            );
      });

      // Use a key to force recreation when selection changes
      final key = ValueKey(
          '${explorerState.selectedArtboard?.name ?? 'default'}_${explorerState.selectedStateMachine?.name ?? 'none'}_${explorerState.selectedAnimation?.name ?? 'none'}');

      // Wrap RiveAnimation with error handling
      return _RiveAnimationErrorBoundary(
        key: key,
        onError: (error, stackTrace) {
          final errorString = error.toString();

          // Check for vector feathering issue
          if (errorString.contains('RangeError') &&
              (errorString.contains('index should be less than 2: 2') ||
                  (errorString.contains('Index out of range') && errorString.contains('2')))) {
            ref.read(consoleProvider.notifier).logRiveOperation(
                  'Vector Feathering Error Detected',
                  details:
                      'This Rive file uses unsupported Feather features. See: https://github.com/rive-app/rive-flutter/issues/461',
                  isError: true,
                );

            ref.read(consoleProvider.notifier).addWarning(
                  'Solution: Open file in Rive Editor and remove Feather effects or check Fill rules are not set to "Clockwise"',
                  source: 'Diagnostic',
                );

            ref.read(consoleProvider.notifier).addInfo(
                  'Feather features are not yet supported in Flutter. Check: https://rive.app/docs/feature-support#feathers',
                  source: 'Diagnostic',
                );
          } else {
            ref.read(consoleProvider.notifier).logRiveOperation(
                  'Rive rendering error',
                  details: error.toString(),
                  isError: true,
                );
          }
        },
        child: RiveAnimation.direct(
          riveFileData.riveFile,
          key: key,
          fit: _fit,
          alignment: _alignment,
          artboard: explorerState.selectedArtboard?.name,
          onInit: (artboard) {
            print('🎬 RivePreviewPanel: onInit called');

            // Log artboard initialization
            ref.read(consoleProvider.notifier).logRiveOperation(
                  'Initializing artboard: ${artboard.name}',
                );

            // Clean up old controllers first
            _cleanupControllers();

            try {
              // Priority 1: Use selected state machine
              if (explorerState.selectedStateMachine != null) {
                print('🎬 Creating state machine controller: ${explorerState.selectedStateMachine!.name}');

                ref.read(consoleProvider.notifier).logControllerOperation(
                      'Creating controller',
                      'StateMachine',
                      details: explorerState.selectedStateMachine!.name,
                    );

                final controller =
                    StateMachineController.fromArtboard(artboard, explorerState.selectedStateMachine!.name);

                if (controller != null) {
                  _stateMachineController = controller;
                  artboard.addController(_stateMachineController!);
                  _currentStateMachineName = explorerState.selectedStateMachine!.name;
                  _currentArtboardName = explorerState.selectedArtboard?.name;

                  ref.read(consoleProvider.notifier).logControllerOperation(
                        'Successfully created and attached controller',
                        'StateMachine',
                        details: '${controller.inputs.length} inputs available',
                      );

                  // Update the explorer state with this controller
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(explorerStateProvider.notifier).updateStateMachineController(_stateMachineController);
                  });

                  setState(() {
                    _isPlaying = true; // State machines typically auto-play
                  });
                  return;
                } else {
                  ref.read(consoleProvider.notifier).logControllerOperation(
                        'Failed to create controller',
                        'StateMachine',
                        details: explorerState.selectedStateMachine!.name,
                        isError: true,
                      );
                }
              }

              // Priority 2: Use selected animation
              if (explorerState.selectedAnimation != null) {
                print('🎬 Creating animation controller: ${explorerState.selectedAnimation!.name}');

                ref.read(consoleProvider.notifier).logControllerOperation(
                      'Creating controller',
                      'Animation',
                      details: explorerState.selectedAnimation!.name,
                    );

                _controller = SimpleAnimation(
                  explorerState.selectedAnimation!.name,
                  autoplay: false, // We'll control play/pause manually
                );
                artboard.addController(_controller!);
                _currentAnimationName = explorerState.selectedAnimation!.name;
                _currentArtboardName = explorerState.selectedArtboard?.name;

                ref.read(consoleProvider.notifier).logControllerOperation(
                      'Successfully created animation controller',
                      'Animation',
                      details: '${explorerState.selectedAnimation!.duration.toStringAsFixed(1)}s duration',
                    );

                // Update the explorer state with this controller
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(explorerStateProvider.notifier).updateAnimationController(_controller);
                });

                setState(() {
                  _isPlaying = false; // Start paused for manual control
                });
                return;
              }

              // Priority 3: Fall back to first animation in selected artboard
              if (explorerState.selectedArtboard != null && explorerState.selectedArtboard!.animations.isNotEmpty) {
                final anim = explorerState.selectedArtboard!.animations.first;
                print('🎬 Fallback to first animation: ${anim.name}');

                ref.read(consoleProvider.notifier).logControllerOperation(
                      'Using fallback animation',
                      'Animation',
                      details: anim.name,
                    );

                _controller = SimpleAnimation(anim.name, autoplay: false);
                artboard.addController(_controller!);
                _currentAnimationName = anim.name;
                _currentArtboardName = explorerState.selectedArtboard!.name;

                setState(() {
                  _isPlaying = false;
                });
                return;
              }

              // Priority 4: Ultimate fallback - first artboard's first animation
              if (riveFileData.artboards.isNotEmpty) {
                final firstArtboard = riveFileData.artboards.first;
                if (firstArtboard.animations.isNotEmpty) {
                  final anim = firstArtboard.animations.first;
                  print('🎬 Ultimate fallback: ${anim.name}');

                  ref.read(consoleProvider.notifier).logControllerOperation(
                        'Using ultimate fallback animation',
                        'Animation',
                        details: '${anim.name} from ${firstArtboard.name}',
                      );

                  _controller = SimpleAnimation(anim.name, autoplay: false);
                  artboard.addController(_controller!);
                  _currentAnimationName = anim.name;
                  _currentArtboardName = firstArtboard.name;

                  setState(() {
                    _isPlaying = false;
                  });
                } else {
                  ref.read(consoleProvider.notifier).logRiveOperation(
                        'No animations found in artboard',
                        details: firstArtboard.name,
                        isError: true,
                      );
                }
              }
            } catch (e) {
              print('🎬 RivePreviewPanel: Error initializing controller: $e');
              ref.read(consoleProvider.notifier).logRiveOperation(
                    'Error initializing Rive controller',
                    details: e.toString(),
                    isError: true,
                  );
            }
          },
        ),
      );
    } catch (e) {
      print('🎬 RivePreviewPanel: Exception in _buildRivePreview: $e');
      ref.read(consoleProvider.notifier).logRiveOperation(
            'Exception in Rive preview',
            details: e.toString(),
            isError: true,
          );
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading Rive file',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEmptyPreview() {
    final uploadState = ref.watch(uploadNotifierProvider);

    // Show upload progress if uploading
    if (uploadState.status == UploadStatus.uploading || uploadState.status == UploadStatus.processing) {
      return _buildUploadProgress(uploadState);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.uploadZoneBackground.withValues(alpha: 0.4),
        border: Border.all(
          color: AppColors.uploadZoneBorder.withValues(alpha: 0.5),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Upload a Rive File',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '.riv',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Browse Files'),
                ),
                if (uploadState.status == UploadStatus.error) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            uploadState.errorMessage ?? 'Upload failed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                            textAlign: TextAlign.center,
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

  Widget _buildUploadProgress(UploadState uploadState) {
    final statusText = uploadState.status == UploadStatus.uploading ? 'Uploading...' : 'Processing Rive file...';

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

  Future<void> _handleFile(String fileName, String filePath, Uint8List fileBytes) async {
    try {
      final uploadNotifier = ref.read(uploadNotifierProvider.notifier);

      // Process the file using the upload provider
      await uploadNotifier.uploadFile(filePath, fileName, fileBytes);

      // The file will automatically be available in the preview once upload completes
      // The explorer page already listens for upload changes and will auto-select the first artboard
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

  Widget _buildAlignmentGrid() {
    const alignments = [
      Alignment.topLeft,
      Alignment.topCenter,
      Alignment.topRight,
      Alignment.centerLeft,
      Alignment.center,
      Alignment.centerRight,
      Alignment.bottomLeft,
      Alignment.bottomCenter,
      Alignment.bottomRight,
    ];

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: alignments.map((alignment) {
        final isSelected = _alignment == alignment;
        return GestureDetector(
          onTap: () {
            setState(() {
              _alignment = alignment;
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingRow(BuildContext context, String label, Widget control) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        control,
      ],
    );
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    ref.read(consoleProvider.notifier).logControllerOperation(
          _isPlaying ? 'Started playback' : 'Paused playback',
          _stateMachineController != null ? 'StateMachine' : 'Animation',
        );

    if (_controller != null && _controller is SimpleAnimation) {
      final simpleAnim = _controller as SimpleAnimation;
      simpleAnim.isActive = _isPlaying;
    } else if (_stateMachineController != null) {
      _stateMachineController!.isActive = _isPlaying;
    }
  }

  void _stopAnimation() {
    setState(() {
      _isPlaying = false;
    });

    ref.read(consoleProvider.notifier).logControllerOperation(
          'Stopped animation',
          _stateMachineController != null ? 'StateMachine' : 'Animation',
        );

    if (_controller != null && _controller is SimpleAnimation) {
      final simpleAnim = _controller as SimpleAnimation;
      simpleAnim.isActive = false;
      simpleAnim.reset();
    } else if (_stateMachineController != null) {
      _stateMachineController!.isActive = false;
      // For state machines, we don't reset as it might have complex state
    }
  }

  void _restartAnimation() {
    ref.read(consoleProvider.notifier).logControllerOperation(
          'Restarting animation/state machine',
          _stateMachineController != null ? 'StateMachine' : 'Animation',
        );

    final uploadState = ref.read(uploadNotifierProvider);
    final explorerState = ref.read(explorerStateProvider);
    final riveFileData = uploadState.riveFileData;

    if (riveFileData == null) return;

    try {
      // Clean up current controllers
      _cleanupControllers();

      // Get the current artboard
      final artboardName = explorerState.selectedArtboard?.name ??
          (riveFileData.artboards.isNotEmpty ? riveFileData.artboards.first.name : null);

      if (artboardName == null) return;

      final artboard = riveFileData.riveFile.artboardByName(artboardName);
      if (artboard == null) return;

      // Recreate and restart the appropriate controller
      if (explorerState.selectedStateMachine != null) {
        // Restart state machine
        final controller = StateMachineController.fromArtboard(artboard, explorerState.selectedStateMachine!.name);

        if (controller != null) {
          _stateMachineController = controller;
          artboard.addController(_stateMachineController!);
          _currentStateMachineName = explorerState.selectedStateMachine!.name;
          _currentArtboardName = artboardName;

          // Reset all inputs to their default values
          for (final input in controller.inputs) {
            if (input is SMIBool && explorerState.selectedStateMachine!.inputs.any((i) => i.name == input.name)) {
              final inputData = explorerState.selectedStateMachine!.inputs.firstWhere((i) => i.name == input.name);
              if (inputData.defaultValue is bool) {
                input.value = inputData.defaultValue as bool;
              }
            } else if (input is SMINumber &&
                explorerState.selectedStateMachine!.inputs.any((i) => i.name == input.name)) {
              final inputData = explorerState.selectedStateMachine!.inputs.firstWhere((i) => i.name == input.name);
              if (inputData.defaultValue is num) {
                input.value = (inputData.defaultValue as num).toDouble();
              }
            }
          }

          _stateMachineController!.isActive = true;

          ref.read(consoleProvider.notifier).logControllerOperation(
                'State machine restarted successfully',
                'StateMachine',
                details: '${controller.inputs.length} inputs reset to defaults',
              );

          setState(() {
            _isPlaying = true;
          });
        }
      } else if (explorerState.selectedAnimation != null) {
        // Restart animation
        _controller = SimpleAnimation(
          explorerState.selectedAnimation!.name,
          autoplay: true, // Start playing immediately
        );
        artboard.addController(_controller!);
        _currentAnimationName = explorerState.selectedAnimation!.name;
        _currentArtboardName = artboardName;

        ref.read(consoleProvider.notifier).logControllerOperation(
              'Animation restarted successfully',
              'Animation',
              details: explorerState.selectedAnimation!.name,
            );

        setState(() {
          _isPlaying = true;
        });
      } else {
        // Fallback: restart first available animation
        if (explorerState.selectedArtboard != null && explorerState.selectedArtboard!.animations.isNotEmpty) {
          final anim = explorerState.selectedArtboard!.animations.first;
          _controller = SimpleAnimation(anim.name, autoplay: true);
          artboard.addController(_controller!);
          _currentAnimationName = anim.name;
          _currentArtboardName = artboardName;

          ref.read(consoleProvider.notifier).logControllerOperation(
                'Fallback animation restarted',
                'Animation',
                details: anim.name,
              );

          setState(() {
            _isPlaying = true;
          });
        }
      }

      // Update the explorer state with the new controllers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_stateMachineController != null) {
          ref.read(explorerStateProvider.notifier).updateStateMachineController(_stateMachineController);
        } else if (_controller != null) {
          ref.read(explorerStateProvider.notifier).updateAnimationController(_controller);
        }
      });
    } catch (e) {
      ref.read(consoleProvider.notifier).logControllerOperation(
            'Failed to restart',
            _stateMachineController != null ? 'StateMachine' : 'Animation',
            details: e.toString(),
            isError: true,
          );
    }
  }

  void _showFullscreen() {
    final uploadState = ref.read(uploadNotifierProvider);
    final explorerState = ref.read(explorerStateProvider);
    final riveFileData = uploadState.riveFileData;

    if (riveFileData == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenRiveViewer(
          riveFileData: riveFileData,
          explorerState: explorerState,
          fit: _fit,
          alignment: _alignment,
        ),
      ),
    );
  }
}

class _RiveAnimationErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(Object error, StackTrace stackTrace)? onError;

  const _RiveAnimationErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<_RiveAnimationErrorBoundary> createState() => _RiveAnimationErrorBoundaryState();
}

class _RiveAnimationErrorBoundaryState extends State<_RiveAnimationErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();

    // Store the original error handler
    final originalOnError = FlutterError.onError;

    // Override Flutter's error handler to catch rendering errors
    FlutterError.onError = (FlutterErrorDetails details) {
      // Check if this error is related to RiveAnimation and happened in our context
      final errorString = details.toString();
      if (mounted &&
          (errorString.contains('RiveAnimation') ||
              errorString.contains('RangeError') ||
              errorString.contains('IndexError') ||
              errorString.contains('rive_common') ||
              (errorString.contains('paint') && errorString.contains('index')))) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _error = details.exception;
              _stackTrace = details.stack;
              _errorDetails = details;
              _hasError = true;
            });
            widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
          }
        });
      }

      // Call the original error handler
      originalOnError?.call(details);
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      return _buildErrorWidget();
    }

    try {
      return widget.child;
    } catch (error, stackTrace) {
      // Catch any synchronous errors
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
        _hasError = true;
      });
      widget.onError?.call(error, stackTrace);
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    final isFeatheringError = _isVectorFeatheringError();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFeatheringError ? Icons.warning : Icons.error_outline,
              size: 48,
              color: isFeatheringError ? AppColors.warning : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              isFeatheringError ? 'Unsupported Feature' : 'Rive Rendering Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isFeatheringError ? AppColors.warning : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isFeatheringError ? AppColors.warning : AppColors.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isFeatheringError ? AppColors.warning : AppColors.error).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getErrorMessage(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isFeatheringError ? AppColors.warning : AppColors.error,
                      fontFamily: 'monospace',
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            if (isFeatheringError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.info),
                        const SizedBox(width: 6),
                        Text(
                          'Solution:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Open the Rive file in Rive Editor\n• Check all shapes for Feather effects\n• Verify no Fill rule is set to "Clockwise"\n• Remove or disable Feather features',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _stackTrace = null;
                      _hasError = false;
                      _errorDetails = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Show error details in a dialog
                    _showErrorDialog(context);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                ),
                if (isFeatheringError) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showFeatheringHelpDialog(context);
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Help'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage() {
    final errorString = _error?.toString() ?? 'Unknown rendering error';

    // Check for specific vector feathering issue
    if (errorString.contains('RangeError') &&
        (errorString.contains('index should be less than 2: 2') ||
            errorString.contains('Index out of range') && errorString.contains('2'))) {
      return 'Vector Feathering Issue - This Rive file uses Feather features that are not supported in Flutter.';
    }

    // Provide more user-friendly error messages for common issues
    if (errorString.contains('RangeError') || errorString.contains('IndexError')) {
      return 'Index out of range - The Rive file contains references to non-existent elements.';
    } else if (errorString.contains('StateError')) {
      return 'Animation state error - The state machine may be corrupted.';
    } else if (errorString.contains('Null check operator')) {
      return 'Missing data - Required components are missing from the Rive file.';
    } else if (errorString.contains('LateInitializationError')) {
      return 'Initialization error - Rive components not properly set up.';
    } else {
      // Return a truncated version of the error
      return errorString.length > 150 ? '${errorString.substring(0, 150)}...' : errorString;
    }
  }

  bool _isVectorFeatheringError() {
    final errorString = _error?.toString() ?? '';
    return errorString.contains('RangeError') &&
        (errorString.contains('index should be less than 2: 2') ||
            (errorString.contains('Index out of range') && errorString.contains('2')));
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SelectableText(
                _error?.toString() ?? 'Unknown error',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              if (_stackTrace != null) ...[
                const SizedBox(height: 12),
                const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                SelectableText(
                  _stackTrace!.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Copy all error details to clipboard
              final errorText = '''
Error: ${_error?.toString() ?? 'Unknown error'}

Stack Trace:
${_stackTrace?.toString() ?? 'No stack trace available'}
''';
              try {
                await Clipboard.setData(ClipboardData(text: errorText));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error details copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to copy error details'),
                      backgroundColor: AppColors.error,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeatheringHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feathering Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To resolve Feathering issues, follow these steps:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Open the Rive file in Rive Editor',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.4,
                    ),
              ),
              Text(
                '2. Check all shapes for Feather effects',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.4,
                    ),
              ),
              Text(
                '3. Verify no Fill rule is set to "Clockwise"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.4,
                    ),
              ),
              Text(
                '4. Remove or disable Feather features',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FullscreenRiveViewer extends StatelessWidget {
  final RiveFileData riveFileData;
  final ExplorerStateData explorerState;
  final BoxFit fit;
  final Alignment alignment;

  const _FullscreenRiveViewer({
    required this.riveFileData,
    required this.explorerState,
    required this.fit,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          riveFileData.fileName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: RiveAnimation.direct(
          riveFileData.riveFile,
          fit: fit,
          alignment: alignment,
          artboard: explorerState.selectedArtboard?.name,
        ),
      ),
    );
  }
}
