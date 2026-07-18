import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_aethervault/services/localization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initializes the current locale strings', () async {
    await initializeLocalizations('de');

    expect(appLocalizations.translate('lifecounter.title'), 'Lebenszähler');
  });
}
