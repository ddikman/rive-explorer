import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import '../../../models/rive_file_data.dart';

class ExplorerStateData {
  final RiveArtboardData? selectedArtboard;
  final RiveStateMachineData? selectedStateMachine;
  final RiveAnimationData? selectedAnimation;
  final StateMachineController? stateMachineController;
  final RiveAnimationController? animationController;
  final bool isLoading;

  const ExplorerStateData({
    this.selectedArtboard,
    this.selectedStateMachine,
    this.selectedAnimation,
    this.stateMachineController,
    this.animationController,
    this.isLoading = false,
  });

  ExplorerStateData copyWith({
    RiveArtboardData? selectedArtboard,
    RiveStateMachineData? selectedStateMachine,
    RiveAnimationData? selectedAnimation,
    StateMachineController? stateMachineController,
    RiveAnimationController? animationController,
    bool? isLoading,
  }) {
    return ExplorerStateData(
      selectedArtboard: selectedArtboard ?? this.selectedArtboard,
      selectedStateMachine: selectedStateMachine ?? this.selectedStateMachine,
      selectedAnimation: selectedAnimation ?? this.selectedAnimation,
      stateMachineController:
          stateMachineController ?? this.stateMachineController,
      animationController: animationController ?? this.animationController,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ExplorerStateNotifier extends StateNotifier<ExplorerStateData> {
  ExplorerStateNotifier() : super(const ExplorerStateData());

  void selectArtboard(RiveArtboardData? artboard, [BuildContext? context]) {
    // Clean up existing controllers
    _cleanupControllers();

    state = state.copyWith(
      selectedArtboard: artboard,
      selectedStateMachine: null, // Reset state machine when artboard changes
      selectedAnimation: null, // Reset animation when artboard changes
      stateMachineController: null,
      animationController: null,
      isLoading: artboard != null,
    );

    if (artboard != null && context != null) {
      _showSnackBar(
          context, '${artboard.name} artboard loaded', Icons.dashboard);
    }

    // Clear loading state after a brief delay
    if (artboard != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && state.selectedArtboard == artboard) {
          state = state.copyWith(isLoading: false);
        }
      });
    }
  }

  void selectStateMachine(RiveStateMachineData? stateMachine,
      [BuildContext? context]) {
    // Clean up existing state machine controller
    state.stateMachineController?.dispose();

    state = state.copyWith(
      selectedStateMachine: stateMachine,
      selectedAnimation: null, // Reset animation when state machine changes
      stateMachineController: null,
      isLoading: stateMachine != null,
    );

    if (stateMachine != null && context != null) {
      _showSnackBar(
          context, '${stateMachine.name} selected', Icons.account_tree);
    }

    // Clear loading state after a brief delay
    if (stateMachine != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && state.selectedStateMachine == stateMachine) {
          state = state.copyWith(isLoading: false);
        }
      });
    }
  }

  void selectAnimation(RiveAnimationData? animation, [BuildContext? context]) {
    // Clean up existing animation controller
    state.animationController?.dispose();

    state = state.copyWith(
      selectedAnimation: animation,
      selectedStateMachine: null, // Reset state machine when animation changes
      stateMachineController: null,
      animationController: null,
      isLoading: animation != null,
    );

    if (animation != null && context != null) {
      _showSnackBar(
          context, '${animation.name} timeline selected', Icons.play_arrow);
    }

    // Clear loading state after a brief delay
    if (animation != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && state.selectedAnimation == animation) {
          state = state.copyWith(isLoading: false);
        }
      });
    }
  }

  void updateStateMachineController(StateMachineController? controller) {
    // Dispose old controller if different
    if (state.stateMachineController != controller) {
      state.stateMachineController?.dispose();
    }
    state = state.copyWith(stateMachineController: controller);
  }

  void updateAnimationController(RiveAnimationController? controller) {
    // Dispose old controller if different
    if (state.animationController != controller) {
      state.animationController?.dispose();
    }
    state = state.copyWith(animationController: controller);
  }

  void _cleanupControllers() {
    state.stateMachineController?.dispose();
    state.animationController?.dispose();
  }

  void _showSnackBar(BuildContext context, String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void reset() {
    _cleanupControllers();
    state = const ExplorerStateData();
  }

  @override
  void dispose() {
    _cleanupControllers();
    super.dispose();
  }
}

final explorerStateProvider =
    StateNotifierProvider<ExplorerStateNotifier, ExplorerStateData>(
  (ref) => ExplorerStateNotifier(),
);
