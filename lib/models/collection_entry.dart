import '../services/scryfall/scryfall_card_print.dart';

enum CardCondition {
  mint,
  nearMint,
  excellent,
  good,
  lightPlayed,
  played,
  poor;

  String get storageValue => name;

  String get userFacingName => switch (this) {
        CardCondition.mint => 'Mint',
        CardCondition.nearMint => 'Near Mint',
        CardCondition.excellent => 'Excellent',
        CardCondition.good => 'Good',
        CardCondition.lightPlayed => 'Light Played',
        CardCondition.played => 'Played',
        CardCondition.poor => 'Poor',
      };

  static CardCondition fromStorageValue(String? value) {
    return CardCondition.values.firstWhere(
      (condition) => condition.storageValue == value,
      orElse: () => CardCondition.nearMint,
    );
  }
}

enum CardFinish {
  nonfoil,
  foil,
  etched;

  String get storageValue => name;

  String get userFacingName => switch (this) {
        CardFinish.nonfoil => 'Nonfoil',
        CardFinish.foil => 'Foil',
        CardFinish.etched => 'Etched',
      };

  static CardFinish fromStorageValue(String? value) {
    return CardFinish.values.firstWhere(
      (finish) => finish.storageValue == value,
      orElse: () => CardFinish.nonfoil,
    );
  }
}

class CollectionEntry {
  const CollectionEntry({
    required this.id,
    required this.scryfallId,
    required this.cardName,
    required this.setCode,
    required this.collectorNumber,
    required this.language,
    required this.quantity,
    required this.condition,
    required this.finish,
    required this.isSigned,
    required this.isAltered,
    required this.isProxy,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.note,
  });

  final String id;
  final String scryfallId;
  final String cardName;
  final String setCode;
  final String collectorNumber;
  final String language;
  final int quantity;
  final CardCondition condition;
  final CardFinish finish;
  final bool isSigned;
  final bool isAltered;
  final bool isProxy;
  final String? imageUrl;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollectionEntry copyWith({
    String? id,
    String? scryfallId,
    String? cardName,
    String? setCode,
    String? collectorNumber,
    String? language,
    int? quantity,
    CardCondition? condition,
    CardFinish? finish,
    bool? isSigned,
    bool? isAltered,
    bool? isProxy,
    String? imageUrl,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionEntry(
      id: id ?? this.id,
      scryfallId: scryfallId ?? this.scryfallId,
      cardName: cardName ?? this.cardName,
      setCode: setCode ?? this.setCode,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      language: language ?? this.language,
      quantity: (quantity ?? this.quantity).clamp(1, 999).toInt(),
      condition: condition ?? this.condition,
      finish: finish ?? this.finish,
      isSigned: isSigned ?? this.isSigned,
      isAltered: isAltered ?? this.isAltered,
      isProxy: isProxy ?? this.isProxy,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get matchingKey {
    return [
      scryfallId,
      condition.storageValue,
      finish.storageValue,
      isSigned,
      isAltered,
      isProxy,
      note?.trim() ?? '',
    ].join('|');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'scryfallId': scryfallId,
      'cardName': cardName,
      'setCode': setCode,
      'collectorNumber': collectorNumber,
      'language': language,
      'quantity': quantity,
      'condition': condition.storageValue,
      'finish': finish.storageValue,
      'isSigned': isSigned,
      'isAltered': isAltered,
      'isProxy': isProxy,
      'imageUrl': imageUrl,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CollectionEntry.fromJson(Map<String, dynamic> json) {
    return CollectionEntry(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      scryfallId: json['scryfallId'] as String? ?? '',
      cardName: json['cardName'] as String? ?? '',
      setCode: json['setCode'] as String? ?? '',
      collectorNumber: json['collectorNumber'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      quantity: ((json['quantity'] as num?)?.toInt() ?? 1).clamp(1, 999).toInt(),
      condition: CardCondition.fromStorageValue(json['condition'] as String?),
      finish: CardFinish.fromStorageValue(json['finish'] as String?),
      isSigned: json['isSigned'] == true,
      isAltered: json['isAltered'] == true,
      isProxy: json['isProxy'] == true,
      imageUrl: json['imageUrl'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  factory CollectionEntry.fromScryfallCard(
    ScryfallCardPrint card, {
    required int quantity,
    required CardCondition condition,
    required CardFinish finish,
    required bool isSigned,
    required bool isAltered,
    required bool isProxy,
    String? note,
  }) {
    final now = DateTime.now();
    return CollectionEntry(
      id: now.microsecondsSinceEpoch.toString(),
      scryfallId: card.id,
      cardName: card.name,
      setCode: card.setCode,
      collectorNumber: card.collectorNumber,
      language: card.lang,
      quantity: quantity.clamp(1, 999).toInt(),
      condition: condition,
      finish: finish,
      isSigned: isSigned,
      isAltered: isAltered,
      isProxy: isProxy,
      imageUrl: card.displayImageSmalls.isNotEmpty
          ? card.displayImageSmalls.first
          : card.displayImageNormals.isNotEmpty
              ? card.displayImageNormals.first
              : null,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }
}
