import 'package:material_ui/material_ui.dart';

import '../../../services/collection/collection_enums.dart';
import '../../../services/localization_service.dart';

/// Translates [key] and fills in `{name}` placeholders from [args].
String tr(String key, [Map<String, Object> args = const {}]) {
  var text = appLocalizations.translate(key);
  args.forEach((name, value) => text = text.replaceAll('{$name}', '$value'));
  return text;
}

String boardLabel(FolderType board) => tr('collection.board.${board.name}');

String finishLabel(CardFinish finish) => tr('collection.finish.${finish.name}');

String qualityLabel(CardQuality quality) =>
    tr('collection.quality.${quality.name}');

String qualityShort(CardQuality quality) =>
    tr('collection.quality_short.${quality.name}');

/// Name shown for the implicit root folder.
String get rootFolderLabel => tr('nav.collection');

/// Colors a user can give a box or deck, stored as hex strings.
const folderColors = <String>[
  '#D6B27F',
  '#D98A6C',
  '#E0C068',
  '#86B07F',
  '#8FB5D9',
  '#B39DDB',
  '#D48FB1',
  '#8A9099',
];

Color? parseFolderColor(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
  final value = int.tryParse(hex.substring(1), radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// Formats a deck can have. Keys match `card_detail.formats`.
const deckFormats = <String>[
  'commander',
  'standard',
  'pioneer',
  'modern',
  'legacy',
  'vintage',
  'pauper',
  'oathbreaker',
  'brawl',
];

String formatLabel(String format) => tr('card_detail.formats.$format');

/// The icon used for a box or deck.
IconData folderIcon(FolderType type, {bool filled = false}) {
  if (type == FolderType.deck) {
    return filled ? Icons.space_dashboard : Icons.space_dashboard_outlined;
  }
  return filled ? Icons.folder : Icons.folder_outlined;
}

void showCollectionSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
