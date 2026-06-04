import 'dart:convert';

import '../models/collection_entry.dart';
import 'app_preferences_storage.dart';

class CollectionStorageException implements Exception {
  const CollectionStorageException(this.message);

  final String message;

  @override
  String toString() => 'CollectionStorageException: $message';
}

class CollectionStorage {
  CollectionStorage({AppPreferencesStorage? preferencesStorage})
      : _preferencesStorage = preferencesStorage ?? AppPreferencesStorage();

  final AppPreferencesStorage _preferencesStorage;

  Future<List<CollectionEntry>> loadEntries() async {
    final rawJson = await _preferencesStorage.loadCollectionJson();
    if (rawJson == null || rawJson.trim().isEmpty) return const <CollectionEntry>[];

    try {
      final decoded = json.decode(rawJson);
      if (decoded is! List) return const <CollectionEntry>[];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CollectionEntry.fromJson)
          .toList(growable: false)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (error) {
      throw CollectionStorageException('Failed to load collection: $error');
    }
  }

  Future<void> saveEntries(List<CollectionEntry> entries) async {
    try {
      final normalized = [...entries]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final rawJson = json.encode(normalized.map((entry) => entry.toJson()).toList(growable: false));
      await _preferencesStorage.saveCollectionJson(rawJson);
    } catch (error) {
      throw CollectionStorageException('Failed to save collection: $error');
    }
  }

  Future<CollectionEntry> addEntry(CollectionEntry newEntry) async {
    final entries = await loadEntries();
    final existingIndex = entries.indexWhere((entry) => entry.matchingKey == newEntry.matchingKey);
    final nextEntries = [...entries];

    if (existingIndex == -1) {
      nextEntries.insert(0, newEntry);
      await saveEntries(nextEntries);
      return newEntry;
    }

    final existing = nextEntries[existingIndex];
    final updated = existing.copyWith(
      quantity: existing.quantity + newEntry.quantity,
      updatedAt: DateTime.now(),
    );
    nextEntries[existingIndex] = updated;
    await saveEntries(nextEntries);
    return updated;
  }

  Future<void> upsertEntry(CollectionEntry updatedEntry) async {
    final entries = await loadEntries();
    final index = entries.indexWhere((entry) => entry.id == updatedEntry.id);
    final nextEntries = [...entries];
    final normalized = updatedEntry.copyWith(updatedAt: DateTime.now());

    if (index == -1) {
      nextEntries.insert(0, normalized);
    } else {
      nextEntries[index] = normalized;
    }

    await saveEntries(nextEntries);
  }

  Future<void> deleteEntry(String entryId) async {
    final entries = await loadEntries();
    await saveEntries(entries.where((entry) => entry.id != entryId).toList(growable: false));
  }
}
