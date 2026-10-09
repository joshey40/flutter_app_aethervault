import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class ScryfallSymbol {
  const ScryfallSymbol({required this.symbol, required this.svgUri});

  final String symbol;
  final String svgUri;
}

class ScryfallSymbolService {
  ScryfallSymbolService._();

  static final ScryfallSymbolService instance = ScryfallSymbolService._();

  Future<Map<String, ScryfallSymbol>>? _symbolsFuture;

  Future<Map<String, ScryfallSymbol>> loadSymbols() {
    return _symbolsFuture ??= _fetchSymbols();
  }

  Future<Map<String, ScryfallSymbol>> _fetchSymbols() async {
    final response = await http.get(
      Uri.parse('https://api.scryfall.com/symbology'),
      headers: const {
        'User-Agent': 'AetherVault/1.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Scryfall symbology request failed: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['data'] is! List) {
      throw const FormatException('Invalid Scryfall symbology response');
    }

    final symbols = <String, ScryfallSymbol>{};
    for (final item in decoded['data'] as List<dynamic>) {
      if (item is! Map) continue;
      final symbol = item['symbol'];
      final svgUri = item['svg_uri'];
      if (symbol is String && svgUri is String) {
        symbols[symbol] = ScryfallSymbol(symbol: symbol, svgUri: svgUri);
      }
    }
    return symbols;
  }
}

class ScryfallSymbolText extends StatefulWidget {
  const ScryfallSymbolText({
    required this.text,
    this.style,
    this.symbolScale = 1.2,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final double symbolScale;

  @override
  State<ScryfallSymbolText> createState() => _ScryfallSymbolTextState();
}

class _ScryfallSymbolTextState extends State<ScryfallSymbolText> {
  late Future<Map<String, ScryfallSymbol>> _symbolsFuture;

  @override
  void initState() {
    super.initState();
    _symbolsFuture = ScryfallSymbolService.instance.loadSymbols();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, ScryfallSymbol>>(
      future: _symbolsFuture,
      builder: (context, snapshot) {
        final symbols = snapshot.data;
        if (symbols == null) {
          return Text(widget.text, style: widget.style);
        }

        return RichText(
          text: TextSpan(
            style: widget.style ?? DefaultTextStyle.of(context).style,
            children: _buildSpans(symbols),
          ),
        );
      },
    );
  }

  List<InlineSpan> _buildSpans(Map<String, ScryfallSymbol> symbols) {
    final spans = <InlineSpan>[];
    final tokenPattern = RegExp(r'\{[^}]+\}');
    var lastEnd = 0;

    for (final match in tokenPattern.allMatches(widget.text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: widget.text.substring(lastEnd, match.start)));
      }

      final token = match.group(0)!;
      final symbol = symbols[token];
      if (symbol == null) {
        spans.add(TextSpan(text: token));
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SvgPicture.network(
                symbol.svgUri,
                width: _symbolSize,
                height: _symbolSize,
                placeholderBuilder: (context) =>
                    SizedBox(width: _symbolSize, height: _symbolSize),
              ),
            ),
          ),
        );
      }
      lastEnd = match.end;
    }

    if (lastEnd < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(lastEnd)));
    }
    return spans;
  }

  double get _symbolSize => (widget.style?.fontSize ?? 16) * widget.symbolScale;
}
