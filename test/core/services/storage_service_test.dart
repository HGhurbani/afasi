import 'package:afasi/core/constants/app_constants.dart';
import 'package:afasi/core/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('returns empty favorites by default', () {
    expect(StorageService.getFavorites(), isEmpty);
  });

  test('saves and retrieves favorites', () async {
    await StorageService.saveFavorites(const ['دعاء 1', 'دعاء 2']);
    expect(StorageService.getFavorites(), equals(['دعاء 1', 'دعاء 2']));
  });

  test('persists and restores last audio category', () async {
    expect(StorageService.getLastCategory(), AppConstants.defaultCategory);

    await StorageService.saveLastCategory('القرآن الكريم');
    expect(StorageService.getLastCategory(), 'القرآن الكريم');
  });

  test('persists and restores theme mode', () async {
    expect(StorageService.getTheme(), isNull);
    expect(StorageService.hasThemePreference(), isFalse);

    await StorageService.saveTheme(true);
    expect(StorageService.hasThemePreference(), isTrue);
    expect(StorageService.getTheme(), isTrue);

    await StorageService.saveTheme(false);
    expect(StorageService.getTheme(), isFalse);
  });
}
