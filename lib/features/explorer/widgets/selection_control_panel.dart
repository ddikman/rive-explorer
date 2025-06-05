import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../upload/providers/upload_provider.dart';
import '../providers/explorer_state_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/rive_file_data.dart';

class SelectionControlPanel extends ConsumerWidget {
  const SelectionControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final explorerState = ref.watch(explorerStateProvider);
    final riveFileData = uploadState.riveFileData;

    if (riveFileData == null || riveFileData.artboards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Selection',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Artboard Selection
          _buildSelectionRow(
            context,
            'Artboard',
            DropdownButton<RiveArtboardData?>(
              value: explorerState.selectedArtboard,
              hint: const Text('Select Artboard'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<RiveArtboardData?>(
                  value: null,
                  child: Text('None'),
                ),
                ...riveFileData.artboards.map(
                  (artboard) => DropdownMenuItem<RiveArtboardData?>(
                    value: artboard,
                    child: Text(artboard.name),
                  ),
                ),
              ],
              onChanged: (artboard) {
                ref
                    .read(explorerStateProvider.notifier)
                    .selectArtboard(artboard, context);
              },
            ),
          ),

          const SizedBox(height: 12),

          // State Machine Selection
          _buildSelectionRow(
            context,
            'State Machine',
            explorerState.selectedArtboard != null &&
                    explorerState.selectedArtboard!.stateMachines.isNotEmpty
                ? DropdownButton<RiveStateMachineData?>(
                    value: _findMatchingStateMachine(
                      explorerState.selectedStateMachine,
                      explorerState.selectedArtboard!.stateMachines,
                    ),
                    hint: const Text('Select State Machine'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<RiveStateMachineData?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...explorerState.selectedArtboard!.stateMachines.map(
                        (sm) => DropdownMenuItem<RiveStateMachineData?>(
                          value: sm,
                          child: Text(sm.name),
                        ),
                      ),
                    ],
                    onChanged: (stateMachine) {
                      ref
                          .read(explorerStateProvider.notifier)
                          .selectStateMachine(stateMachine, context);
                    },
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      explorerState.selectedArtboard == null
                          ? 'Select an artboard first'
                          : 'No state machines available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          // Animation Selection
          _buildSelectionRow(
            context,
            'Animation',
            explorerState.selectedArtboard != null &&
                    explorerState.selectedArtboard!.animations.isNotEmpty
                ? DropdownButton<RiveAnimationData?>(
                    value: _findMatchingAnimation(
                      explorerState.selectedAnimation,
                      explorerState.selectedArtboard!.animations,
                    ),
                    hint: const Text('Select Animation'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<RiveAnimationData?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...explorerState.selectedArtboard!.animations.map(
                        (anim) => DropdownMenuItem<RiveAnimationData?>(
                          value: anim,
                          child: Text(
                              '${anim.name} (${anim.duration.toStringAsFixed(1)}s)'),
                        ),
                      ),
                    ],
                    onChanged: (animation) {
                      ref
                          .read(explorerStateProvider.notifier)
                          .selectAnimation(animation, context);
                    },
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      explorerState.selectedArtboard == null
                          ? 'Select an artboard first'
                          : 'No animations available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ),
          ),

          // Selection Summary
          if (explorerState.selectedArtboard != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Configuration',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Artboard: ${explorerState.selectedArtboard!.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (explorerState.selectedStateMachine != null) ...[
                    Text(
                      'State Machine: ${explorerState.selectedStateMachine!.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Inputs: ${explorerState.selectedStateMachine!.inputs.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ] else if (explorerState.selectedAnimation != null) ...[
                    Text(
                      'Animation: ${explorerState.selectedAnimation!.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Duration: ${explorerState.selectedAnimation!.duration.toStringAsFixed(1)}s',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Type: ${explorerState.selectedAnimation!.isLooping ? 'Loop' : 'OneShot'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ] else ...[
                    Text(
                      'Mode: Auto (first available)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionRow(
      BuildContext context, String label, Widget control) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: control),
      ],
    );
  }

  /// Helper method to find matching state machine by name to avoid reference equality issues
  RiveStateMachineData? _findMatchingStateMachine(
    RiveStateMachineData? selectedStateMachine,
    List<RiveStateMachineData> availableStateMachines,
  ) {
    if (selectedStateMachine == null) return null;

    try {
      return availableStateMachines
          .where((sm) => sm.name == selectedStateMachine.name)
          .first;
    } catch (e) {
      // If no matching state machine found, return null to avoid dropdown assertion error
      return null;
    }
  }

  /// Helper method to find matching animation by name to avoid reference equality issues
  RiveAnimationData? _findMatchingAnimation(
    RiveAnimationData? selectedAnimation,
    List<RiveAnimationData> availableAnimations,
  ) {
    if (selectedAnimation == null) return null;

    try {
      return availableAnimations
          .where((anim) => anim.name == selectedAnimation.name)
          .first;
    } catch (e) {
      // If no matching animation found, return null to avoid dropdown assertion error
      return null;
    }
  }
}
