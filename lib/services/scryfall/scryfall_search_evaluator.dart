import 'scryfall_search_filter.dart';
import 'scryfall_search_json_utils.dart';

class ScryfallSearchEvaluator {
  const ScryfallSearchEvaluator._();

  static bool matchesQuery(Map<String, dynamic> json, ParsedScryfallSearch query) {
    for (final filter in query.filters) {
      final matches = matchesFilter(json, filter);
      if (filter.negated ? matches : !matches) return false;
    }
    return true;
  }

  static bool matchesFilter(Map<String, dynamic> json, ScryfallSearchFilter filter) {
    switch (filter.canonicalKeyword) {
      case 'name':
        return compareText(jsonText(json, 'name'), filter.normalizedValue, filter.operator);
      case 'type':
        return compareText(coalesceFaces(json, 'type_line'), filter.normalizedValue, filter.operator);
      case 'oracle':
        return compareText(coalesceFaces(json, 'oracle_text'), filter.normalizedValue, filter.operator);
      case 'flavor':
        return compareText(coalesceFaces(json, 'flavor_text'), filter.normalizedValue, filter.operator);
      case 'artist':
        return compareText(jsonText(json, 'artist'), filter.normalizedValue, filter.operator);
      case 'mana':
        return compareText(jsonText(json, 'mana_cost'), normalizeMana(filter.value), filter.operator);
      case 'set':
        return compareText(jsonText(json, 'set'), filter.normalizedValue, filter.operator);
      case 'setName':
        return compareText(jsonText(json, 'set_name'), filter.normalizedValue, filter.operator);
      case 'setType':
        return compareText(jsonText(json, 'set_type'), filter.normalizedValue, filter.operator);
      case 'rarity':
        return compareRarity(jsonText(json, 'rarity'), filter.normalizedValue, filter.operator);
      case 'lang':
        return compareText(jsonText(json, 'lang'), filter.normalizedValue, filter.operator);
      case 'collectorNumber':
        return compareText(jsonText(json, 'collector_number'), filter.normalizedValue, filter.operator);
      case 'artistId':
        return compareText(jsonText(json, 'artist_id'), filter.normalizedValue, filter.operator);
      case 'border':
        return compareText(jsonText(json, 'border_color'), filter.normalizedValue, filter.operator);
      case 'frame':
        return compareText(jsonText(json, 'frame'), filter.normalizedValue, filter.operator);
      case 'layout':
        return compareText(jsonText(json, 'layout'), filter.normalizedValue, filter.operator);
      case 'game':
        return stringList(json['games']).map(ScryfallJsonSearchUtils.normalize).contains(filter.normalizedValue);
      case 'colors':
        return compareColorSet(stringList(json['colors']), filter.normalizedValue, filter.operator);
      case 'identity':
        return compareColorSet(stringList(json['color_identity']), filter.normalizedValue, filter.operator);
      case 'producedMana':
        return compareColorSet(stringList(json['produced_mana']), filter.normalizedValue, filter.operator);
      case 'manaValue':
        return compareNumber(ScryfallJsonSearchUtils.toDouble(json['cmc']), filter.value, filter.operator);
      case 'power':
        return compareNumber(parseFlexibleNumber(coalesceFaces(json, 'power')), filter.value, filter.operator);
      case 'toughness':
        return compareNumber(parseFlexibleNumber(coalesceFaces(json, 'toughness')), filter.value, filter.operator);
      case 'loyalty':
        return compareNumber(parseFlexibleNumber(coalesceFaces(json, 'loyalty')), filter.value, filter.operator);
      case 'defense':
        return compareNumber(parseFlexibleNumber(coalesceFaces(json, 'defense')), filter.value, filter.operator);
      case 'usd':
        return compareNumber(price(json, 'usd'), filter.value, filter.operator);
      case 'eur':
        return compareNumber(price(json, 'eur'), filter.value, filter.operator);
      case 'tix':
        return compareNumber(price(json, 'tix'), filter.value, filter.operator);
      case 'year':
        return compareNumber(releasedYear(json), filter.value, filter.operator);
      case 'date':
        return compareDate(json['released_at'] as String? ?? '', filter.value, filter.operator);
      case 'legal':
      case 'banned':
      case 'restricted':
        return matchesLegality(json, filter.canonicalKeyword, filter.normalizedValue);
      case 'is':
        return matchesIs(json, filter.normalizedValue);
      case 'in':
        return matchesIn(json, filter.normalizedValue);
      default:
        throw UnsupportedError('Local search does not support "${filter.keyword}" yet.');
    }
  }

