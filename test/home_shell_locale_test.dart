import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_aethervault/models/vault_user.dart';
import 'package:flutter_app_aethervault/screens/home/home_shell.dart';
import 'package:flutter_app_aethervault/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeShell updates lifecounter strings when the locale changes', (tester) async {
    await initializeLocalizations('en');
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          user: const VaultUser(displayName: 'Tester', email: 'tester@example.com'),
          themeMode: ThemeMode.light,
          onThemeModeChanged: (_) {},
          locale: const Locale('en'),
          onLocaleChanged: (_) async {},
          onSignOut: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          user: const VaultUser(displayName: 'Tester', email: 'tester@example.com'),
          themeMode: ThemeMode.light,
          onThemeModeChanged: (_) {},
          locale: const Locale('en'),
          onLocaleChanged: (_) async {},
          onSignOut: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Lifecounter'), findsWidgets);

    await initializeLocalizations('de');
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          user: const VaultUser(displayName: 'Tester', email: 'tester@example.com'),
          themeMode: ThemeMode.light,
          onThemeModeChanged: (_) {},
          locale: const Locale('de'),
          onLocaleChanged: (_) async {},
          onSignOut: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lebenszähler'), findsWidgets);
  });
}
