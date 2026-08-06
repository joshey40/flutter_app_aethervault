
import 'dart:isolate';

import 'package:drift/drift.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'database.dart';
import 'scryfall_download.dart';

class ParserProgress {
  final int current;
  final int total;
  final String? currentType;
  final int? cardsParsed;
  final bool isRunning;

  ParserProgress({
    required this.current,
    required this.total,
    this.currentType,
    this.cardsParsed,
    required this.isRunning,
  });
}

class _ParseChunkArgs {
  final List<String> lines;
  final List<String> langs;
  _ParseChunkArgs(this.lines, this.langs);
}

class _ParseChunkResult {
  final List<ScryfallCardsCompanion> cards;
  final List<ScryfallCardFacesCompanion> faces;
  final int parsedCount;
  _ParseChunkResult(this.cards, this.faces, this.parsedCount);
}

class ScryfallDataParser {
  ScryfallDataParser({
    AppDatabase? database,
    ScryfallDownloadService? downloadService,
  })  : _database = database ?? AppDatabase(),
        _downloadService = downloadService ?? ScryfallDownloadService();

  final AppDatabase _database;
  final ScryfallDownloadService _downloadService;

  static const Set<String> _cardBulkTypes = {
    'all_cards',
    'oracle_cards',
  };

  final _progressController = StreamController<ParserProgress>.broadcast();

  Stream<ParserProgress> get progressStream => _progressController.stream;

  Future<void> parseAllCardData() async {
    // By default, parse only "all_cards", which contains all card data.
    // For testing only parse german and english cards (add Setting later)
    _progressController.add(ParserProgress(current: 0, total: 1, isRunning: true));
    await parseBulkData('all_cards', ['en','de']);
    _progressController.add(ParserProgress(current: 1, total: 1, isRunning: false));
  }

