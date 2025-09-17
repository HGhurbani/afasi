import 'package:afasi/app/app.dart';
import 'package:afasi/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  for (final brightness in Brightness.values) {
    testWidgets(
        "initial theme matches system brightness when no preference is stored: "
        "${brightness == Brightness.dark ? 'dark' : 'light'}",
        (WidgetTester tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(() {
        binding.platformDispatcher.platformBrightnessTestValue = null;
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final expectedThemeMode =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

      expect(materialApp.themeMode, expectedThemeMode);
      expect(StorageService.getTheme(), brightness == Brightness.dark);
    });
  }
}
