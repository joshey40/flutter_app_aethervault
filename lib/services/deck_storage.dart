import 'dart:convert';

import '../models/vault_deck.dart';
import 'app_preferences_storage.dart';

class DeckStorageException implements Exception {
  const DeckStorageException(this.message);

  final String message;

  @override
  String toString() => 'DeckStorageException: $message';
}

class DeckStorage {
  DeckStorage({AppPreferencesStorage? preferencesStorage})
      : _preferencesStorage = preferencesStorage ?? AppPreferencesStorage();

  final AppPreferencesStorage _preferencesStorage;

  Future<List<VaultDeck>> loadDecks() async {
    final rawJson = await _preferencesStorage.loadDecksJson();
    if (rawJson == null || rawJson.trim().isEmpty) return const <VaultDeck>[];

    try {
      final decoded = json.decode(rawJson);
      if (decoded is! List) return const <VaultDeck>[];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(VaultDeck.fromJson)
          .toList(growable: false)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (error) {
      throw DeckStorageException('Failed to load decks: $error');
    }
  }

  Future<void> saveDecks(List<VaultDeck> decks) async {
    try {
      final normalizedDecks = [...decks]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final rawJson = json.encode(normalizedDecks.map((deck) => deck.toJson()).toList(growable: false));
      await _preferencesStorage.saveDecksJson(rawJson);
    } catch (error) {
      throw DeckStorageException('Failed to save decks: $error');
    }
  }

  Future<VaultDeck> createDeck({
    required String name,
    required String format,
  }) async {
    final now = DateTime.now();
    final deck = VaultDeck(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Untitled Deck' : name.trim(),
      format: format.trim().isEmpty ? 'Commander' : format.trim(),
      entries: const <DeckEntry>[],
      createdAt: now,
      updatedAt: now,
    );

    final decks = await loadDecks();
    await saveDecks([deck, ...decks]);
    return deck;
  }

  Future<void> upsertDeck(VaultDeck updatedDeck) async {
    final decks = await loadDecks();
    final index = decks.indexWhere((deck) => deck.id == updatedDeck.id);
    final nextDecks = [...decks];
    if (index == -1) {
      nextDecks.insert(0, updatedDeck);
    } else {
      nextDecks[index] = updatedDeck;
    }
    await saveDecks(nextDecks);
  }

  Future<void> deleteDeck(String deckId) async {
    final decks = await loadDecks();
    await saveDecks(decks.where((deck) => deck.id != deckId).toList(growable: false));
  }
}
