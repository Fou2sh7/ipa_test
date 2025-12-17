import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediconsult/features/family_members/data/family_response_model.dart';

/// Family members cache service - handles caching for family members data
class FamilyCacheService {
  static const String _familyDataKeyPrefix = 'family_data_';
  static const String _familyLastUpdateKeyPrefix = 'family_last_update_';
  static const int _familyCacheExpiryHours = 24;

  /// Cache family data for specific language
  static Future<void> cacheFamilyData(FamilyResponse data, String lang) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    final dataKey = '$_familyDataKeyPrefix$lang';
    final updateKey = '$_familyLastUpdateKeyPrefix$lang';
    await prefs.setString(dataKey, jsonString);
    await prefs.setInt(updateKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached family data for specific language
  static Future<FamilyResponse?> getCachedFamilyData(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    final dataKey = '$_familyDataKeyPrefix$lang';
    final updateKey = '$_familyLastUpdateKeyPrefix$lang';
    final jsonString = prefs.getString(dataKey);
    final lastUpdate = prefs.getInt(updateKey);

    if (jsonString == null || lastUpdate == null) {
      return null;
    }

    // Check if cache is expired (24 hours)
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - lastUpdate;
    final cacheExpiryMs = _familyCacheExpiryHours * 60 * 60 * 1000;

    if (cacheAge > cacheExpiryMs) {
      await clearFamilyCache(lang);
      return null;
    }

    try {
      final jsonData = jsonDecode(jsonString);
      return FamilyResponse.fromJson(jsonData);
    } catch (e) {
      await clearFamilyCache(lang);
      return null;
    }
  }

  /// Clear family cache for specific language
  static Future<void> clearFamilyCache([String? lang]) async {
    final prefs = await SharedPreferences.getInstance();
    if (lang != null) {
      // Clear cache for specific language
      final dataKey = '$_familyDataKeyPrefix$lang';
      final updateKey = '$_familyLastUpdateKeyPrefix$lang';
      await prefs.remove(dataKey);
      await prefs.remove(updateKey);
    } else {
      // Clear all language caches (for backward compatibility)
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_familyDataKeyPrefix) || key.startsWith(_familyLastUpdateKeyPrefix)) {
          await prefs.remove(key);
        }
      }
    }
  }
}

