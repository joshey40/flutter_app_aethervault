import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'scryfall_card_print.dart';
import 'scryfall_search_repository.dart';

class ScryfallRemoteSearchDataSource implements RemoteScryfallSearchDataSource {
  ScryfallRemoteSearchDataSource({
    http.Client? client,
    Map<String, String>? headers,
    this.maxCards,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        headers = headers ??
            const <String, String>{
              'User-Agent': 'AetherVault/0.1 (https://github.com/joshey40)',
              'Accept': 'application/json',
            };

  final http.Client _client;
  final bool _ownsClient;
  final Map<String, String> headers;

  /// Optional safety cap for online fallback. Null means all Scryfall pages are
  /// loaded for the query.
  final int? maxCards;

  @override
  Future<List<ScryfallCardPrint>> search(String rawQuery) async {
    final cards = <ScryfallCardPrint>[];
    Uri? nextPage = Uri.https('api.scryfall.com', '/cards/search', <String, String>{
      'q': rawQuery,
      // Match Scryfall's user-facing default: collapse reprints into one card.
      'unique': 'cards',
    });

    while (nextPage != null && _underLimit(cards.length)) {
      final response = await _client.get(nextPage, headers: headers);
      if (response.statusCode == 404) return const <ScryfallCardPrint>[];
      if (response.statusCode != 200) {
        throw HttpException(
          'Scryfall search failed with HTTP ${response.statusCode}.',
          uri: nextPage,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        for (final item in data.whereType<Map<String, dynamic>>()) {
          cards.add(ScryfallCardPrint.fromJson(item));
          if (!_underLimit(cards.length)) break;
        }
      }

      final hasMore = body['has_more'] == true;
      final nextPageValue = body['next_page'] as String?;
      nextPage = hasMore && nextPageValue != null ? Uri.parse(nextPageValue) : null;
    }

    return cards;
  }

  bool _underLimit(int count) => maxCards == null || count < maxCards!;

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
