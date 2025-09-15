import 'package:afasi/features/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsPage adapts to theme changes and shows settings labels',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('إعدادات التطبيق'), findsOneWidget);

    BuildContext context = tester.element(find.byType(SettingsPage));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const SettingsPage(),
    ));
    await tester.pump();

    context = tester.element(find.byType(SettingsPage));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('إعدادات التطبيق'), findsOneWidget);
  });
}
