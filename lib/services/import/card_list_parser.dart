import '../collection/collection_enums.dart';

// =============================================================================
// Intermediate form
// =============================================================================

/// One line of an imported card list, before it is matched to a card.
///
/// Every format (CSV of Moxfield, ManaBox, Archidekt, text lists, ...) is
/// parsed into this form, so the matching and the review list only exist once.
class ImportLine {
  const ImportLine({
    required this.lineNumber,
    required this.raw,
    required this.quantity,
    this.name,
    this.setCode,
    this.collectorNumber,
    this.scryfallId,
    this.language,
    this.finish = CardFinish.nonfoil,
    this.quality = CardQuality.unknown,
    this.isProxy = false,
    this.isAltered = false,
    this.isSigned = false,
  });

  /// 1-based line in the pasted text, for messages.
  final int lineNumber;

  /// The original line.
  final String raw;

  final int quantity;
  final String? name;

  /// Lowercase Scryfall set code.
  final String? setCode;
  final String? collectorNumber;
  final String? scryfallId;

  /// Scryfall language code (en, de, ja, ...), null if not given.
  final String? language;

  final CardFinish finish;
  final CardQuality quality;
  final bool isProxy;
  final bool isAltered;
  final bool isSigned;

  ImportLine copyWith({String? name}) => ImportLine(
    lineNumber: lineNumber,
    raw: raw,
    quantity: quantity,
    name: name ?? this.name,
    setCode: setCode,
    collectorNumber: collectorNumber,
    scryfallId: scryfallId,
    language: language,
    finish: finish,
    quality: quality,
    isProxy: isProxy,
    isAltered: isAltered,
    isSigned: isSigned,
  );
}

/// A line that could not be read at all.
class ImportLineError {
  const ImportLineError({
    required this.lineNumber,
    required this.raw,
    required this.message,
  });

  final int lineNumber;
  final String raw;
  final String message;
}

class ParsedCardList {
  const ParsedCardList({
    required this.format,
    required this.lines,
    required this.errors,
  });

  /// Which parser read the text, e.g. "csv" or "text".
  final String format;
  final List<ImportLine> lines;
  final List<ImportLineError> errors;
}

// =============================================================================
// Parsers
// =============================================================================

/// Reads one format of card lists.
abstract class CardListParser {
  const CardListParser();

  /// Short name of the format.
  String get format;

  /// Whether [text] looks like this format.
  bool canParse(String text);

  ParsedCardList parse(String text);
}

/// Picks the right parser for [text] and parses it.
ParsedCardList parseCardList(String text) {
  const parsers = <CardListParser>[CsvCardListParser(), TextCardListParser()];
  for (final parser in parsers) {
    if (parser.canParse(text)) return parser.parse(text);
  }
  return const TextCardListParser().parse(text);
}

/// CSV exports of collection apps (Moxfield, ManaBox, Archidekt, Deckbox, ...).
///
/// Instead of one parser per app, columns are recognized by their names, so
/// apps with similar exports work too.
class CsvCardListParser extends CardListParser {
  const CsvCardListParser();

  @override
  String get format => 'csv';

  static const _columns = <String, Set<String>>{
    'quantity': {'count', 'quantity', 'qty', 'amount'},
    'name': {'name', 'cardname'},
    'set': {'edition', 'setcode', 'editioncode', 'set'},
    'number': {'collectornumber', 'cardnumber', 'number', 'collectorsnumber'},
    'scryfallId': {'scryfallid'},
    'finish': {'foil', 'finish', 'printing'},
    'condition': {'condition'},
    'language': {'language', 'lang'},
    'altered': {'alter', 'altered', 'alteredart'},
    'proxy': {'proxy'},
    'signed': {'signed'},
  };

