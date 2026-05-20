import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_aethervault/screens/home/lifecounter/data/lifecounter_model.dart';
import 'package:flutter_app_aethervault/screens/home/lifecounter/data/lifecounter_storage.dart';

void main() {
  test('LifecounterStorage save and load roundtrip', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LifecounterStorage();

    final game = LifecounterGame(
      startLife: 20,
      playerCount: 2,
      currentLives: [20, 20],
    );

    await storage.saveGame(game);
    final loaded = await storage.loadGame();

    expect(loaded, isNotNull);
    expect(loaded!.startLife, equals(game.startLife));
    expect(loaded.playerCount, equals(game.playerCount));
  });

  test('LifecounterStorage returns null on corrupted data', () async {
    SharedPreferences.setMockInitialValues({'lifecounter.current_game': 'not a json'});
    final storage = LifecounterStorage();

    final loaded = await storage.loadGame();
    expect(loaded, isNull);
  });
}
