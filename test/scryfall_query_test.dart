import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_aethervault/services/card_database/scryfall_query.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('tokenizeScryfallSyntax', () {
    test('parses a simple filter', () {
      final tokens = tokenizeScryfallSyntax('type:creature');

      expect(tokens, hasLength(1));
      final token = tokens.single as FilterToken;

      expect(token.key, 'type');
      expect(token.op, FilterOp.contains);
      expect(token.value, 'creature');
      expect(token.isNegated, isFalse);
    });

    test('parses all comparison operators', () {
      final tokens = tokenizeScryfallSyntax(
        'cmc:3 cmc=4 cmc!=5 cmc>6 cmc>=7 cmc<8 cmc<=9',
      );

      expect(tokens, hasLength(7));

      final expected = [
        FilterOp.contains,
        FilterOp.eq,
        FilterOp.ne,
        FilterOp.gt,
        FilterOp.gte,
        FilterOp.lt,
        FilterOp.lte,
      ];

      for (var i = 0; i < tokens.length; i++) {
        expect((tokens[i] as FilterToken).op, expected[i]);
      }
    });

    test('treats adjacent filters as AND', () {
      final tokens = tokenizeScryfallSyntax('type:creature color:red');

      expect(tokens, hasLength(2));
      expect((tokens[0] as FilterToken).key, 'type');
      expect((tokens[1] as FilterToken).key, 'color');
    });

    test('parses OR expressions', () {
      final tokens = tokenizeScryfallSyntax(
        'type:creature OR type:instant',
      );

      expect(tokens, hasLength(1));
      final list = tokens.single as ListToken;

      expect(list.isOR, isTrue);
      expect(list.tokens, hasLength(2));
    });

    test('respects parentheses', () {
      final tokens = tokenizeScryfallSyntax(
        '(type:creature OR type:instant) color:red',
      );

      expect(tokens, hasLength(2));

      final alternatives = tokens[0] as ListToken;
      expect(alternatives.isOR, isTrue);
      expect(alternatives.tokens, hasLength(2));

      final color = tokens[1] as FilterToken;
      expect(color.key, 'color');
      expect(color.value, 'red');
    });

    test('parses negated filters', () {
      final tokens = tokenizeScryfallSyntax('-type:creature');

      final token = tokens.single as FilterToken;

      expect(token.key, 'type');
      expect(token.isNegated, isTrue);
    });

    test('parses negated parenthesized expressions', () {
      final tokens = tokenizeScryfallSyntax(
        '-(type:creature OR type:instant)',
      );

      final token = tokens.single as ListToken;

      expect(token.isOR, isTrue);
      expect(token.isNegated, isTrue);
    });

    test('keeps quoted values together', () {
      final tokens = tokenizeScryfallSyntax(
        'name:"Lightning Bolt"',
      );

      final token = tokens.single as FilterToken;

      expect(token.key, 'name');
      expect(token.value, 'Lightning Bolt');
    });

    test('treats a bare value as a name filter', () {
      final tokens = tokenizeScryfallSyntax('Lightning');

      final token = tokens.single as FilterToken;

      expect(token.key, 'name');
      expect(token.op, FilterOp.contains);
      expect(token.value, 'Lightning');
    });

    test('returns an empty list for an empty query', () {
      expect(tokenizeScryfallSyntax('   '), isEmpty);
    });

    test('treats an invalid filter as a name search', () {
      final tokens = tokenizeScryfallSyntax('type:');

      expect(tokens, hasLength(1));

      final token = tokens.single as FilterToken;
      expect(token.key, 'name');
      expect(token.op, FilterOp.contains);
      expect(token.value, 'type:');
    });

    test('rejects unmatched parentheses', () {
      expect(
        () => tokenizeScryfallSyntax('(type:creature'),
        throwsFormatException,
      );
    });
  });

  group('query helper functions', () {
    test('detects language filters', () {
      final tokens = tokenizeScryfallSyntax('type:creature lang:de');

      expect(containsLangFilter(tokens), isTrue);
    });

    test('detects type filters only when they are not negated', () {
      expect(
        containsTypeFilter(tokenizeScryfallSyntax('-type:creature')),
        isFalse,
      );
      expect(
        containsTypeFilter(tokenizeScryfallSyntax('type:creature')),
        isTrue,
      );
    });

    test('detects set filters only when they are not negated', () {
      expect(
        containsSetFilter(tokenizeScryfallSyntax('-set:abc')),
        isFalse,
      );
      expect(
        containsSetFilter(tokenizeScryfallSyntax('set:abc')),
        isTrue,
      );
    });

    test('collects Oracle Tag lookups', () {
      final tokens = tokenizeScryfallSyntax(
        'otag:draw function:ramp is:frenchvanilla',
      );

      expect(
        collectOracleTagLookups(tokens),
        containsAll(['draw', 'ramp', 'french-vanilla']),
      );
    });

    test('collects Illustration Tag lookups', () {
      final tokens = tokenizeScryfallSyntax(
        'art:dragon atag:angel',
      );

      expect(
        collectIllustrationTagLookups(tokens),
        containsAll(['dragon', 'angel']),
      );
    });
  });
}
