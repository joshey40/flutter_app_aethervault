import 'package:drift/drift.dart';

/// The kind of a folder in the collection.
enum FolderType {
  box(0),
  deck(1),
  commander(2),
  main(3),
  sideboard(4),
  considering(5),
  companion(6),
  planes(7),
  schemes(8),
  dungeon(9),
  attractions(10),
  contraptions(11),
  stickers(12);

  const FolderType(this.value);

  /// The value that is stored in the database and sent to the server.
  final int value;

  /// Whether this is a board folder inside a deck.
  bool get isBoard => value >= FolderType.commander.value;

  /// All board types, in the order they should usually be displayed.
  static List<FolderType> get boards =>
      values.where((type) => type.isBoard).toList();

  static FolderType fromValue(int value) =>
      values.firstWhere((type) => type.value == value);

  static const converter = _IntEnumConverter<FolderType>(
    FolderType.fromValue,
    _folderTypeToValue,
  );
}

int _folderTypeToValue(FolderType type) => type.value;

/// The finish of a physical card. Same values as Scryfall's `finishes`.
enum CardFinish {
  nonfoil(0),
  foil(1),
  etched(2);

  const CardFinish(this.value);

  final int value;

  static CardFinish fromValue(int value) =>
      values.firstWhere((finish) => finish.value == value);

  static const converter = _IntEnumConverter<CardFinish>(
    CardFinish.fromValue,
    _cardFinishToValue,
  );
}

int _cardFinishToValue(CardFinish finish) => finish.value;

/// The condition of a physical card, using the Cardmarket scale.
enum CardQuality {
  unknown(0),
  mint(1),
  nearMint(2),
  excellent(3),
  good(4),
  lightPlayed(5),
  played(6),
  poor(7);

  const CardQuality(this.value);

  final int value;

  static CardQuality fromValue(int value) =>
      values.firstWhere((quality) => quality.value == value);

  static const converter = _IntEnumConverter<CardQuality>(
    CardQuality.fromValue,
    _cardQualityToValue,
  );
}

int _cardQualityToValue(CardQuality quality) => quality.value;

/// Stores an enum by its explicit `value` instead of its index, so reordering
/// the Dart enum can never silently change stored data.
class _IntEnumConverter<T extends Enum> extends TypeConverter<T, int> {
  const _IntEnumConverter(this._fromValue, this._toValue);

  final T Function(int value) _fromValue;
  final int Function(T value) _toValue;

  @override
  T fromSql(int fromDb) => _fromValue(fromDb);

  @override
  int toSql(T value) => _toValue(value);
}