  static String jsonText(Map<String, dynamic> json, String key) =>
      ScryfallJsonSearchUtils.normalize(json[key] as String? ?? '');

  static String coalesceFaces(Map<String, dynamic> json, String key) =>
      ScryfallJsonSearchUtils.normalize(ScryfallJsonSearchUtils.coalesceFaces(json, key));

  static List<String> stringList(Object? value) => ScryfallJsonSearchUtils.stringList(value);

  static String normalizeMana(String value) =>
      ScryfallJsonSearchUtils.normalize(value).replaceAll(RegExp(r'[^a-z0-9/{}]'), '');

  static double? price(Map<String, dynamic> json, String key) {
    final prices = json['prices'];
    if (prices is! Map<String, dynamic>) return null;
    return ScryfallJsonSearchUtils.toDouble(prices[key]);
  }

  static double? releasedYear(Map<String, dynamic> json) {
    final releasedAt = DateTime.tryParse(json['released_at'] as String? ?? '');
    return releasedAt?.year.toDouble();
  }

  static double? parseFlexibleNumber(String value) {
    final normalized = ScryfallJsonSearchUtils.normalize(value);
    if (normalized.isEmpty || normalized == '*' || normalized == 'x') return null;
    return double.tryParse(normalized);
  }

  static bool compareText(String normalizedActual, String expected, String operator) {
    switch (operator) {
      case ':':
        return normalizedActual.contains(expected);
      case '=':
        return normalizedActual == expected;
      case '!=':
        return normalizedActual != expected;
      default:
        throw UnsupportedError('Text operator "$operator" is not supported locally.');
    }
  }

  static bool compareDate(String actual, String expected, String operator) {
    final actualDate = DateTime.tryParse(actual);
    final expectedDate = DateTime.tryParse(expected);
    if (actualDate == null || expectedDate == null) return false;
    switch (operator) {
      case ':':
      case '=':
        return _sameDay(actualDate, expectedDate);
      case '!=':
        return !_sameDay(actualDate, expectedDate);
      case '<':
        return actualDate.isBefore(expectedDate);
      case '<=':
        return actualDate.isBefore(expectedDate) || _sameDay(actualDate, expectedDate);
      case '>':
        return actualDate.isAfter(expectedDate);
      case '>=':
        return actualDate.isAfter(expectedDate) || _sameDay(actualDate, expectedDate);
      default:
        return false;
    }
  }

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static bool compareNumber(double? actual, String expected, String operator) {
    if (actual == null) return false;
    final parsed = double.tryParse(expected);
    if (parsed == null) return false;

    switch (operator) {
      case ':':
      case '=':
        return actual == parsed;
      case '!=':
        return actual != parsed;
      case '<':
        return actual < parsed;
      case '<=':
        return actual <= parsed;
      case '>':
        return actual > parsed;
      case '>=':
        return actual >= parsed;
      default:
        return false;
    }
  }

  static bool compareRarity(String actual, String expected, String operator) {
    final actualRank = rarityRank(actual);
    final expectedRank = rarityRank(expected);
    if (actualRank == null || expectedRank == null) return compareText(actual, expected, operator);
    switch (operator) {
      case ':':
      case '=':
        return actualRank == expectedRank;
      case '!=':
        return actualRank != expectedRank;
      case '<':
        return actualRank < expectedRank;
      case '<=':
        return actualRank <= expectedRank;
      case '>':
        return actualRank > expectedRank;
      case '>=':
        return actualRank >= expectedRank;
      default:
        return false;
    }
  }

