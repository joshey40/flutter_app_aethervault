import 'lifecounter_model.dart';
import '../../../../services/app_preferences_storage.dart';
import 'package:flutter/foundation.dart';

/// Exception thrown when storage operations fail.
class LifecounterStorageException implements Exception {
  final String message;
  LifecounterStorageException(this.message);
  @override
  String toString() => 'LifecounterStorageException: $message';
}

class LifecounterStorage {
  Future<void> saveGame(LifecounterGame game) async {
    final prefs = AppPreferencesStorage();
    try {
      // Validate before persisting to catch inconsistencies early.
      game.validate();
      await prefs.saveLifecounterGame(game.encode());
    } catch (e, st) {
      // Use debugPrint via foundation to avoid flutter imports in pure dart contexts.
      debugPrint('Failed to save lifecounter game: $e\n$st');
      throw LifecounterStorageException('Failed to save game: $e');
    }
  }

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
