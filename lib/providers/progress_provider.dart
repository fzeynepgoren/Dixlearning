import 'package:flutter/material.dart';

class ProgressProvider extends ChangeNotifier {
  bool _stage1Completed = false;
  bool _stage2Completed = false;
  bool _stage3Completed = false;
  bool _stage4Completed = false;

  bool get stage1Completed => _stage1Completed;
  bool get stage2Completed => _stage2Completed;
  bool get stage3Completed => _stage3Completed;
  bool get stage4Completed => _stage4Completed;

  bool get stage2Unlocked => _stage1Completed;
  bool get stage3Unlocked => _stage2Completed;
  bool get stage4Unlocked => _stage3Completed;

  void completeStage1() {
    _stage1Completed = true;
    notifyListeners();
  }

  void completeStage2() {
    _stage2Completed = true;
    notifyListeners();
  }

  void completeStage3() {
    _stage3Completed = true;
    notifyListeners();
  }

  void completeStage4() {
    _stage4Completed = true;
    notifyListeners();
  }

  void resetProgress() {
    _stage1Completed = false;
    _stage2Completed = false;
    _stage3Completed = false;
    _stage4Completed = false;
    notifyListeners();
  }

  Map<String, bool> getProgressMap() {
    return {
      'stage1': _stage1Completed,
      'stage2': _stage2Completed,
      'stage3': _stage3Completed,
      'stage4': _stage4Completed,
    };
  }

  void loadProgress(Map<String, bool> progressMap) {
    _stage1Completed = progressMap['stage1'] ?? false;
    _stage2Completed = progressMap['stage2'] ?? false;
    _stage3Completed = progressMap['stage3'] ?? false;
    _stage4Completed = progressMap['stage4'] ?? false;
    notifyListeners();
  }
}

