import 'package:flutter/material.dart';
import 'dart:math';

typedef ActivityScreenBuilder = Widget Function();

/// Controls the flow of a sequence of intro/activity screens.
class IntroFlowController extends ChangeNotifier {
  final BuildContext context;
  final List<ActivityScreenBuilder> _activityBuilders;
  final VoidCallback onFlowComplete;
  final bool shuffle;

  int _currentIndex = 0;
  late final List<ActivityScreenBuilder> _shuffledBuilders;

  IntroFlowController({
    required this.context,
    required List<ActivityScreenBuilder> activityBuilders,
    required this.onFlowComplete,
    this.shuffle = false,
  }) : _activityBuilders = activityBuilders {
    _shuffledBuilders = List<ActivityScreenBuilder>.from(_activityBuilders);
    if (shuffle) {
      _shuffledBuilders.shuffle(Random());
    }
  }

  /// Returns the widget for the current activity.
  Widget currentActivity() {
    return _shuffledBuilders[_currentIndex]();
  }

  /// Advances to the next activity, or calls onFlowComplete if done.
  void next() {
    if (_currentIndex < _shuffledBuilders.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      onFlowComplete();
    }
  }

  /// Resets the flow to the beginning.
  void reset() {
    _currentIndex = 0;
    if (shuffle) {
      _shuffledBuilders.shuffle(Random());
    }
    notifyListeners();
  }

  /// Returns the current index (for progress display).
  int get currentIndex => _currentIndex;

  /// Returns the total number of activities.
  int get totalCount => _shuffledBuilders.length;
} 