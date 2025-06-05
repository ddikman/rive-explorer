import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rive/rive.dart';
import '../../../models/rive_file_data.dart';
import '../../explorer/providers/console_provider.dart';

part 'upload_provider.g.dart';

@riverpod
class UploadNotifier extends _$UploadNotifier {
  @override
  UploadState build() {
    return const UploadState();
  }

  /// Upload and process a Rive file
  Future<void> uploadFile(
      String filePath, String fileName, Uint8List fileBytes) async {
    try {
      // Get console notifier reference
      final consoleNotifier = ref.read(consoleProvider.notifier);
      consoleNotifier.logRiveOperation('Starting upload', details: fileName);

      // Set uploading state
      state = state.copyWith(
        status: UploadStatus.uploading,
        progress: 0.0,
        errorMessage: null,
      );

      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        state = state.copyWith(progress: i / 100);
      }

      consoleNotifier.logRiveOperation('Upload completed, processing file',
          details: fileName);

      // Set processing state
      state = state.copyWith(
        status: UploadStatus.processing,
        progress: 0.0,
      );

      // Load and process the Rive file
      final riveFileData =
          await _processRiveFile(fileName, filePath, fileBytes);

      consoleNotifier.logRiveOperation('File processed successfully',
          details:
              '${riveFileData.artboards.length} artboards, ${riveFileData.artboards.fold(0, (sum, ab) => sum + ab.animations.length)} animations');

      // Analyze the file for potential issues
      final totalAnimations = riveFileData.artboards
          .fold(0, (sum, ab) => sum + ab.animations.length);
      final totalStateMachines = riveFileData.artboards
          .fold(0, (sum, ab) => sum + ab.stateMachines.length);

      consoleNotifier.analyzeRiveFile(fileName, riveFileData.artboards.length,
          totalAnimations, totalStateMachines);

      // Set success state
      state = state.copyWith(
        status: UploadStatus.success,
        riveFileData: riveFileData,
        progress: 1.0,
      );
    } catch (e) {
      // Log error to console
      ref.read(consoleProvider.notifier).logRiveOperation(
            'Upload failed',
            details: e.toString(),
            isError: true,
          );

      // Set error state
      state = state.copyWith(
        status: UploadStatus.error,
        errorMessage: e.toString(),
        progress: 0.0,
      );
    }
  }

  /// Process the Rive file and extract all relevant data
  Future<RiveFileData> _processRiveFile(
      String fileName, String filePath, Uint8List fileBytes) async {
    try {
      // Initialize text engine before processing Rive files with text
      // This fixes the LateInitializationError: Field '_makeFont' has not been initialized
      await RiveFile.initializeText();

      // Validate file bytes
      if (fileBytes.isEmpty) {
        throw Exception('File is empty');
      }

      // Load the Rive file using ByteData approach but with better error handling
      final byteData = ByteData.sublistView(fileBytes);

      // Try to import the Rive file
      late final RiveFile riveFile;
      try {
        riveFile = RiveFile.import(byteData);
      } catch (e) {
        throw Exception('Invalid Rive file format: $e');
      }

      if (riveFile.artboards.isEmpty) {
        throw Exception('No artboards found in Rive file');
      }

      // Extract artboards and their data
      final artboards = <RiveArtboardData>[];

      for (final artboard in riveFile.artboards) {
        try {
          // Extract animations - only process LinearAnimations
          final animations = <RiveAnimationData>[];
          for (final animation in artboard.animations) {
            try {
              // Only process LinearAnimation types, skip others
              if (animation is LinearAnimation) {
                animations.add(RiveAnimationData(
                  name: animation.name,
                  duration: animation.durationSeconds,
                  isLooping: animation.loop == Loop.loop ||
                      animation.loop == Loop.pingPong,
                ));
              }
            } catch (e) {
              // Skip this animation if there's an error processing it
              print('Warning: Could not process animation: $e');
            }
          }

          // Extract state machines with proper input extraction
          final stateMachines = <RiveStateMachineData>[];
          for (final stateMachine in artboard.stateMachines) {
            try {
              // Create a temporary controller to extract input information
              final tempArtboard = riveFile.artboardByName(artboard.name);
              if (tempArtboard != null) {
                final controller = StateMachineController.fromArtboard(
                    tempArtboard, stateMachine.name);

                final inputs = <RiveInputData>[];
                if (controller != null) {
                  // Extract inputs from the controller
                  for (final input in controller.inputs) {
                    RiveInputType inputType;
                    dynamic defaultValue;

                    if (input is SMITrigger) {
                      inputType = RiveInputType.trigger;
                      defaultValue = null;
                    } else if (input is SMIBool) {
                      inputType = RiveInputType.boolean;
                      defaultValue = input.value;
                    } else if (input is SMINumber) {
                      inputType = RiveInputType.number;
                      defaultValue = input.value;
                    } else {
                      continue; // Skip unknown input types
                    }

                    inputs.add(RiveInputData(
                      name: input.name,
                      type: inputType,
                      defaultValue: defaultValue,
                      smiInput: input,
                    ));
                  }

                  // Clean up the temporary controller
                  controller.dispose();
                }

                stateMachines.add(RiveStateMachineData(
                  name: stateMachine.name,
                  inputs: inputs,
                  controller:
                      null, // Will be created when needed in the preview
                ));
              }
            } catch (e) {
              print(
                  'Warning: Could not process state machine ${stateMachine.name}: $e');
              // Still add the state machine with minimal data
              stateMachines.add(RiveStateMachineData(
                name: stateMachine.name,
                inputs: [],
                controller: null,
              ));
            }
          }

          artboards.add(RiveArtboardData(
            name: artboard.name,
            stateMachines: stateMachines,
            animations: animations,
            artboard: artboard,
          ));
        } catch (e) {
          print('Warning: Could not process artboard ${artboard.name}: $e');
          // Still add the artboard with minimal data
          artboards.add(RiveArtboardData(
            name: artboard.name,
            stateMachines: [],
            animations: [],
            artboard: artboard,
          ));
        }
      }

      return RiveFileData(
        fileName: fileName,
        filePath: filePath,
        artboards: artboards,
        riveFile: riveFile,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error processing Rive file: $e');
      throw Exception('Failed to process Rive file: $e');
    }
  }

  /// Reset the upload state
  void reset() {
    state = const UploadState();
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      status: UploadStatus.idle,
    );
  }
}