  static int? rarityRank(String rarity) {
    switch (rarity) {
      case 'common':
      case 'c':
        return 1;
      case 'uncommon':
      case 'u':
        return 2;
      case 'rare':
      case 'r':
        return 3;
      case 'mythic':
      case 'mythic rare':
      case 'm':
        return 4;
      default:
        return null;
    }
  }

  static bool compareColorSet(List<String> actualColors, String expected, String operator) {
    final actual = actualColors.map(ScryfallJsonSearchUtils.normalize).toSet();
    final expectedSet = colorSet(expected);

    switch (operator) {
      case ':':
      case '<=':
        return actual.difference(expectedSet).isEmpty;
      case '=':
        return actual.length == expectedSet.length && actual.containsAll(expectedSet);
      case '>=':
        return expectedSet.difference(actual).isEmpty;
      case '!=':
        return !(actual.length == expectedSet.length && actual.containsAll(expectedSet));
      default:
        throw UnsupportedError('Color operator "$operator" is not supported locally.');
    }
  }

  static Set<String> colorSet(String value) {
    final normalized = ScryfallJsonSearchUtils.normalize(value);
    if (normalized == 'c' || normalized == 'colorless') return const <String>{};
    return normalized.split('').where((char) => 'wubrg'.contains(char)).toSet();
  }

  static bool matchesLegality(Map<String, dynamic> json, String status, String format) {
    final legalities = json['legalities'];
    if (legalities is! Map<String, dynamic>) return false;
    return ScryfallJsonSearchUtils.normalize(legalities[format] as String? ?? '') == status;
  }

  static bool matchesIs(Map<String, dynamic> json, String value) {
    switch (value) {
      case 'multicolored':
      case 'multicolor':
        return stringList(json['colors']).length > 1;
      case 'monocolored':
      case 'monocolor':
        return stringList(json['colors']).length == 1;
      case 'colorless':
        return stringList(json['colors']).isEmpty;
      case 'paper':
        return stringList(json['games']).contains('paper');
      case 'arena':
        return stringList(json['games']).contains('arena');
      case 'mtgo':
        return stringList(json['games']).contains('mtgo');
      case 'digital':
        return !stringList(json['games']).contains('paper');
      case 'foil':
        return stringList(json['finishes']).contains('foil');
      case 'nonfoil':
        return stringList(json['finishes']).contains('nonfoil');
      case 'etched':
        return stringList(json['finishes']).contains('etched');
      case 'funny':
        return jsonText(json, 'set_type') == 'funny';
      case 'token':
        return jsonText(json, 'layout') == 'token' || coalesceFaces(json, 'type_line').contains('token');
      case 'extra':
        return ScryfallJsonSearchUtils.isExtra(json);
      case 'reserved':
        return json['reserved'] == true;
      case 'reprint':
        return json['reprint'] == true;
      case 'firstprint':
        return json['reprint'] == false;
      case 'promo':
        return json['promo'] == true;
      case 'variation':
        return json['variation'] == true;
      case 'booster':
        return json['booster'] == true;
      case 'story':
        return json['story_spotlight'] == true;
      case 'fullart':
        return json['full_art'] == true;
      case 'textless':
        return json['textless'] == true;
      case 'oversized':
        return json['oversized'] == true;
      case 'highres':
        return json['highres_image'] == true;
      case 'phyrexian':
        return jsonText(json, 'lang') == 'ph';
      case 'split':
      case 'flip':
      case 'transform':
      case 'modal':
      case 'meld':
      case 'adventure':
      case 'prototype':
        return jsonText(json, 'layout') == value;
      default:
        throw UnsupportedError('Local search does not support is:$value yet.');
    }
  }

  static bool matchesIn(Map<String, dynamic> json, String value) {
    switch (value) {
      case 'paper':
      case 'arena':
      case 'mtgo':
        return stringList(json['games']).contains(value);
      default:
        throw UnsupportedError('Local search does not support in:$value yet.');
    }
  }
}
