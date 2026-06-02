import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ScryfallSymbol {
  const ScryfallSymbol({
    required this.symbol,
    required this.svgUri,
    required this.english,
    required this.representsMana,
    required this.appearsInManaCosts,
    required this.colors,
  });

  final String symbol;
  final Uri? svgUri;
  final String english;
  final bool representsMana;
  final bool appearsInManaCosts;
  final List<String> colors;

  factory ScryfallSymbol.fromJson(Map<String, dynamic> json) {
    return ScryfallSymbol(
      symbol: json['symbol'] as String? ?? '',
      svgUri: Uri.tryParse(json['svg_uri'] as String? ?? ''),
      english: json['english'] as String? ?? '',
      representsMana: json['represents_mana'] == true,
      appearsInManaCosts: json['appears_in_mana_costs'] == true,
      colors: (json['colors'] as List<dynamic>? ?? const <dynamic>[]).whereType<String>().toList(growable: false),
    );
  }
}

class ScryfallSymbologyService {
  ScryfallSymbologyService({
    http.Client? client,
    Map<String, String>? headers,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _headers = headers ??
            const <String, String>{
              'User-Agent': 'AetherVault/0.1 (https://github.com/joshey40)',
              'Accept': 'application/json',
            };

  final http.Client _client;
  final bool _ownsClient;
  final Map<String, String> _headers;
  Map<String, ScryfallSymbol>? _cachedSymbols;

  Future<Map<String, ScryfallSymbol>> loadSymbols() async {
    final cached = _cachedSymbols;
    if (cached != null) return cached;

    final uri = Uri.https('api.scryfall.com', '/symbology');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw HttpException('Scryfall symbology failed with HTTP ${response.statusCode}.', uri: uri);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is! List) return const <String, ScryfallSymbol>{};

    final symbols = <String, ScryfallSymbol>{};
    for (final item in data.whereType<Map<String, dynamic>>()) {
      final symbol = ScryfallSymbol.fromJson(item);
      if (symbol.symbol.isNotEmpty) {
        symbols[symbol.symbol] = symbol;
      }
    }

    _cachedSymbols = symbols;
    return symbols;
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
