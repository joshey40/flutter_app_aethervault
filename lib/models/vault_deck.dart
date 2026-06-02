import '../services/scryfall/scryfall_card_print.dart';

enum DeckZone {
  mainboard,
  sideboard,
  commander,
  maybeboard,
}

extension DeckZoneLabel on DeckZone {
  String get storageValue => name;

  String get userFacingName {
    switch (this) {
      case DeckZone.mainboard:
        return 'Mainboard';
      case DeckZone.sideboard:
        return 'Sideboard';
      case DeckZone.commander:
        return 'Commander';
      case DeckZone.maybeboard:
        return 'Maybeboard';
    }
  }

  static DeckZone fromStorageValue(String? value) {
    return DeckZone.values.firstWhere(
      (zone) => zone.storageValue == value,
      orElse: () => DeckZone.mainboard,
    );
  }
}

class VaultDeck {
  const VaultDeck({
    required this.id,
    required this.name,
    required this.format,
    required this.entries,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.tags = const <String>[],
    this.customCategories = const <DeckCategory>[],
  });

  final String id;
  final String name;
  final String format;
  final List<DeckEntry> entries;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Reserved for later folder/navigation features.
  final String? folderId;

  /// Reserved for later deck-level tags.
  final List<String> tags;

  /// Reserved for later user-defined grouping such as ramp, removal, wincons.
  final List<DeckCategory> customCategories;

  int get totalCards => entries.fold<int>(0, (sum, entry) => sum + entry.quantity);

  int countCardsInZone(DeckZone zone) {
    return entries.where((entry) => entry.zone == zone).fold<int>(0, (sum, entry) => sum + entry.quantity);
  }

  VaultDeck copyWith({
    String? id,
    String? name,
    String? format,
    List<DeckEntry>? entries,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderId,
    List<String>? tags,
    List<DeckCategory>? customCategories,
  }) {
    return VaultDeck(
      id: id ?? this.id,
      name: name ?? this.name,
      format: format ?? this.format,
      entries: entries ?? this.entries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      customCategories: customCategories ?? this.customCategories,
    );
  }

  VaultDeck addOrIncrementCard(
    DeckEntry newEntry, {
    int delta = 1,
  }) {
    final updatedEntries = [...entries];
    final index = updatedEntries.indexWhere(
      (entry) => entry.cardKey == newEntry.cardKey && entry.zone == newEntry.zone && entry.categoryId == newEntry.categoryId,
    );

    if (index == -1) {
      updatedEntries.add(newEntry.copyWith(quantity: delta.clamp(1, 999)));
    } else {
      final existing = updatedEntries[index];
      updatedEntries[index] = existing.copyWith(quantity: (existing.quantity + delta).clamp(1, 999));
    }

    return copyWith(entries: updatedEntries, updatedAt: DateTime.now());
  }

  VaultDeck updateEntryQuantity(String entryId, int quantity) {
    final normalizedQuantity = quantity.clamp(0, 999);
    final updatedEntries = entries
        .map((entry) => entry.id == entryId ? entry.copyWith(quantity: normalizedQuantity) : entry)
        .where((entry) => entry.quantity > 0)
        .toList(growable: false);

    return copyWith(entries: updatedEntries, updatedAt: DateTime.now());
  }

  VaultDeck removeEntry(String entryId) {
    return copyWith(
      entries: entries.where((entry) => entry.id != entryId).toList(growable: false),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'format': format,
        'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'folderId': folderId,
        'tags': tags,
        'customCategories': customCategories.map((category) => category.toJson()).toList(growable: false),
      };

  factory VaultDeck.fromJson(Map<String, dynamic> json) {
    return VaultDeck(
      id: json['id'] as String? ?? _fallbackId(),
      name: json['name'] as String? ?? 'Untitled Deck',
      format: json['format'] as String? ?? 'Commander',
      entries: (json['entries'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(DeckEntry.fromJson)
          .toList(growable: false),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      folderId: json['folderId'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[]).whereType<String>().toList(growable: false),
      customCategories: (json['customCategories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(DeckCategory.fromJson)
          .toList(growable: false),
    );
  }

  static String _fallbackId() => DateTime.now().microsecondsSinceEpoch.toString();
}

class DeckEntry {
  const DeckEntry({
    required this.id,
    required this.scryfallId,
    required this.name,
    required this.quantity,
    this.oracleId,
    this.imageUrl,
    this.typeLine,
    this.manaCost,
    this.zone = DeckZone.mainboard,
    this.categoryId,
    this.tags = const <String>[],
  });

  final String id;
  final String scryfallId;
  final String? oracleId;
  final String name;
  final int quantity;
  final String? imageUrl;
  final String? typeLine;
  final String? manaCost;

  /// First version writes everything to mainboard, but the field is persisted now.
  final DeckZone zone;

  /// Reserved for later custom categories.
  final String? categoryId;

  /// Reserved for later card-level tags.
  final List<String> tags;

  String get cardKey => oracleId ?? scryfallId;

  DeckEntry copyWith({
    String? id,
    String? scryfallId,
    String? oracleId,
    String? name,
    int? quantity,
    String? imageUrl,
    String? typeLine,
    String? manaCost,
    DeckZone? zone,
    String? categoryId,
    List<String>? tags,
  }) {
    return DeckEntry(
      id: id ?? this.id,
      scryfallId: scryfallId ?? this.scryfallId,
      oracleId: oracleId ?? this.oracleId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      typeLine: typeLine ?? this.typeLine,
      manaCost: manaCost ?? this.manaCost,
      zone: zone ?? this.zone,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'scryfallId': scryfallId,
        'oracleId': oracleId,
        'name': name,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'typeLine': typeLine,
        'manaCost': manaCost,
        'zone': zone.storageValue,
        'categoryId': categoryId,
        'tags': tags,
      };

  factory DeckEntry.fromJson(Map<String, dynamic> json) {
    return DeckEntry(
      id: json['id'] as String? ?? _fallbackEntryId(),
      scryfallId: json['scryfallId'] as String? ?? '',
      oracleId: json['oracleId'] as String?,
      name: json['name'] as String? ?? 'Unknown Card',
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
      typeLine: json['typeLine'] as String?,
      manaCost: json['manaCost'] as String?,
      zone: DeckZoneLabel.fromStorageValue(json['zone'] as String?),
      categoryId: json['categoryId'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[]).whereType<String>().toList(growable: false),
    );
  }

  factory DeckEntry.fromScryfallCard(
    ScryfallCardPrint card, {
    DeckZone zone = DeckZone.mainboard,
    String? categoryId,
  }) {
    return DeckEntry(
      id: '${card.id}_${zone.storageValue}_${categoryId ?? 'default'}',
      scryfallId: card.id,
      oracleId: card.oracleId,
      name: card.name,
      quantity: 1,
      imageUrl: card.displayImageSmalls.isNotEmpty ? card.displayImageSmalls.first : null,
      typeLine: card.typeLine,
      manaCost: card.manaCost,
      zone: zone,
      categoryId: categoryId,
    );
  }

  static String _fallbackEntryId() => DateTime.now().microsecondsSinceEpoch.toString();
}

class DeckCategory {
  const DeckCategory({
    required this.id,
    required this.name,
    this.colorValue,
  });

  final String id;
  final String name;
  final int? colorValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
      };

  factory DeckCategory.fromJson(Map<String, dynamic> json) {
    return DeckCategory(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Category',
      colorValue: json['colorValue'] as int?,
    );
  }
}