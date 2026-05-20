import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_aethervault/screens/home/lifecounter/data/lifecounter_model.dart';

void main() {
  test('LifecounterGame serialization roundtrip', () {
    final game = LifecounterGame(
      startLife: 40,
      playerCount: 2,
      currentLives: [40, 40],
      commanderTax: [2, 0],
      commanderDamage: [
        [[0], [0]],
        [[0], [0]]
      ],
      partnerEnabled: [false, false],
      partnerTax: [0, 0],
      active: true,
      name: 'Test Game',
    );

    final encoded = game.encode();
    final decoded = LifecounterGame.decode(encoded);

    expect(decoded, isNotNull);
    expect(decoded!.startLife, equals(game.startLife));
    expect(decoded.playerCount, equals(game.playerCount));
    expect(decoded.currentLives, equals(game.currentLives));
    expect(decoded.commanderTax, equals(game.commanderTax));
    expect(decoded.partnerEnabled, equals(game.partnerEnabled));
    expect(decoded.name, equals(game.name));
  });

  test('LifecounterGame validate throws on invalid data', () {
    final bad = LifecounterGame(
      startLife: 20,
      playerCount: 0,
      currentLives: [],
    );

    expect(() => bad.validate(), throwsFormatException);
  });
}
