import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Level ilerleme ve yıldız sistemi için Provider
///
/// Yıldız hesaplama formülü (yanlış oranına göre):
/// - %0-25 yanlış → 3 yıldız
/// - %25-55 yanlış → 2 yıldız
/// - %55-75 yanlış → 1 yıldız
/// - %75+ yanlış → 0 yıldız
class LevelProgressProvider extends ChangeNotifier {
  // Her kategori için level yıldızları
  // Key format: "kategori_level" örn: "sorting_1", "matching_2"
  final Map<String, int> _levelStars = {};

  // Her kategori için tamamlanma durumu
  final Map<String, bool> _levelCompleted = {};

  int getStars(String category, int level) {
    return _levelStars['${category}_$level'] ?? 0;
  }

  bool isCompleted(String category, int level) {
    return _levelCompleted['${category}_$level'] ?? false;
  }

  /// Başarı oranına göre yıldız hesapla
  /// [wrongCount]: Yanlış cevap sayısı
  /// [totalCount]: Toplam soru sayısı
  static int calculateStars(int wrongCount, int totalCount) {
    if (totalCount == 0) return 0;

    // Başarı oranına göre yıldız hesapla
    double successRate = (totalCount - wrongCount) / totalCount;

    if (successRate >= 0.75) {
      return 3; // %75-100 başarı → 3 yıldız
    } else if (successRate >= 0.50) {
      return 2; // %50-75 başarı → 2 yıldız
    } else {
      return 1; // %0-50 başarı → 1 yıldız (minimum)
    }
  }

  /// Level tamamlandığında çağrılır
  Future<void> completeLevel(
    String category,
    int level,
    int wrongCount,
    int totalCount,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    int stars = calculateStars(wrongCount, totalCount);

    // Önceki yıldızlardan daha iyiyse güncelle
    int previousStars = prefs.getInt('${category}_stage_${level}_stars') ?? 0;
    if (stars > previousStars) {
      await prefs.setInt('${category}_stage_${level}_stars', stars);
      _levelStars['${category}_$level'] = stars;
    } else {
      _levelStars['${category}_$level'] = previousStars;
    }

    // Tamamlanma durumunu kaydet
    await prefs.setBool('${category}_stage_${level}_completed', true);
    _levelCompleted['${category}_$level'] = true;

    notifyListeners();
  }

  /// SharedPreferences'dan verileri yükle
  Future<void> loadProgress(String category, List<int> levels) async {
    final prefs = await SharedPreferences.getInstance();

    for (int level in levels) {
      _levelStars['${category}_$level'] =
          prefs.getInt('${category}_stage_${level}_stars') ?? 0;
      _levelCompleted['${category}_$level'] =
          prefs.getBool('${category}_stage_${level}_completed') ?? false;
    }

    notifyListeners();
  }

  /// Belirli bir kategori için tüm ilerlemeyi sıfırla
  Future<void> resetProgress(String category, List<int> levels) async {
    final prefs = await SharedPreferences.getInstance();

    for (int level in levels) {
      await prefs.remove('${category}_stage_${level}_stars');
      await prefs.remove('${category}_stage_${level}_completed');
      _levelStars.remove('${category}_$level');
      _levelCompleted.remove('${category}_$level');
    }

    notifyListeners();
  }
}
