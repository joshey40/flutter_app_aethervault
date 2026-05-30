class ScryfallCardPrint {
  const ScryfallCardPrint({
    required this.id,
    required this.name,
    required this.lang,
    required this.releasedAt,
    required this.setCode,
    required this.collectorNumber,
    required this.layout,
    required this.typeLine,
    required this.oracleText,
    required this.rarity,
    required this.games,
    required this.finishes,
    this.oracleId,
    this.manaCost,
    this.manaValue,
    this.colors = const <String>[],
    this.colorIdentity = const <String>[],
    this.artist,
    this.imageNormal,
    this.imageSmall,
    this.usd,
    this.eur,
  });

  final String id;
  final String? oracleId;
  final String name;
  final String lang;
  final DateTime? releasedAt;
  final String setCode;
  final String collectorNumber;
  final String layout;
  final String typeLine;
  final String oracleText;
  final String? manaCost;
  final double? manaValue;
  final List<String> colors;
  final List<String> colorIdentity;
  final String rarity;
  final List<String> games;
  final List<String> finishes;
  final String? artist;
  final String? imageNormal;
  final String? imageSmall;
  final double? usd;
  final double? eur;

  factory ScryfallCardPrint.fromJson(Map<String, dynamic> json) {
    final imageUris = json['image_uris'] is Map<String, dynamic>
        ? json['image_uris'] as Map<String, dynamic>
        : null;
    final prices = json['prices'] is Map<String, dynamic>
        ? json['prices'] as Map<String, dynamic>
        : null;

    return ScryfallCardPrint(
      id: json['id'] as String,
      oracleId: json['oracle_id'] as String?,
      name: json['name'] as String? ?? '',
      lang: json['lang'] as String? ?? 'en',
      releasedAt: DateTime.tryParse(json['released_at'] as String? ?? ''),
      setCode: json['set'] as String? ?? '',
      collectorNumber: json['collector_number'] as String? ?? '',
      layout: json['layout'] as String? ?? '',
      typeLine: _coalesceFaces(json, 'type_line'),
      oracleText: _coalesceFaces(json, 'oracle_text'),
      manaCost: _coalesceNullableFaces(json, 'mana_cost'),
      manaValue: _toDouble(json['cmc']),
      colors: _stringList(json['colors']),
      colorIdentity: _stringList(json['color_identity']),
      rarity: json['rarity'] as String? ?? '',
      games: _stringList(json['games']),
      finishes: _stringList(json['finishes']),
      artist: json['artist'] as String?,
      imageNormal: imageUris?['normal'] as String?,
      imageSmall: imageUris?['small'] as String?,
      usd: _toDouble(prices?['usd']),
      eur: _toDouble(prices?['eur']),
    );
  }

  static String _coalesceFaces(Map<String, dynamic> json, String key) {
    final direct = json[key] as String?;
    if (direct != null && direct.isNotEmpty) return direct;

    final faces = json['card_faces'];
    if (faces is! List) return '';

    return faces
        .whereType<Map<String, dynamic>>()
        .map((face) => face[key] as String? ?? '')
        .where((value) => value.isNotEmpty)
        .join('\n---\n');
  }

  static String? _coalesceNullableFaces(Map<String, dynamic> json, String key) {
    final value = _coalesceFaces(json, key);
    return value.isEmpty ? null : value;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList(growable: false);
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) return double.tryParse(value);
    return null;
  }
}
