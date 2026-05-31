import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ScryfallJsonSearchUtils {
  const ScryfallJsonSearchUtils._();

  static Stream<String> readTopLevelJsonObjects(String path) async* {
    final file = File(path);
    final header = await file.openRead(0, 2).fold<List<int>>(
      <int>[],
      (previous, chunk) => previous..addAll(chunk),
    );

    Stream<List<int>> bytes = file.openRead();
    if (looksLikeGzip(header)) {
      bytes = bytes.transform(gzip.decoder);
    }

    final chars = bytes.transform(utf8.decoder);
    final buffer = StringBuffer();
    var depth = 0;
    var inString = false;
    var escaping = false;
    var capturing = false;

    await for (final chunk in chars) {
      for (var i = 0; i < chunk.length; i++) {
        final char = chunk[i];

        if (capturing) buffer.write(char);

        if (inString) {
          if (escaping) {
            escaping = false;
          } else if (char == r'\') {
            escaping = true;
          } else if (char == '"') {
            inString = false;
          }
          continue;
        }

        if (char == '"') {
          inString = true;
          continue;
        }

        if (char == '{') {
          if (!capturing) {
            capturing = true;
            buffer.clear();
            buffer.write(char);
          }
          depth++;
          continue;
        }

        if (char == '}') {
          depth--;
          if (capturing && depth == 0) {
            yield buffer.toString();
            buffer.clear();
            capturing = false;
          }
        }
      }
    }
  }

  static bool looksLikeGzip(List<int> bytes) =>
      bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;

  static bool isExtra(Map<String, dynamic> json) {
    final games = stringList(json['games']);
    if (json['digital'] == true && !games.contains('paper')) return true;

    final layout = json['layout'] as String? ?? '';
    if (extraLayouts.contains(layout)) return true;

    final typeLine = coalesceFaces(json, 'type_line').toLowerCase().trim();
    if (typeLine.contains('token') || typeLine.contains('emblem')) return true;

    final setType = json['set_type'] as String? ?? '';
    return extraSetTypes.contains(setType);
  }

  static const Set<String> extraLayouts = <String>{
    'token',
    'emblem',
    'art_series',
    'planar',
    'scheme',
    'vanguard',
  };

  static const Set<String> extraSetTypes = <String>{
    'token',
    'funny',
    'memorabilia',
    'minigame',
  };

  static String coalesceFaces(Map<String, dynamic> json, String key) {
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

  static String? coalesceNullableFaces(Map<String, dynamic> json, String key) {
    final value = coalesceFaces(json, key);
    return value.isEmpty ? null : value;
  }

  static List<String> stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList(growable: false);
  }

  static double? toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) return double.tryParse(value);
    return null;
  }

  static String normalize(String value) => value.toLowerCase().trim();
}
