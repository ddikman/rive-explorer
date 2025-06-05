import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConsoleMessageType {
  info,
  warning,
  error,
  debug,
}

class ConsoleMessage {
  final String message;
  final ConsoleMessageType type;
  final DateTime timestamp;
  final String? source;

  const ConsoleMessage({
    required this.message,
    required this.type,
    required this.timestamp,
    this.source,
  });

  Color get color {
    switch (type) {
      case ConsoleMessageType.error:
        return const Color(0xFFF44336); // Red
      case ConsoleMessageType.warning:
        return const Color(0xFFFF9800); // Orange
      case ConsoleMessageType.info:
        return const Color(0xFF2196F3); // Blue
      case ConsoleMessageType.debug:
        return const Color(0xFF9E9E9E); // Gray
    }
  }

  IconData get icon {
    switch (type) {
      case ConsoleMessageType.error:
        return Icons.error;
      case ConsoleMessageType.warning:
        return Icons.warning;
      case ConsoleMessageType.info:
        return Icons.info;
      case ConsoleMessageType.debug:
        return Icons.bug_report;
    }
  }

  String get prefix {
    switch (type) {
      case ConsoleMessageType.error:
        return 'ERROR';
      case ConsoleMessageType.warning:
        return 'WARN';
      case ConsoleMessageType.info:
        return 'INFO';
      case ConsoleMessageType.debug:
        return 'DEBUG';
    }
  }
}

class ConsoleState {
  final List<ConsoleMessage> messages;
  final bool autoScroll;

  const ConsoleState({
    this.messages = const [],
    this.autoScroll = true,
  });

  ConsoleState copyWith({
    List<ConsoleMessage>? messages,
    bool? autoScroll,
  }) {
    return ConsoleState(
      messages: messages ?? this.messages,
      autoScroll: autoScroll ?? this.autoScroll,
    );
  }
}

class ConsoleNotifier extends StateNotifier<ConsoleState> {
  ConsoleNotifier() : super(const ConsoleState()) {
    // Add initial welcome message
    addInfo('Console initialized - monitoring Rive operations',
        source: 'System');
  }

  void addMessage(String message, ConsoleMessageType type, {String? source}) {
    final newMessage = ConsoleMessage(
      message: message,
      type: type,
      timestamp: DateTime.now(),
      source: source,
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );
  }

  void addError(String message, {String? source}) {
    addMessage(message, ConsoleMessageType.error, source: source);
  }

  void addWarning(String message, {String? source}) {
    addMessage(message, ConsoleMessageType.warning, source: source);
  }

  void addInfo(String message, {String? source}) {
    addMessage(message, ConsoleMessageType.info, source: source);
  }

  void addDebug(String message, {String? source}) {
    addMessage(message, ConsoleMessageType.debug, source: source);
  }

  void clear() {
    state = state.copyWith(messages: []);
    addInfo('Console cleared', source: 'System');
  }

  void toggleAutoScroll() {
    state = state.copyWith(autoScroll: !state.autoScroll);
  }

  // Helper method to log Rive file operations
  void logRiveOperation(String operation,
      {String? details, bool isError = false}) {
    final message = details != null ? '$operation: $details' : operation;
    if (isError) {
      addError(message, source: 'Rive');
    } else {
      addInfo(message, source: 'Rive');
    }
  }

  // Helper method to log controller operations
  void logControllerOperation(String operation, String controllerType,
      {String? details, bool isError = false}) {
    final message = details != null
        ? '$controllerType $operation: $details'
        : '$controllerType $operation';
    if (isError) {
      addError(message, source: 'Controller');
    } else {
      addDebug(message, source: 'Controller');
    }
  }

  // Helper method to analyze Rive file for potential issues
  void analyzeRiveFile(String fileName, int artboardCount, int animationCount,
      int stateMachineCount) {
    addInfo('File analysis started: $fileName', source: 'Diagnostic');

    if (artboardCount == 0) {
      addWarning('No artboards found - file may be corrupted',
          source: 'Diagnostic');
    }

    if (animationCount == 0 && stateMachineCount == 0) {
      addWarning('No animations or state machines found - file may be empty',
          source: 'Diagnostic');
    }

    addInfo(
        'Analysis complete: $artboardCount artboards, $animationCount animations, $stateMachineCount state machines',
        source: 'Diagnostic');
  }

  // Helper method to suggest solutions for common errors
  void suggestSolution(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'feathering':
      case 'vector_feathering':
        addInfo(
            'Feathering Issue: Remove Feather effects from shapes in Rive Editor',
            source: 'Solution');
        addInfo(
            'Check: https://rive.app/docs/feature-support#feathers for feature support',
            source: 'Solution');
        break;
      case 'range_error':
      case 'index_error':
        addInfo(
            'Index Error: Check for corrupted data or invalid references in the Rive file',
            source: 'Solution');
        break;
      case 'state_machine':
        addInfo(
            'State Machine Error: Verify all inputs and transitions are properly configured',
            source: 'Solution');
        break;
    }
  }
}

final consoleProvider = StateNotifierProvider<ConsoleNotifier, ConsoleState>(
  (ref) => ConsoleNotifier(),
);