  Future<void> parseBulkData(String bulkDataType, List<String> langs) async {
  if (!_cardBulkTypes.contains(bulkDataType)) {
    throw ArgumentError.value(
      bulkDataType,
      'bulkDataType',
      'Only card bulk data types can be parsed into the card database',
    );
  }

  final bulkDataFilePath = await _downloadService.getBulkDataFilePath(bulkDataType);
  final bulkDataFile = File(bulkDataFilePath);
  if (!await bulkDataFile.exists()) {
    throw StateError('Bulk data file not found: $bulkDataFilePath');
  }

  const chunkSize = 5000;
  var parsedCount = 0;

  _progressController.add(
    ParserProgress(cardsParsed: 0, currentType: bulkDataType, isRunning: true, current: 1, total: 1),
  );

  await _database.transaction(() async {
    await _database.delete(_database.scryfallCardFaces).go();
    await _database.delete(_database.scryfallCards).go();

    Future<_ParseChunkResult>? pendingParse;

    Future<void> awaitAndFlushPending() async {
      if (pendingParse == null) return;
      final result = await pendingParse!;
      pendingParse = null;
      await _flushBatch(result.cards, result.faces);
      parsedCount += result.parsedCount;
      _progressController.add(
        ParserProgress(
          cardsParsed: parsedCount,
          currentType: bulkDataType,
          isRunning: true,
          current: 1,
          total: 1,
        ),
      );
    }

    var buffer = <String>[];
    final stream = _readBulkDataLines(bulkDataFile);

    await for (final line in stream) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        continue;
      }
      buffer.add(trimmedLine);

      if (buffer.length >= chunkSize) {
        final chunkToParse = buffer;
        buffer = <String>[];

        final newParseFuture = _spawnParseChunk(chunkToParse, langs);

        await awaitAndFlushPending();

        pendingParse = newParseFuture;
      }
    }

    if (buffer.isNotEmpty) {
      final chunkToParse = buffer;
      final newParseFuture = _spawnParseChunk(chunkToParse, langs);
      await awaitAndFlushPending();
      pendingParse = newParseFuture;
    }

    await awaitAndFlushPending();
  });

  _progressController.add(
    ParserProgress(cardsParsed: parsedCount, currentType: bulkDataType, isRunning: false, current: 1, total: 1),
  );
}
  
  Stream<String> _readBulkDataLines(File file) {
    final stream = file.openRead();
    if (file.path.endsWith('.gz')) {
      return stream.transform(gzip.decoder).transform(utf8.decoder).transform(const LineSplitter());
    }

    return stream.transform(utf8.decoder).transform(const LineSplitter());
  }

  static ScryfallCardsCompanion _mapCard(Map<String, dynamic> card, String? rawJsonStr) {
    final imageUris = _objectField(card, 'image_uris');
    final legalities = _objectField(card, 'legalities');
    final prices = _objectField(card, 'prices');
    final relatedUris = _objectField(card, 'related_uris');
    final purchaseUris = _objectField(card, 'purchase_uris');
    final allParts = _listField(card, 'all_parts');

    final colors = _stringListField(card, 'colors');
    final colorIdentity = _stringListField(card, 'color_identity');
    final producedMana = _stringListField(card, 'produced_mana');
    final keywords = _stringListField(card, 'keywords');
    final frameEffects = _stringListField(card, 'frame_effects');
    final artistIds = _stringListField(card, 'artist_ids');
    final multiverseIds = _dynamicListField(card, 'multiverse_ids');
    final cardFaces = _listField(card, 'card_faces');

    final hasCardFaces = cardFaces.isNotEmpty;
    final hasColorIndicator = card.containsKey('color_indicator');

    return ScryfallCardsCompanion.insert(
      scryfallId: _stringValue(card, 'id'),
      oracleId: Value(_stringField(card, 'oracle_id')),
      tcgplayerId: Value(_stringField(card, 'tcgplayer_id')),
      cardmarketId: Value(_stringField(card, 'cardmarket_id')),
      multiverseIdsJson: Value(_encodeJsonOrNull(multiverseIds)),
      
      layout: _stringValue(card, 'layout'),
      
      name: _stringValue(card, 'name'),
      printedName: Value<String?>(_stringField(card, 'printed_name')),
      
      setId: _stringValue(card, 'set_id'),
      setCode: _stringValue(card, 'set'),
      setName: _stringValue(card, 'set_name'),
      setType: _stringValue(card, 'set_type'),
      setUri: _stringValue(card, 'set_uri'),
      setSearchUri: _stringValue(card, 'set_search_uri'),
      scryfallSetUri: _stringValue(card, 'scryfall_set_uri'),
      
      collectorNumber: _stringValue(card, 'collector_number'),
      lang: _stringValue(card, 'lang'),
      rarity: _stringValue(card, 'rarity'),
      releasedAt: _stringValue(card, 'released_at'),
      
      scryfallUri: _stringValue(card, 'scryfall_uri'),
      uri: _stringValue(card, 'uri'),
      rulingsUri: _stringValue(card, 'rulings_uri'),
      printsSearchUri: _stringValue(card, 'prints_search_uri'),
      
      typeLine: _stringField(card, 'type_line') ?? '',
      printedTypeLine: Value<String?>(_stringField(card, 'printed_type_line')),
      manaCost: Value(_stringField(card, 'mana_cost')),
      cmc: _doubleValue(card, 'cmc'),
      oracleText: Value(_stringField(card, 'oracle_text')),
      printedText: Value<String?>(_stringField(card, 'printed_text')),
      flavorText: Value(_stringField(card, 'flavor_text')),
      
      colorsJson: Value(_encodeJsonOrNull(colors)),
      colorMask: _colorMask(colors),
      colorIdentityJson: Value(_encodeJsonOrNull(colorIdentity)),
      colorIdentityMask: _colorMask(colorIdentity),
      producedManaJson: Value(_encodeJsonOrNull(producedMana)),
      producedManaMask: _colorMask(producedMana),
      
      keywordsJson: Value(_encodeJsonOrNull(keywords)),
      hasCardFaces: Value(hasCardFaces),
      hasColorIndicator: Value(hasColorIndicator),
      borderColor: Value(_stringValue(card, 'border_color')),
      frame: Value(_stringValue(card, 'frame')),
      frameEffectsJson: Value(_encodeJsonOrNull(frameEffects)),
      securityStamp: Value(_stringField(card, 'security_stamp')),
      
      highresImage: Value(_boolValue(card, 'highres_image')),
      imageStatus: Value(_stringValue(card, 'image_status')),
      imageUpdatedAt: Value(_stringValue(card, 'image_updated_at')),
      imageSmall: Value(_stringField(imageUris, 'small')),
      imageNormal: Value(_stringField(imageUris, 'normal')),
      imageLarge: Value(_stringField(imageUris, 'large')),
      imagePng: Value(_stringField(imageUris, 'png')),
      imageArtCrop: Value(_stringField(imageUris, 'art_crop')),
      imageBorderCrop: Value(_stringField(imageUris, 'border_crop')),
      artist: Value(_stringValue(card, 'artist')),
      artistIdsJson: Value(_encodeJsonOrNull(artistIds)),
      illustrationId: Value(_stringField(card, 'illustration_id')),
      watermark: Value(_stringField(card, 'watermark')),
      
      fullArt: Value(_boolValue(card, 'full_art')),
      textless: Value(_boolValue(card, 'textless')),
      booster: Value(_boolValue(card, 'booster')),
      storySpotlight: Value(_boolValue(card, 'story_spotlight')),
      promo: Value(_boolValue(card, 'promo')),
      reprint: Value(_boolValue(card, 'reprint')),
      variation: Value(_boolValue(card, 'variation')),
      reserved: Value(_boolValue(card, 'reserved')),
      gameChanger: Value(_boolValue(card, 'game_changer')),
      oversized: Value(_boolValue(card, 'oversized')),
      nonfoil: Value(_boolValue(card, 'nonfoil')),
      foil: Value(_boolValue(card, 'foil')),
      etched: Value(_containsString(card, 'finishes', 'etched')),
      glossy: Value(_containsString(card, 'finishes', 'glossy')),
      paper: Value(_containsString(card, 'games', 'paper')),
      
      legalStandard: Value(_stringField(legalities, 'standard')),
      legalFuture: Value(_stringField(legalities, 'future')),
      legalHistoric: Value(_stringField(legalities, 'historic')),
      legalTimeless: Value(_stringField(legalities, 'timeless')),
      legalGladiator: Value(_stringField(legalities, 'gladiator')),
      legalPioneer: Value(_stringField(legalities, 'pioneer')),
      legalModern: Value(_stringField(legalities, 'modern')),
      legalLegacy: Value(_stringField(legalities, 'legacy')),
      legalPauper: Value(_stringField(legalities, 'pauper')),
      legalVintage: Value(_stringField(legalities, 'vintage')),
      legalPenny: Value(_stringField(legalities, 'penny')),
      legalCommander: Value(_stringField(legalities, 'commander')),
      legalOathbreaker: Value(_stringField(legalities, 'oathbreaker')),
      legalStandardBrawl: Value(_stringField(legalities, 'standardbrawl')),
      legalBrawl: Value(_stringField(legalities, 'brawl')),
      legalCompetitiveBrawl: Value(_stringField(legalities, 'competitivebrawl')),
      legalAlchemy: Value(_stringField(legalities, 'alchemy')),
      legalPauperCommander: Value(_stringField(legalities, 'paupercommander')),
      legalDuel: Value(_stringField(legalities, 'duel')),
      legalOldSchool: Value(_stringField(legalities, 'oldschool')),
      legalPremodern: Value(_stringField(legalities, 'premodern')),
      legalPredh: Value(_stringField(legalities, 'predh')),
      legalTlr: Value(_stringField(legalities, 'tlr')),
      
      pricesUsd: Value(_stringField(prices, 'usd')),
      pricesUsdFoil: Value(_stringField(prices, 'usd_foil')),
      pricesUsdEtched: Value(_stringField(prices, 'usd_etched')),
      pricesEur: Value(_stringField(prices, 'eur')),
      pricesEurFoil: Value(_stringField(prices, 'eur_foil')),
      pricesTix: Value(_stringField(prices, 'tix')),
      
      relatedGathererUri: Value(_stringField(relatedUris, 'gatherer')),
      relatedTcgplayerInfiniteArticlesUri: Value(_stringField(relatedUris, 'tcgplayer_infinite_articles')),
      relatedTcgplayerInfiniteDecksUri: Value(_stringField(relatedUris, 'tcgplayer_infinite_decks')),
      relatedEdhrecUri: Value(_stringField(relatedUris, 'edhrec')),
      
      purchaseTcgplayerUri: Value(_stringField(purchaseUris, 'tcgplayer')),
      purchaseCardmarketUri: Value(_stringField(purchaseUris, 'cardmarket')),
      purchaseCardhoarderUri: Value(_stringField(purchaseUris, 'cardhoarder')),
      
      cardBackId: Value(_stringField(card, 'card_back_id')),
      allPartsJson: Value(_encodeJsonOrNull(allParts)),
      
      rawJson: rawJsonStr ?? jsonEncode(card)
    );
  }

  static List<ScryfallCardFacesCompanion> _mapFaces(Map<String, dynamic> card) {
    final cardFaces = _listField(card, 'card_faces');
    if (cardFaces.isEmpty) {
      return const <ScryfallCardFacesCompanion>[];
    }

    return [
      for (var index = 0; index < cardFaces.length; index++)
        if (cardFaces[index] is Map)
          _mapFace(
            cardId: _stringValue(card, 'id'),
            faceIndex: index,
            face: cardFaces[index].cast<String, dynamic>(),
          ),
    ];
  }

  static ScryfallCardFacesCompanion _mapFace({
    required String cardId,
    required int faceIndex,
    required Map<String, dynamic> face,
  }) {
    final imageUris = _objectField(face, 'image_uris');
    final colors = _stringListField(face, 'colors');
    final colorIndicator = _stringListField(face, 'color_indicator');

    return ScryfallCardFacesCompanion.insert(
      cardId: cardId,
      faceIndex: faceIndex,
      
      name: _stringValue(face, 'name'),
      printedName: Value<String?>(_stringField(face, 'printed_name')),
      manaCost: Value(_stringField(face, 'mana_cost')),
      typeLine: Value(_stringField(face, 'type_line')),
      printedTypeLine: Value<String?>(_stringField(face, 'printed_type_line')),
      oracleText: Value(_stringValue(face, 'oracle_text')),
      printedText: Value<String?>(_stringField(face, 'printed_text')),
      flavorText: Value(_stringField(face, 'flavor_text')),
      
      colorsJson: Value(_encodeJsonOrNull(colors)),
      colorMask: _colorMask(colors),
      colorIndicatorJson: Value(_encodeJsonOrNull(colorIndicator)),
      colorIndicatorMask: _colorMask(colorIndicator),
      
      power: Value(_stringField(face, 'power')),
      toughness: Value(_stringField(face, 'toughness')),
      loyalty: Value(_stringField(face, 'loyalty')),
      defense: Value(_stringField(face, 'defense')),
      cmc: Value(_doubleValue(face, 'cmc')),
      
      artist: Value(_stringField(face, 'artist')),
      artistId: Value(_stringField(face, 'artist_id')),
      illustrationId: Value(_stringField(face, 'illustration_id')),
      highresImage: Value(_boolValue(face, 'highres_image')),
      imageStatus: Value(_stringField(face, 'image_status')),
      imageSmall: Value(_stringField(imageUris, 'small')),
      imageNormal: Value(_stringField(imageUris, 'normal')),
      imageLarge: Value(_stringField(imageUris, 'large')),
      imagePng: Value(_stringField(imageUris, 'png')),
      imageArtCrop: Value(_stringField(imageUris, 'art_crop')),
      imageBorderCrop: Value(_stringField(imageUris, 'border_crop')),
      watermark: Value(_stringField(face, 'watermark')),
      
      rawJson: jsonEncode(face),
    );
  }

  Future<void> _flushBatch(
    List<ScryfallCardsCompanion> cards,
    List<ScryfallCardFacesCompanion> faces,
  ) async {
    if (cards.isEmpty && faces.isEmpty) {
      return;
    }

    final cardsToInsert = List<ScryfallCardsCompanion>.from(cards);
    final facesToInsert = List<ScryfallCardFacesCompanion>.from(faces);
    cards.clear();
    faces.clear();

    await _database.batch((batch) {
      for (final card in cardsToInsert) {
        batch.insert(
          _database.scryfallCards,
          card,
          mode: InsertMode.insertOrReplace,
        );
      }

      for (final face in facesToInsert) {
        batch.insert(
          _database.scryfallCardFaces,
          face,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  static Future<_ParseChunkResult> _spawnParseChunk(List<String> lines, List<String> langs) {
    return Isolate.run(() => _parseChunk(_ParseChunkArgs(lines, langs)));
  }
  
  static _ParseChunkResult _parseChunk(_ParseChunkArgs args) {
  final cards = <ScryfallCardsCompanion>[];
  final faces = <ScryfallCardFacesCompanion>[];
  var parsedCount = 0;

  for (final trimmedLine in args.lines) {
    final decoded = json.decode(trimmedLine);
    if (decoded is! Map) {
      throw FormatException('Expected one JSON object per line');
    }

    final record = decoded.cast<String, dynamic>();
    if (_boolValue(record, 'digital')) {
      continue;
    }
    if (args.langs.isNotEmpty && !args.langs.contains(record['lang'])) {
      continue;
    }

    parsedCount++;
    cards.add(_mapCard(record, trimmedLine));
    faces.addAll(_mapFaces(record));
  }

  return _ParseChunkResult(cards, faces, parsedCount);
}

  static Map<String, dynamic>? _objectField(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is Map ? value.cast<String, dynamic>() : null;
  }

  static List<dynamic> _listField(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is List ? value : const <dynamic>[];
  }

  static List<String> _stringListField(Map<String, dynamic> source, String key) {
    return _listField(source, key).map((value) => value.toString()).toList(growable: false);
  }

  static List<String> _dynamicListField(Map<String, dynamic> source, String key) {
    return _stringListField(source, key);
  }

  static String _stringValue(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value == null) {
      throw FormatException('Missing required Scryfall field: $key');
    }
    return value.toString();
  }

  static String? _stringField(Map<String, dynamic>? source, String key) {
    final value = source?[key];
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static double _doubleValue(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static bool _boolValue(Map<String, dynamic> source, String key) {
    return source[key] == true;
  }

  static bool _containsString(Map<String, dynamic> source, String key, String expected) {
    final values = _stringListField(source, key);
    return values.contains(expected);
  }

  static Value<int> _colorMask(List<String> colors) {
    var mask = 0;
    for (final color in colors) {
      switch (color) {
        case 'W':
          mask |= 1;
          break;
        case 'U':
          mask |= 2;
          break;
        case 'B':
          mask |= 4;
          break;
        case 'R':
          mask |= 8;
          break;
        case 'G':
          mask |= 16;
          break;
      }
    }
    return Value(mask);
  }

  static String? _encodeJsonOrNull(Object? value) {
    if (value == null) {
      return null;
    }
    return jsonEncode(value);
  }

  void dispose() {
    _progressController.close();
  }
}