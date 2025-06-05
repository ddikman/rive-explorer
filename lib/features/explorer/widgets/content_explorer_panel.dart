import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import '../../upload/providers/upload_provider.dart';
import '../providers/explorer_state_provider.dart';
import '../providers/console_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/rive_file_data.dart';

class ContentExplorerPanel extends ConsumerStatefulWidget {
  const ContentExplorerPanel({super.key});

  @override
  ConsumerState<ContentExplorerPanel> createState() =>
      _ContentExplorerPanelState();
}

class _ContentExplorerPanelState extends ConsumerState<ContentExplorerPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final riveFileData = uploadState.riveFileData;

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Artboards'),
              Tab(text: 'Animations'),
              Tab(text: 'State Machines'),
              Tab(text: 'Active Inputs'),
              Tab(text: 'Console'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ArtboardsTab(riveFileData: riveFileData),
              _AnimationsTab(riveFileData: riveFileData),
              _StateMachinesTab(riveFileData: riveFileData),
              const _ActiveInputsTab(),
              const _ConsoleTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArtboardsTab extends StatelessWidget {
  final RiveFileData? riveFileData;

  const _ArtboardsTab({this.riveFileData});

  @override
  Widget build(BuildContext context) {
    if (riveFileData == null || riveFileData!.artboards.isEmpty) {
      return const Center(
        child: Text(
          'No artboards found',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: riveFileData!.artboards.length,
      itemBuilder: (context, index) {
        final artboard = riveFileData!.artboards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: const Icon(Icons.dashboard, color: AppColors.primary),
            title: Text(artboard.name),
            subtitle: Text(
                'Animations: ${artboard.animations.length} • State Machines: ${artboard.stateMachines.length}'),
            children: [
              if (artboard.animations.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Animations',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                ...artboard.animations.map((animation) => ListTile(
                      leading: Icon(
                        animation.isLooping ? Icons.loop : Icons.play_arrow,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                      title: Text(animation.name),
                      subtitle: Text(
                        'Duration: ${animation.duration.toStringAsFixed(1)}s • ${animation.isLooping ? 'Loop' : 'OneShot'}',
                      ),
                      dense: true,
                    )),
              ],
              if (artboard.stateMachines.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'State Machines',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                ...artboard.stateMachines.map((stateMachine) => ListTile(
                      leading: const Icon(
                        Icons.account_tree,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                      title: Text(stateMachine.name),
                      subtitle: Text('Inputs: ${stateMachine.inputs.length}'),
                      dense: true,
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AnimationsTab extends ConsumerWidget {
  final RiveFileData? riveFileData;

  const _AnimationsTab({this.riveFileData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (riveFileData == null) {
      return const Center(
        child: Text(
          'No file loaded',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    final explorerState = ref.watch(explorerStateProvider);
    final allAnimations = riveFileData!.artboards
        .expand((artboard) =>
            artboard.animations.map((anim) => MapEntry(artboard.name, anim)))
        .toList();

    if (allAnimations.isEmpty) {
      return const Center(
        child: Text(
          'No animations found',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: allAnimations.length,
      itemBuilder: (context, index) {
        final entry = allAnimations[index];
        final artboardName = entry.key;
        final animation = entry.value;
        final isSelected =
            explorerState.selectedAnimation?.name == animation.name;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          child: ListTile(
            leading: Icon(
              animation.isLooping ? Icons.loop : Icons.play_arrow,
              color:
                  isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            title: Text(
              animation.name,
              style: TextStyle(
                color: isSelected ? AppColors.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Artboard: $artboardName'),
                Text(
                  'Duration: ${animation.duration.toStringAsFixed(1)}s • ${animation.isLooping ? 'Loop' : 'OneShot'}',
                ),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: Icon(
                isSelected ? Icons.pause_circle : Icons.play_circle,
                color: isSelected ? AppColors.primary : AppColors.secondary,
              ),
              onPressed: () {
                // First select the artboard if not already selected
                final artboard = riveFileData!.artboards
                    .firstWhere((ab) => ab.name == artboardName);

                if (explorerState.selectedArtboard?.name != artboardName) {
                  ref
                      .read(explorerStateProvider.notifier)
                      .selectArtboard(artboard, context);
                }

                // Then select the animation
                if (isSelected) {
                  // If already selected, deselect
                  ref
                      .read(explorerStateProvider.notifier)
                      .selectAnimation(null, context);
                } else {
                  // Select this animation
                  ref
                      .read(explorerStateProvider.notifier)
                      .selectAnimation(animation, context);
                }
              },
              tooltip: isSelected ? 'Stop Preview' : 'Preview Animation',
            ),
          ),
        );
      },
    );
  }
}

class _StateMachinesTab extends StatelessWidget {
  final RiveFileData? riveFileData;

  const _StateMachinesTab({this.riveFileData});

  @override
  Widget build(BuildContext context) {
    if (riveFileData == null) {
      return const Center(
        child: Text(
          'No file loaded',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    final allStateMachines = riveFileData!.artboards
        .expand((artboard) =>
            artboard.stateMachines.map((sm) => MapEntry(artboard.name, sm)))
        .toList();

    if (allStateMachines.isEmpty) {
      return const Center(
        child: Text(
          'No state machines found',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: allStateMachines.length,
      itemBuilder: (context, index) {
        final entry = allStateMachines[index];
        final artboardName = entry.key;
        final stateMachine = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: const Icon(Icons.account_tree, color: AppColors.primary),
            title: Text(stateMachine.name),
            subtitle: Text(
                'Artboard: $artboardName • Inputs: ${stateMachine.inputs.length}'),
            children: stateMachine.inputs
                .map((input) => ListTile(
                      leading: Icon(
                        _getInputIcon(input.type),
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                      title: Text(input.name),
                      subtitle: Text(
                        'Type: ${input.type.displayName}${input.defaultValue != null ? ' • Default: ${input.defaultValue}' : ''}',
                      ),
                      dense: true,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  IconData _getInputIcon(RiveInputType type) {
    switch (type) {
      case RiveInputType.trigger:
        return Icons.radio_button_unchecked;
      case RiveInputType.boolean:
        return Icons.toggle_off;
      case RiveInputType.number:
        return Icons.numbers;
    }
  }
}

class _ActiveInputsTab extends ConsumerStatefulWidget {
  const _ActiveInputsTab();

  @override
  ConsumerState<_ActiveInputsTab> createState() => _ActiveInputsTabState();
}

class _ActiveInputsTabState extends ConsumerState<_ActiveInputsTab> {
  StateMachineController? _controller;
  final Map<String, SMIInput> _inputs = {};
  String? _currentStateMachineName;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final explorerState = ref.watch(explorerStateProvider);
    final riveFileData = uploadState.riveFileData;

    if (explorerState.selectedArtboard == null ||
        explorerState.selectedStateMachine == null ||
        riveFileData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.input,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active State Machine',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an artboard and state machine to see inputs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Initialize controller if needed
    _initializeController(riveFileData, explorerState);

    if (_inputs.isEmpty) {
      return const Center(
        child: Text(
          'No inputs available in this state machine',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _inputs.length,
      itemBuilder: (context, index) {
        final entry = _inputs.entries.elementAt(index);
        final inputName = entry.key;
        final input = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(_getInputIcon(input), color: AppColors.primary),
            title: Text(inputName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${_getInputType(input)}'),
                if (input is SMIBool || input is SMINumber)
                  Text('Current: ${_getCurrentValue(input)}'),
              ],
            ),
            trailing: _buildInputControl(input),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _initializeController(
      RiveFileData riveFileData, ExplorerStateData explorerState) {
    final selectedArtboard = explorerState.selectedArtboard!;
    final selectedStateMachine = explorerState.selectedStateMachine!;

    // Only reinitialize if the selection has changed
    if (_controller == null ||
        _currentStateMachineName != selectedStateMachine.name) {
      _controller?.dispose();
      _inputs.clear();

      try {
        // Use the existing controller from explorer state if available
        if (explorerState.stateMachineController != null &&
            _currentStateMachineName == selectedStateMachine.name) {
          _controller = explorerState.stateMachineController;
          _currentStateMachineName = selectedStateMachine.name;

          // Populate inputs map
          for (final input in _controller!.inputs) {
            _inputs[input.name] = input;
          }
          return;
        }

        // Create a separate artboard instance for input management
        // This ensures we don't conflict with the preview panel
        final artboard =
            riveFileData.riveFile.artboardByName(selectedArtboard.name);
        if (artboard != null) {
          _controller = StateMachineController.fromArtboard(
              artboard, selectedStateMachine.name);
          if (_controller != null) {
            // Store the current state machine name
            _currentStateMachineName = selectedStateMachine.name;

            // Populate inputs map
            for (final input in _controller!.inputs) {
              _inputs[input.name] = input;
            }

            // Update the explorer state with the new controller only if none exists
            if (explorerState.stateMachineController == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(explorerStateProvider.notifier)
                    .updateStateMachineController(_controller);
              });
            }
          }
        }
      } catch (e) {
        print('Error initializing state machine controller: $e');
      }
    }
  }

  IconData _getInputIcon(SMIInput input) {
    if (input is SMITrigger) return Icons.radio_button_unchecked;
    if (input is SMIBool) return Icons.toggle_off;
    if (input is SMINumber) return Icons.numbers;
    return Icons.input;
  }

  String _getInputType(SMIInput input) {
    if (input is SMITrigger) return 'Trigger';
    if (input is SMIBool) return 'Boolean';
    if (input is SMINumber) return 'Number';
    return 'Unknown';
  }

  String _getCurrentValue(SMIInput input) {
    if (input is SMIBool) return input.value.toString();
    if (input is SMINumber) return input.value.toStringAsFixed(2);
    return '';
  }

  Widget? _buildInputControl(SMIInput input) {
    if (input is SMITrigger) {
      return IconButton(
        icon: const Icon(Icons.play_circle),
        onPressed: () {
          input.fire();
        },
      );
    } else if (input is SMIBool) {
      return Switch(
        value: input.value,
        onChanged: (value) {
          setState(() {
            input.value = value;
          });
        },
      );
    } else if (input is SMINumber) {
      return SizedBox(
        width: 80,
        child: TextFormField(
          initialValue: input.value.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(8),
          ),
          onFieldSubmitted: (value) {
            final numValue = double.tryParse(value) ?? input.value;
            setState(() {
              input.value = numValue;
            });
          },
        ),
      );
    }
    return null;
  }
}

class _ConsoleTab extends ConsumerStatefulWidget {
  const _ConsoleTab();

  @override
  ConsumerState<_ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends ConsumerState<_ConsoleTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final consoleState = ref.watch(consoleProvider);

    // Auto-scroll to bottom when new messages arrive
    ref.listen(consoleProvider, (previous, current) {
      if (consoleState.autoScroll &&
          current.messages.length > (previous?.messages.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Column(
      children: [
        // Console header with controls
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.terminal,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Console',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                ' (${consoleState.messages.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  consoleState.autoScroll
                      ? Icons.vertical_align_bottom
                      : Icons.stop,
                  size: 16,
                ),
                onPressed: () =>
                    ref.read(consoleProvider.notifier).toggleAutoScroll(),
                tooltip: consoleState.autoScroll
                    ? 'Disable Auto-scroll'
                    : 'Enable Auto-scroll',
                style: IconButton.styleFrom(
                  minimumSize: const Size(24, 24),
                  padding: const EdgeInsets.all(4),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () => ref.read(consoleProvider.notifier).clear(),
                tooltip: 'Clear Console',
                style: IconButton.styleFrom(
                  minimumSize: const Size(24, 24),
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
        ),
        // Console messages
        Expanded(
          child: consoleState.messages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.terminal,
                        size: 48,
                        color: AppColors.onSurfaceVariant,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Console is empty',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rive operations and errors will appear here',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: consoleState.messages.length,
                  itemBuilder: (context, index) {
                    final message = consoleState.messages[index];
                    return _buildMessageTile(context, message);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessageTile(BuildContext context, ConsoleMessage message) {
    final timestamp = _formatTimestamp(message.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: message.type == ConsoleMessageType.error
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: message.type == ConsoleMessageType.error
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message header
          Row(
            children: [
              Icon(
                message.icon,
                size: 14,
                color: message.color,
              ),
              const SizedBox(width: 6),
              Text(
                message.prefix,
                style: TextStyle(
                  color: message.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              if (message.source != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    message.source!,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                timestamp,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Message content
          Text(
            message.message,
            style: TextStyle(
              color: message.type == ConsoleMessageType.error
                  ? AppColors.error
                  : AppColors.onSurface,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
