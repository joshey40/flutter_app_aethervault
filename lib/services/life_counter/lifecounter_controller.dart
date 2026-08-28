import 'package:flutter/foundation.dart';

import 'lifecounter_model.dart';
import 'lifecounter_storage.dart';

/// Coordinates the persisted lifecounter state between the different screens.
///
/// The controller is shared by the lifecounter routes so screens do not have
/// to infer state changes from navigation lifecycle callbacks.
class LifecounterController extends ChangeNotifier {
  LifecounterController({LifecounterStorage? storage})
      : _storage = storage ?? LifecounterStorage();

  final LifecounterStorage _storage;
  bool _hasSavedGame = false;

  bool get hasSavedGame => _hasSavedGame;

  /// Loads the persisted state once when the application starts.
  Future<void> initialize() async {
    final game = await _storage.loadGame();
    _hasSavedGame = game != null;
  }

  Future<LifecounterGame?> loadGame() {
    return _storage.loadGame();
  }

  Future<void> saveGame(LifecounterGame game) async {
    await _storage.saveGame(game);
    if (!_hasSavedGame) {
      _hasSavedGame = true;
      notifyListeners();
    }
  }

  Future<void> clearGame() async {
    await _storage.clearGame();
    if (_hasSavedGame) {
      _hasSavedGame = false;
      notifyListeners();
    }
  }
}
