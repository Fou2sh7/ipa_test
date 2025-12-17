import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediconsult/core/cache/family_cache_service.dart';
import 'package:mediconsult/features/family_members/data/family_response_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
  });

  test('cache and read family data', () async {
    const lang = 'en';
    final response = FamilyResponse(
      success: true,
      timestamp: 'now',
      message: 'ok',
      data: FamilyData(familyMembers: const [], totalCount: 0),
    );

    await FamilyCacheService.cacheFamilyData(response, lang);
    final cached = await FamilyCacheService.getCachedFamilyData(lang);
    expect(cached?.success, true);
  });

  test('clear cache removes data', () async {
    const lang = 'en';
    await FamilyCacheService.clearFamilyCache(lang);
    final cached = await FamilyCacheService.getCachedFamilyData(lang);
    expect(cached, isNull);
  });
}


