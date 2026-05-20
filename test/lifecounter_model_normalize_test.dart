import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_aethervault/screens/home/lifecounter/data/lifecounter_model.dart';

void main() {
  test('normalize adds missing rows and columns and preserves values', () {
    final game = LifecounterGame(
      startLife: 20,
      playerCount: 3,
      currentLives: [20, 20, 20],
      // deliberately malformed commanderDamage: only one source with one target
      commanderDamage: [
        [ [5] ]
      ],
      partnerEnabled: [false, false, false],
    );

    // Precondition: malformed
    expect(game.commanderDamage.length < 3 || game.commanderDamage[0].length < 3, true);

    game.normalizeCommanderDamageSlots();

    expect(game.commanderDamage.length, 3);
    for (var s = 0; s < 3; s++) {
      expect(game.commanderDamage[s].length, 3);
      for (var t = 0; t < 3; t++) {
        expect(game.commanderDamage[s][t].isNotEmpty, true);
      }
    }
    // original value preserved at [0][0][0]
    expect(game.commanderDamage[0][0][0], 5);
  });

  test('normalize preserves extra slots (does not truncate)', () {
    final game = LifecounterGame(
      startLife: 20,
      playerCount: 2,
      currentLives: [20, 20],
      // source 0 -> target 1 has 3 slots already
      commanderDamage: [
        [ [0], [1,2,3] ],
        [ [0], [0] ],
      ],
      partnerEnabled: [false, false],
    );

    // target 1 does not have partner enabled => expected slots = 1
    expect(game.partnerEnabled[1], false);
    expect(game.commanderDamage[0][1].length, 3);

    game.normalizeCommanderDamageSlots();

    // extra slots should remain
    expect(game.commanderDamage[0][1].length, 3);
    expect(game.commanderDamage[0][1], [1,2,3]);
  });
}
