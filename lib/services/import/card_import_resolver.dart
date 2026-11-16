import '../card_database/database.dart';
import 'card_list_parser.dart';

/// Hints about how a line was matched.
enum ImportNote {
  /// Several printings fit, the newest normal one was taken.
  ambiguousPrinting,

  /// The language isn't in the local Scryfall data, English was taken.
  languageFallback,

  /// No card fits the line.
  notFound,
}

/// A parsed line and the card it was matched to. Can be changed in the
/// review list before importing.
class ResolvedImportLine {
  ResolvedImportLine({required this.line, this.card, Set<ImportNote>? notes})
    : notes = notes ?? {};

  ImportLine line;
  ScryfallCard? card;
  final Set<ImportNote> notes;

  /// The user chose not to import this line.
  bool skip = false;

  bool get isCertain => card != null && notes.isEmpty;
  bool get willImport => card != null && !skip;
}

/// Matches parsed card list lines to printings in the local Scryfall data.
///
/// From most to least certain: Scryfall ID → set + collector number →
/// set + name → name only (newest normal printing, marked as ambiguous).
class CardImportResolver {
  const CardImportResolver(this._database);

  final AppDatabase _database;

  /// Layouts and set types that are not "normal" cards to own.
  static const _specialLayouts = {
    'token',
    'double_faced_token',
    'emblem',
    'art_series',
    'vanguard',
  };
  static const _specialSetTypes = {'memorabilia', 'promo', 'funny', 'token'};

  /// Set types of regular products. Name-only lines prefer these over special
  /// products like Secret Lair (box) or From the Vault.
  static const _regularSetTypes = {
    'core',
    'expansion',
    'masters',
    'draft_innovation',
    'commander',
    'starter',
    'duel_deck',
    'planechase',
    'archenemy',
  };

  Future<List<ResolvedImportLine>> resolve(List<ImportLine> lines) async {
    final byId = await _database.getCardsByIds([
      for (final line in lines)
        if (line.scryfallId != null) line.scryfallId!,
    ]);
    final bySetNumber = <(String, String), List<ScryfallCard>>{};
    for (final card in await _database.findCardsBySetAndNumber([
      for (final line in lines)
        if (line.setCode != null && line.collectorNumber != null)
          (line.setCode!, line.collectorNumber!),
    ])) {
      bySetNumber
          .putIfAbsent((card.setCode, card.collectorNumber), () => [])
          .add(card);
    }
    final byName = <String, List<ScryfallCard>>{};
    for (final card in await _database.findCardsByNames([
      for (final line in lines)
        if (line.name != null) line.name!,
    ])) {
      for (final key in _nameKeys(card)) {
        byName.putIfAbsent(key, () => []).add(card);
      }
    }

    return [
      for (final line in lines) _resolveLine(line, byId, bySetNumber, byName),
    ];
  }

  /// Resolves a single line again, e.g. after the user corrected the name.
  Future<ResolvedImportLine> resolveOne(ImportLine line) async =>
      (await resolve([line])).single;

  static Set<String> _nameKeys(ScryfallCard card) {
    final name = card.name.toLowerCase();
    return {
      name,
      if (name.contains(' // ')) name.substring(0, name.indexOf(' // ')),
      if (card.printedName != null) card.printedName!.toLowerCase(),
    };
  }

  ResolvedImportLine _resolveLine(
    ImportLine line,
    Map<String, ScryfallCard> byId,
    Map<(String, String), List<ScryfallCard>> bySetNumber,
    Map<String, List<ScryfallCard>> byName,
  ) {
    final language = line.language ?? 'en';

    final idMatch = line.scryfallId == null ? null : byId[line.scryfallId];
    if (idMatch != null) return ResolvedImportLine(line: line, card: idMatch);

    if (line.setCode != null && line.collectorNumber != null) {
      final candidates =
          bySetNumber[(line.setCode!, line.collectorNumber!)] ?? const [];
      if (candidates.isNotEmpty) {
        return _pick(line, candidates, language, ambiguousIfMany: false);
      }
    }

    final named = line.name == null
        ? const <ScryfallCard>[]
        : byName[line.name!.toLowerCase()] ?? const <ScryfallCard>[];

    if (line.setCode != null) {
      final inSet = named
          .where((card) => card.setCode == line.setCode)
          .toList();
      if (inSet.isNotEmpty) {
        return _pick(line, inSet, language, ambiguousIfMany: true);
      }
    }

    if (named.isNotEmpty) {
      final normal = named.where(_isNormal).toList();
      final regular = normal
          .where((card) => _regularSetTypes.contains(card.setType))
          .toList();
      return _pick(
        line,
        regular.isNotEmpty
            ? regular
            : normal.isNotEmpty
            ? normal
            : named,
        language,
        ambiguousIfMany: true,
        allMatches: named,
      );
    }

    return ResolvedImportLine(line: line, notes: {ImportNote.notFound});
  }

  /// Takes the newest printing in [language] (or English, with a hint).
  ResolvedImportLine _pick(
    ImportLine line,
    List<ScryfallCard> candidates,
    String language, {
    required bool ambiguousIfMany,
    List<ScryfallCard>? allMatches,
  }) {
    final notes = <ImportNote>{};
    var pool = candidates.where((card) => card.lang == language).toList();
    if (pool.isEmpty) {
      pool = candidates.where((card) => card.lang == 'en').toList();
      if (language != 'en') notes.add(ImportNote.languageFallback);
    }
    if (pool.isEmpty) pool = candidates;

    pool.sort(_newestFirst);
    final chosen = pool.first;
    // Count every printing the line could have meant, also the ones that
    // were not preferred (e.g. Secret Lair), in the chosen language.
    final printings = (allMatches ?? pool)
        .where((card) => card.lang == chosen.lang)
        .map((card) => card.scryfallId)
        .toSet();
    if (ambiguousIfMany && printings.length > 1) {
      notes.add(ImportNote.ambiguousPrinting);
    }
    return ResolvedImportLine(line: line, card: chosen, notes: notes);
  }

  static bool _isNormal(ScryfallCard card) =>
      !card.promo &&
      !_specialLayouts.contains(card.layout) &&
      !_specialSetTypes.contains(card.setType);

  /// Newest release first; within a set the lowest collector number (the
  /// regular version before showcase / borderless variants).
  static int _newestFirst(ScryfallCard a, ScryfallCard b) {
    final released = b.releasedAt.compareTo(a.releasedAt);
    if (released != 0) return released;
    final numberA = int.tryParse(
      RegExp(r'\d+').stringMatch(a.collectorNumber) ?? '',
    );
    final numberB = int.tryParse(
      RegExp(r'\d+').stringMatch(b.collectorNumber) ?? '',
    );
    if (numberA != null && numberB != null && numberA != numberB) {
      return numberA.compareTo(numberB);
    }
    return a.collectorNumber.compareTo(b.collectorNumber);
  }
}