  static String _normalizeHeader(String header) =>
      header.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  /// Maps our column names to their index in [header].
  static Map<String, int> _mapColumns(List<String> header) {
    final result = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final normalized = _normalizeHeader(header[i]);
      for (final entry in _columns.entries) {
        if (entry.value.contains(normalized)) {
          result.putIfAbsent(entry.key, () => i);
        }
      }
    }
    return result;
  }

  @override
  bool canParse(String text) {
    final firstLine = text
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    if (!firstLine.contains(',')) return false;
    final columns = _mapColumns(parseCsvLine(firstLine));
    return columns.containsKey('name') || columns.containsKey('scryfallId');
  }

  @override
  ParsedCardList parse(String text) {
    final rows = text.split(RegExp(r'\r?\n'));
    final lines = <ImportLine>[];
    final errors = <ImportLineError>[];

    var headerIndex = rows.indexWhere((row) => row.trim().isNotEmpty);
    if (headerIndex < 0) {
      return ParsedCardList(format: format, lines: lines, errors: errors);
    }
    final columns = _mapColumns(parseCsvLine(rows[headerIndex]));

    for (var i = headerIndex + 1; i < rows.length; i++) {
      final raw = rows[i];
      if (raw.trim().isEmpty) continue;
      final cells = parseCsvLine(raw);
      String? cell(String column) {
        final index = columns[column];
        if (index == null || index >= cells.length) return null;
        final value = cells[index].trim();
        return value.isEmpty ? null : value;
      }

      final quantityText = cell('quantity');
      final quantity = quantityText == null ? 1 : int.tryParse(quantityText);
      final name = cell('name');
      final scryfallId = cell('scryfallId');
      if (quantity == null || quantity < 1) {
        errors.add(
          ImportLineError(
            lineNumber: i + 1,
            raw: raw,
            message: 'Ungültige Anzahl: $quantityText',
          ),
        );
        continue;
      }
      if (name == null && scryfallId == null) {
        errors.add(
          ImportLineError(lineNumber: i + 1, raw: raw, message: 'Kein Name'),
        );
        continue;
      }

      lines.add(
        ImportLine(
          lineNumber: i + 1,
          raw: raw,
          quantity: quantity,
          name: name,
          setCode: cell('set')?.toLowerCase(),
          collectorNumber: cell('number'),
          scryfallId: scryfallId?.toLowerCase(),
          language: parseLanguage(cell('language')),
          finish: parseFinish(cell('finish')),
          quality: parseCondition(cell('condition')),
          isAltered: parseBool(cell('altered')),
          isProxy: parseBool(cell('proxy')),
          isSigned: parseBool(cell('signed')),
        ),
      );
    }
    return ParsedCardList(format: format, lines: lines, errors: errors);
  }
}

/// Plain text lists, one card per line, as exported by Moxfield, Archidekt,
/// MTG Arena, MTGO and others:
///
/// ```
/// 4 Lightning Bolt
/// 4x Lightning Bolt (M10) 146
/// 1 Sol Ring (CMM) 410 *F*
/// 1x Sol Ring (cmm) 410 *E* [Ramp]
/// ```
class TextCardListParser extends CardListParser {
  const TextCardListParser();

  @override
  String get format => 'text';

  static final _lineRe = RegExp(
    r'^(?:(\d+)\s*[xX]?\s+)?' // quantity
    r'(.+?)' // name
    r'(?:\s+\(([A-Za-z0-9]+)\)(?:\s+([^\s*\[\^]+))?)?' // (set) number
    r'(?:\s+\*([FfEe])\*)?' // *F* foil / *E* etched
    r'(?:\s+\[[^\]]*\])?' // [category]
    r'(?:\s+\^[^\^]*\^)?' // ^tag^
    r'\s*$',
  );

  /// `[quantity] SET NUMBER [language] [finish]`, e.g. `2 msc 211 de foil`.
  static final _printingRe = RegExp(
    r'^(?:(\d+)\s*[xX]?\s+)?' // quantity
    r'([A-Za-z0-9]{2,6})\s+' // set code
    r'(\d+[A-Za-z]*[^\s]*)' // collector number, e.g. 211, 12a, 136★
    r'((?:\s+\S+){0,2})\s*$', // language and/or finish
  );

  /// Reads a line naming a printing by set and collector number instead of
  /// the card name. Null if the line isn't in that format.
  static ImportLine? _parsePrintingLine(
    String line,
    int lineNumber,
    String raw,
  ) {
    final match = _printingRe.firstMatch(line);
    if (match == null) return null;

    String? language;
    var finish = CardFinish.nonfoil;
    for (final token in match.group(4)!.trim().split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      final lower = token.toLowerCase();
      final finishFromToken = switch (lower) {
        'foil' || 'f' || '*f*' => CardFinish.foil,
        'etched' || 'e' || '*e*' => CardFinish.etched,
        'nonfoil' || 'normal' => CardFinish.nonfoil,
        _ => null,
      };
      final languageFromToken = knownLanguage(lower);
      if (finishFromToken != null) {
        finish = finishFromToken;
      } else if (languageFromToken != null && language == null) {
        language = languageFromToken;
      } else {
        // Something else, e.g. a card name like "Forest Bear": not this format.
        return null;
      }
    }

    final quantity = int.tryParse(match.group(1) ?? '1') ?? 1;
    return ImportLine(
      lineNumber: lineNumber,
      raw: raw,
      quantity: quantity < 1 ? 1 : quantity,
      setCode: match.group(2)!.toLowerCase(),
      collectorNumber: match.group(3),
      language: language,
      finish: finish,
    );
  }

  /// Section headers of deck lists, ignored for the collection.
  static final _headerRe = RegExp(
    r'^(deck|main ?deck|mainboard|sideboard|commander|companion|maybeboard|'
    r'considering|tokens?|about|name\s.*)\s*:?$',
    caseSensitive: false,
  );

  @override
  bool canParse(String text) => true;

