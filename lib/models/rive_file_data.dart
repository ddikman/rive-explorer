import 'package:equatable/equatable.dart';
import 'package:rive/rive.dart';

/// Represents the complete data structure of a loaded Rive file
class RiveFileData extends Equatable {
  final String fileName;
  final String filePath;
  final List<RiveArtboardData> artboards;
  final RiveFile riveFile;
  final DateTime uploadedAt;

  const RiveFileData({
    required this.fileName,
    required this.filePath,
    required this.artboards,
    required this.riveFile,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [fileName, filePath, artboards, uploadedAt];
}

/// Represents an artboard within a Rive file
class RiveArtboardData extends Equatable {
  final String name;
  final List<RiveStateMachineData> stateMachines;
  final List<RiveAnimationData> animations;
  final Artboard artboard;

  const RiveArtboardData({
    required this.name,
    required this.stateMachines,
    required this.animations,
    required this.artboard,
  });

  @override
  List<Object?> get props => [name, stateMachines, animations];
}

/// Represents a state machine within an artboard
class RiveStateMachineData extends Equatable {
  final String name;
  final List<RiveInputData> inputs;
  final StateMachineController? controller;

  const RiveStateMachineData({
    required this.name,
    required this.inputs,
    this.controller,
  });

  @override
  List<Object?> get props => [name, inputs];
}

/// Represents an animation within an artboard
class RiveAnimationData extends Equatable {
  final String name;
  final double duration;
  final bool isLooping;
  final LinearAnimationInstance? instance;

  const RiveAnimationData({
    required this.name,
    required this.duration,
    required this.isLooping,
    this.instance,
  });

  @override
  List<Object?> get props => [name, duration, isLooping];
}

/// Represents an input (trigger, boolean, number) in a state machine
class RiveInputData extends Equatable {
  final String name;
  final RiveInputType type;
  final dynamic defaultValue;
  final SMIInput? smiInput;

  const RiveInputData({
    required this.name,
    required this.type,
    this.defaultValue,
    this.smiInput,
  });

  @override
  List<Object?> get props => [name, type, defaultValue];
}

/// Enum for different types of Rive inputs
enum RiveInputType {
  trigger,
  boolean,
  number;

  String get displayName {
    switch (this) {
      case RiveInputType.trigger:
        return 'Trigger';
      case RiveInputType.boolean:
        return 'Boolean';
      case RiveInputType.number:
        return 'Number';
    }
  }
}

/// Represents the current state of the file upload process
enum UploadStatus {
  idle,
  uploading,
  processing,
  success,
  error;
}

/// Represents the state of file upload
class UploadState extends Equatable {
  final UploadStatus status;
  final double progress;
  final String? errorMessage;
  final RiveFileData? riveFileData;

  const UploadState({
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.riveFileData,
  });

  UploadState copyWith({
    UploadStatus? status,
    double? progress,
    String? errorMessage,
    RiveFileData? riveFileData,
  }) {
    return UploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      riveFileData: riveFileData ?? this.riveFileData,
    );
  }

  @override
  List<Object?> get props => [status, progress, errorMessage, riveFileData];
}
