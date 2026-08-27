import 'lifecounter_model.dart';
import '../../../../services/app_preferences_storage.dart';
import 'package:flutter/foundation.dart';

/// Exception thrown when there is an error in LifecounterStorage operations.
class LifecounterStorageException implements Exception {
  final String message;
  LifecounterStorageException(this.message);
  @override
  String toString() => 'LifecounterStorageException: $message';
}

class LifecounterStorage {
  /// Save the current lifecounter [game] state as a JSON string.
  Future<void> saveGame(LifecounterGame game) async {
    final prefs = AppPreferencesStorage();
    try {
      // Validate before persisting to catch inconsistencies early.
      game.validate();
      await prefs.saveLifecounterGame(game.encode());
    } catch (e, st) {
      throw LifecounterStorageException('Failed to save game: $e\n$st');
    }
  }

  /// Load the current lifecounter game state.
  /// Returns null if no game is saved or if the saved data is invalid.
  Future<LifecounterGame?> loadGame() async {
    final prefs = AppPreferencesStorage();
    try {
      final data = await prefs.loadLifecounterGame();
      final game = LifecounterGame.decode(data);
      if (game == null) {
        debugPrint('LifecounterStorage: loaded data is null or invalid');
        return null;
      }
      return game;
    } catch (e, st) {
      debugPrint('Failed to load lifecounter game: $e\n$st');
      return null;
    }
  }

  /// Clear the current lifecounter game state.
  Future<void> clearGame() async {
    final prefs = AppPreferencesStorage();
    try {
      await prefs.clearLifecounterGame();
    } catch (e, st) {
      debugPrint('Failed to clear lifecounter game: $e\n$st');
      throw LifecounterStorageException('Failed to clear game: $e');
    }
  }
}
