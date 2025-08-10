import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ActivityTracker {
  static Future<void> completeActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserJson = prefs.getString('current_user');
      
      if (currentUserJson != null) {
        final currentUser = Map<String, dynamic>.from(json.decode(currentUserJson));
        final currentUserEmail = currentUser['email'] ?? '';
        
        // Bugünün tarihini al
        final today = DateTime.now();
        final todayKey = '${today.year}-${today.month}-${today.day}';
        final userActivityKey = '${currentUserEmail}_activities_$todayKey';
        
        // Mevcut sayıyı al ve artır
        final currentCount = prefs.getInt(userActivityKey) ?? 0;
        final newCount = currentCount + 1;
        
        // Yeni sayıyı kaydet
        await prefs.setInt(userActivityKey, newCount);
        
        print('🎉 Activity completed! New count: $newCount');
      }
    } catch (e) {
      print('❌ Error completing activity: $e');
    }
  }
} 