  @override
  ParsedCardList parse(String text) {
    final rows = text.split(RegExp(r'\r?\n'));
    final lines = <ImportLine>[];
    final errors = <ImportLineError>[];

    for (var i = 0; i < rows.length; i++) {
      final raw = rows[i];
      var line = raw.trim();
      if (line.isEmpty || line.startsWith('//') || line.startsWith('#')) {
        continue;
      }
      if (_headerRe.hasMatch(line)) continue;
      if (line.toUpperCase().startsWith('SB:')) line = line.substring(3).trim();

      final printing = _parsePrintingLine(line, i + 1, raw);
      if (printing != null) {
        lines.add(printing);
        continue;
      }

      final match = _lineRe.firstMatch(line);
      final name = match?.group(2)?.trim();
      if (match == null || name == null || name.isEmpty) {
        errors.add(
          ImportLineError(
            lineNumber: i + 1,
            raw: raw,
            message: 'Zeile nicht erkannt',
          ),
        );
        continue;
      }

      final quantity = int.tryParse(match.group(1) ?? '1') ?? 1;
      final finishMark = match.group(5)?.toUpperCase();
      lines.add(
        ImportLine(
          lineNumber: i + 1,
          raw: raw,
          quantity: quantity < 1 ? 1 : quantity,
          name: name,
          setCode: match.group(3)?.toLowerCase(),
          collectorNumber: match.group(4),
          finish: switch (finishMark) {
            'F' => CardFinish.foil,
            'E' => CardFinish.etched,
            _ => CardFinish.nonfoil,
          },
        ),
      );
    }
    return ParsedCardList(format: format, lines: lines, errors: errors);
  }
}

// =============================================================================
// Value helpers
// =============================================================================

/// Splits one CSV line into cells (quotes and "" escapes supported).
List<String> parseCsvLine(String line) {
  final cells = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        buffer.write(char);
      }
    } else if (char == '"') {
      inQuotes = true;
    } else if (char == ',') {
      cells.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  cells.add(buffer.toString());
  return cells;
}

bool parseBool(String? value) {
  final lower = value?.trim().toLowerCase();
  return lower == 'true' || lower == 'yes' || lower == '1' || lower == 'y';
}

CardFinish parseFinish(String? value) {
  final lower = value?.trim().toLowerCase() ?? '';
  if (lower.contains('etched')) return CardFinish.etched;
  if (lower.contains('foil') && !lower.contains('non')) return CardFinish.foil;
  if (lower == 'true' || lower == 'yes' || lower == '1') {
    return CardFinish.foil;
  }
  return CardFinish.nonfoil;
}

/// Our Cardmarket scale plus the TCGplayer scale most US apps use
/// (NM → Near Mint, LP → Excellent, MP → Light Played, HP → Played,
/// DMG → Poor).
CardQuality parseCondition(String? value) {
  final key = value?.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '') ?? '';
  return switch (key) {
    'm' || 'mint' => CardQuality.mint,
    'nm' || 'nearmint' => CardQuality.nearMint,
    'ex' || 'excellent' => CardQuality.excellent,
    'gd' || 'good' => CardQuality.good,
    // TCGplayer "lightly played" is better than Cardmarket "light played".
    'lp' || 'lightlyplayed' => CardQuality.excellent,
    'lightplayed' => CardQuality.lightPlayed,
    'mp' || 'moderatelyplayed' => CardQuality.lightPlayed,
    'pl' || 'played' || 'hp' || 'heavilyplayed' => CardQuality.played,
    'po' || 'poor' || 'd' || 'dmg' || 'damaged' => CardQuality.poor,
    _ => CardQuality.unknown,
  };
}

/// Maps language names and codes to Scryfall language codes.
/// The Scryfall code of a language code (en, de, jp, ...), null if [value]
/// is not a known language code. Unlike [parseLanguage], unknown values are
/// not passed through.
String? knownLanguage(String value) {
  const codes = {
    'en',
    'de',
    'fr',
    'it',
    'es',
    'sp',
    'pt',
    'ja',
    'jp',
    'ko',
    'kr',
    'ru',
    'zhs',
    'zht',
    'cs',
    'ct',
    'ph',
  };
  final lower = value.toLowerCase();
  return codes.contains(lower) ? parseLanguage(lower) : null;
}

String? parseLanguage(String? value) {
  final key = value?.trim().toLowerCase();
  if (key == null || key.isEmpty) return null;
  return switch (key) {
    'en' || 'english' => 'en',
    'de' || 'german' || 'deutsch' => 'de',
    'fr' || 'french' => 'fr',
    'it' || 'italian' => 'it',
    'es' || 'sp' || 'spanish' => 'es',
    'pt' || 'portuguese' || 'portuguese (brazil)' => 'pt',
    'ja' || 'jp' || 'japanese' => 'ja',
    'ko' || 'kr' || 'korean' => 'ko',
    'ru' || 'russian' => 'ru',
    'zhs' ||
    'cs' ||
    'zh-cn' ||
    'chinese simplified' ||
    'simplified chinese' => 'zhs',
    'zht' ||
    'ct' ||
    'zh-tw' ||
    'chinese traditional' ||
    'traditional chinese' => 'zht',
    'ph' || 'phyrexian' => 'ph',
    _ => key,
  };
}
