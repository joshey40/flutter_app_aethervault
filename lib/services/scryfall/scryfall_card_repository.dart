import 'scryfall_service.dart';

/// Query intent to data-source matrix:
/// - default mode + non-variant query => default_cards
/// - default mode + variant-sensitive query => all_cards
/// - all-printings mode => all_cards

class ScryfallCardGroup {
  ScryfallCardGroup(this.oracleId);

  final String oracleId;
  Map<String, dynamic>? oracleCard;
  Map<String, dynamic>? primaryCard;
  final Map<String, Map<String, dynamic>> _variantsById = {};

  List<Map<String, dynamic>> get variants {
    final out = _variantsById.values.toList();
    out.sort((a, b) {
      final ad = a['released_at']?.toString() ?? '';
      final bd = b['released_at']?.toString() ?? '';
      final cmp = bd.compareTo(ad);
      if (cmp != 0) return cmp;
      final as_ = a['set']?.toString() ?? '';
      final bs = b['set']?.toString() ?? '';
      if (as_ != bs) return as_.compareTo(bs);
      return (a['collector_number']?.toString() ?? '')
          .compareTo(b['collector_number']?.toString() ?? '');
    });
    return out;
  }

  Set<String> get languages => variants
      .map((card) => card['lang']?.toString() ?? '')
      .where((lang) => lang.isNotEmpty)
      .toSet();

  Set<String> get setCodes => variants
      .map((card) => card['set']?.toString() ?? '')
      .where((set) => set.isNotEmpty)
      .toSet();

  Set<String> get illustrationIds => variants
      .map((card) => card['illustration_id']?.toString() ?? '')
      .where((id) => id.isNotEmpty)
      .toSet();

  void addVariant(Map<String, dynamic> card) {
    final id = card['id']?.toString();
    if (id == null || id.isEmpty) return;
    _variantsById[id] = card;
  }
}

class ScryfallCardRepository {
  ScryfallCardRepository({required ScryfallService service}) : _service = service;

  final ScryfallService _service;
  final Map<String, ScryfallCardGroup> _groupsByOracle = {};
  final Map<String, ScryfallCardGroup> _groupsByCardId = {};

  List<Map<String, dynamic>> _oracleCards = const [];
  List<Map<String, dynamic>> _defaultCards = const [];
  List<Map<String, dynamic>> _allCards = const [];

  List<Map<String, dynamic>>? _defaultSearchCache;
  List<Map<String, dynamic>>? _allSearchCache;

  int get defaultCardsCount => _defaultCards.length;
  int get allCardsCount => _allCards.length;

  Future<void> loadBaseData() async {
    final oracleRaw =
        await _service.loadLocalBulkType(bulkType: ScryfallBulkType.oracleCards) ??
            [];
    final defaultRaw =
        await _service.loadLocalBulkType(bulkType: ScryfallBulkType.defaultCards) ??
            [];
    final allRaw =
        await _service.loadLocalBulkType(bulkType: ScryfallBulkType.allCards) ??
            [];
    _oracleCards = _castCards(oracleRaw);
    _defaultCards = _castCards(defaultRaw);
    _allCards = _castCards(allRaw);
    _rebuildIndex();
  }

  List<Map<String, dynamic>> defaultSearchCards() {
    return _defaultSearchCache ??= _defaultCards.map(_enrichCard).toList();
  }

  List<Map<String, dynamic>> allSearchCards() {
    return _allSearchCache ??= _allCards.map(_enrichCard).toList();
  }

  ScryfallCardGroup? groupForCard(Map<String, dynamic> card) {
    final cardId = card['id']?.toString();
    if (cardId != null && cardId.isNotEmpty) {
      return _groupsByCardId[cardId];
    }
    final oracleId = card['oracle_id']?.toString();
    if (oracleId != null && oracleId.isNotEmpty) {
      return _groupsByOracle[oracleId];
    }
    return null;
  }

  void _rebuildIndex() {
    _defaultSearchCache = null;
    _allSearchCache = null;
    _groupsByOracle.clear();
    _groupsByCardId.clear();

    for (final card in _oracleCards) {
      final oracleId = card['oracle_id']?.toString();
      if (oracleId == null || oracleId.isEmpty) continue;
      final group = _groupsByOracle.putIfAbsent(
        oracleId,
        () => ScryfallCardGroup(oracleId),
      );
      group.oracleCard = card;
    }

    for (final card in _defaultCards) {
      final oracleId = _oracleIdFor(card);
      if (oracleId == null) continue;
      final group = _groupsByOracle.putIfAbsent(
        oracleId,
        () => ScryfallCardGroup(oracleId),
      );
      group.addVariant(card);
      group.primaryCard ??= card;
    }

    for (final card in _allCards) {
      final oracleId = _oracleIdFor(card);
      if (oracleId == null) continue;
      final group = _groupsByOracle.putIfAbsent(
        oracleId,
        () => ScryfallCardGroup(oracleId),
      );
      group.addVariant(card);
    }

    for (final group in _groupsByOracle.values) {
      for (final variant in group.variants) {
        final id = variant['id']?.toString();
        if (id != null && id.isNotEmpty) {
          _groupsByCardId[id] = group;
        }
      }
    }
  }

  List<Map<String, dynamic>> _castCards(List<dynamic> raw) {
    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  String? _oracleIdFor(Map<String, dynamic> card) {
    final oracleId = card['oracle_id']?.toString();
    if (oracleId != null && oracleId.isNotEmpty) return oracleId;
    return null;
  }

  Map<String, dynamic> _enrichCard(Map<String, dynamic> card) {
    final group = groupForCard(card);
    if (group == null) return card;
    final enriched = Map<String, dynamic>.from(card);
    enriched['_av_oracle_id'] = group.oracleId;
    enriched['_av_variant_count'] = group.variants.length;
    enriched['_av_set_count'] = group.setCodes.length;
    enriched['_av_illustration_count'] = group.illustrationIds.length;
    enriched['_av_languages'] = group.languages.toList();
    enriched['_av_sets'] = group.setCodes.toList();
    return enriched;
  }
}
