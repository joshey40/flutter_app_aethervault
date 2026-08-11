// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ScryfallCardsTable extends ScryfallCards
    with TableInfo<$ScryfallCardsTable, ScryfallCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScryfallCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scryfallIdMeta = const VerificationMeta(
    'scryfallId',
  );
  @override
  late final GeneratedColumn<String> scryfallId = GeneratedColumn<String>(
    'scryfall_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oracleIdMeta = const VerificationMeta(
    'oracleId',
  );
  @override
  late final GeneratedColumn<String> oracleId = GeneratedColumn<String>(
    'oracle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tcgplayerIdMeta = const VerificationMeta(
    'tcgplayerId',
  );
  @override
  late final GeneratedColumn<String> tcgplayerId = GeneratedColumn<String>(
    'tcgplayer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardmarketIdMeta = const VerificationMeta(
    'cardmarketId',
  );
  @override
  late final GeneratedColumn<String> cardmarketId = GeneratedColumn<String>(
    'cardmarket_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _multiverseIdsJsonMeta = const VerificationMeta(
    'multiverseIdsJson',
  );
  @override
  late final GeneratedColumn<String> multiverseIdsJson =
      GeneratedColumn<String>(
        'multiverse_ids_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _layoutMeta = const VerificationMeta('layout');
  @override
  late final GeneratedColumn<String> layout = GeneratedColumn<String>(
    'layout',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printedNameMeta = const VerificationMeta(
    'printedName',
  );
  @override
  late final GeneratedColumn<String> printedName = GeneratedColumn<String>(
    'printed_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorNameMeta = const VerificationMeta(
    'flavorName',
  );
  @override
  late final GeneratedColumn<String> flavorName = GeneratedColumn<String>(
    'flavor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setCodeMeta = const VerificationMeta(
    'setCode',
  );
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
    'set_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setTypeMeta = const VerificationMeta(
    'setType',
  );
  @override
  late final GeneratedColumn<String> setType = GeneratedColumn<String>(
    'set_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setUriMeta = const VerificationMeta('setUri');
  @override
  late final GeneratedColumn<String> setUri = GeneratedColumn<String>(
    'set_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setSearchUriMeta = const VerificationMeta(
    'setSearchUri',
  );
  @override
  late final GeneratedColumn<String> setSearchUri = GeneratedColumn<String>(
    'set_search_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scryfallSetUriMeta = const VerificationMeta(
    'scryfallSetUri',
  );
  @override
  late final GeneratedColumn<String> scryfallSetUri = GeneratedColumn<String>(
    'scryfall_set_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectorNumberMeta = const VerificationMeta(
    'collectorNumber',
  );
  @override
  late final GeneratedColumn<String> collectorNumber = GeneratedColumn<String>(
    'collector_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityValueMeta = const VerificationMeta(
    'rarityValue',
  );
  @override
  late final GeneratedColumn<int> rarityValue = GeneratedColumn<int>(
    'rarity_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _releasedAtMeta = const VerificationMeta(
    'releasedAt',
  );
  @override
  late final GeneratedColumn<String> releasedAt = GeneratedColumn<String>(
    'released_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scryfallUriMeta = const VerificationMeta(
    'scryfallUri',
  );
  @override
  late final GeneratedColumn<String> scryfallUri = GeneratedColumn<String>(
    'scryfall_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulingsUriMeta = const VerificationMeta(
    'rulingsUri',
  );
  @override
  late final GeneratedColumn<String> rulingsUri = GeneratedColumn<String>(
    'rulings_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printsSearchUriMeta = const VerificationMeta(
    'printsSearchUri',
  );
  @override
  late final GeneratedColumn<String> printsSearchUri = GeneratedColumn<String>(
    'prints_search_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manaCostMeta = const VerificationMeta(
    'manaCost',
  );
  @override
  late final GeneratedColumn<String> manaCost = GeneratedColumn<String>(
    'mana_cost',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeLineMeta = const VerificationMeta(
    'typeLine',
  );
  @override
  late final GeneratedColumn<String> typeLine = GeneratedColumn<String>(
    'type_line',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printedTypeLineMeta = const VerificationMeta(
    'printedTypeLine',
  );
  @override
  late final GeneratedColumn<String> printedTypeLine = GeneratedColumn<String>(
    'printed_type_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oracleTextMeta = const VerificationMeta(
    'oracleText',
  );
  @override
  late final GeneratedColumn<String> oracleText = GeneratedColumn<String>(
    'oracle_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printedTextMeta = const VerificationMeta(
    'printedText',
  );
  @override
  late final GeneratedColumn<String> printedText = GeneratedColumn<String>(
    'printed_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorTextMeta = const VerificationMeta(
    'flavorText',
  );
  @override
  late final GeneratedColumn<String> flavorText = GeneratedColumn<String>(
    'flavor_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorsJsonMeta = const VerificationMeta(
    'colorsJson',
  );
  @override
  late final GeneratedColumn<String> colorsJson = GeneratedColumn<String>(
    'colors_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMaskMeta = const VerificationMeta(
    'colorMask',
  );
  @override
  late final GeneratedColumn<int> colorMask = GeneratedColumn<int>(
    'color_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorIdentityJsonMeta = const VerificationMeta(
    'colorIdentityJson',
  );
  @override
  late final GeneratedColumn<String> colorIdentityJson =
      GeneratedColumn<String>(
        'color_identity_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _colorIdentityMaskMeta = const VerificationMeta(
    'colorIdentityMask',
  );
  @override
  late final GeneratedColumn<int> colorIdentityMask = GeneratedColumn<int>(
    'color_identity_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _producedManaJsonMeta = const VerificationMeta(
    'producedManaJson',
  );
  @override
  late final GeneratedColumn<String> producedManaJson = GeneratedColumn<String>(
    'produced_mana_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _producedManaMaskMeta = const VerificationMeta(
    'producedManaMask',
  );
  @override
  late final GeneratedColumn<int> producedManaMask = GeneratedColumn<int>(
    'produced_mana_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<String> power = GeneratedColumn<String>(
    'power',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toughnessMeta = const VerificationMeta(
    'toughness',
  );
  @override
  late final GeneratedColumn<String> toughness = GeneratedColumn<String>(
    'toughness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loyaltyMeta = const VerificationMeta(
    'loyalty',
  );
  @override
  late final GeneratedColumn<String> loyalty = GeneratedColumn<String>(
    'loyalty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defenseMeta = const VerificationMeta(
    'defense',
  );
  @override
  late final GeneratedColumn<String> defense = GeneratedColumn<String>(
    'defense',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cmcMeta = const VerificationMeta('cmc');
  @override
  late final GeneratedColumn<double> cmc = GeneratedColumn<double>(
    'cmc',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keywordsJsonMeta = const VerificationMeta(
    'keywordsJson',
  );
  @override
  late final GeneratedColumn<String> keywordsJson = GeneratedColumn<String>(
    'keywords_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasCardFacesMeta = const VerificationMeta(
    'hasCardFaces',
  );
  @override
  late final GeneratedColumn<bool> hasCardFaces = GeneratedColumn<bool>(
    'has_card_faces',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_card_faces" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasColorIndicatorMeta = const VerificationMeta(
    'hasColorIndicator',
  );
  @override
  late final GeneratedColumn<bool> hasColorIndicator = GeneratedColumn<bool>(
    'has_color_indicator',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_color_indicator" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _borderColorMeta = const VerificationMeta(
    'borderColor',
  );
  @override
  late final GeneratedColumn<String> borderColor = GeneratedColumn<String>(
    'border_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frameMeta = const VerificationMeta('frame');
  @override
  late final GeneratedColumn<String> frame = GeneratedColumn<String>(
    'frame',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frameEffectsJsonMeta = const VerificationMeta(
    'frameEffectsJson',
  );
  @override
  late final GeneratedColumn<String> frameEffectsJson = GeneratedColumn<String>(
    'frame_effects_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _securityStampMeta = const VerificationMeta(
    'securityStamp',
  );
  @override
  late final GeneratedColumn<String> securityStamp = GeneratedColumn<String>(
    'security_stamp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _highresImageMeta = const VerificationMeta(
    'highresImage',
  );
  @override
  late final GeneratedColumn<bool> highresImage = GeneratedColumn<bool>(
    'highres_image',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("highres_image" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _imageStatusMeta = const VerificationMeta(
    'imageStatus',
  );
  @override
  late final GeneratedColumn<String> imageStatus = GeneratedColumn<String>(
    'image_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUpdatedAtMeta = const VerificationMeta(
    'imageUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> imageUpdatedAt = GeneratedColumn<String>(
    'image_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageSmallMeta = const VerificationMeta(
    'imageSmall',
  );
  @override
  late final GeneratedColumn<String> imageSmall = GeneratedColumn<String>(
    'image_small',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageNormalMeta = const VerificationMeta(
    'imageNormal',
  );
  @override
  late final GeneratedColumn<String> imageNormal = GeneratedColumn<String>(
    'image_normal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageLargeMeta = const VerificationMeta(
    'imageLarge',
  );
  @override
  late final GeneratedColumn<String> imageLarge = GeneratedColumn<String>(
    'image_large',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePngMeta = const VerificationMeta(
    'imagePng',
  );
  @override
  late final GeneratedColumn<String> imagePng = GeneratedColumn<String>(
    'image_png',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageArtCropMeta = const VerificationMeta(
    'imageArtCrop',
  );
  @override
  late final GeneratedColumn<String> imageArtCrop = GeneratedColumn<String>(
    'image_art_crop',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageBorderCropMeta = const VerificationMeta(
    'imageBorderCrop',
  );
  @override
  late final GeneratedColumn<String> imageBorderCrop = GeneratedColumn<String>(
    'image_border_crop',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistIdsJsonMeta = const VerificationMeta(
    'artistIdsJson',
  );
  @override
  late final GeneratedColumn<String> artistIdsJson = GeneratedColumn<String>(
    'artist_ids_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _illustrationIdMeta = const VerificationMeta(
    'illustrationId',
  );
  @override
  late final GeneratedColumn<String> illustrationId = GeneratedColumn<String>(
    'illustration_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watermarkMeta = const VerificationMeta(
    'watermark',
  );
  @override
  late final GeneratedColumn<String> watermark = GeneratedColumn<String>(
    'watermark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullArtMeta = const VerificationMeta(
    'fullArt',
  );
  @override
  late final GeneratedColumn<bool> fullArt = GeneratedColumn<bool>(
    'full_art',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("full_art" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _textlessMeta = const VerificationMeta(
    'textless',
  );
  @override
  late final GeneratedColumn<bool> textless = GeneratedColumn<bool>(
    'textless',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("textless" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _boosterMeta = const VerificationMeta(
    'booster',
  );
  @override
  late final GeneratedColumn<bool> booster = GeneratedColumn<bool>(
    'booster',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("booster" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _storySpotlightMeta = const VerificationMeta(
    'storySpotlight',
  );
  @override
  late final GeneratedColumn<bool> storySpotlight = GeneratedColumn<bool>(
    'story_spotlight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("story_spotlight" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _promoMeta = const VerificationMeta('promo');
  @override
  late final GeneratedColumn<bool> promo = GeneratedColumn<bool>(
    'promo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("promo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reprintMeta = const VerificationMeta(
    'reprint',
  );
  @override
  late final GeneratedColumn<bool> reprint = GeneratedColumn<bool>(
    'reprint',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reprint" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _variationMeta = const VerificationMeta(
    'variation',
  );
  @override
  late final GeneratedColumn<bool> variation = GeneratedColumn<bool>(
    'variation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("variation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reservedMeta = const VerificationMeta(
    'reserved',
  );
  @override
  late final GeneratedColumn<bool> reserved = GeneratedColumn<bool>(
    'reserved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reserved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gameChangerMeta = const VerificationMeta(
    'gameChanger',
  );
  @override
  late final GeneratedColumn<bool> gameChanger = GeneratedColumn<bool>(
    'game_changer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("game_changer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _oversizedMeta = const VerificationMeta(
    'oversized',
  );
  @override
  late final GeneratedColumn<bool> oversized = GeneratedColumn<bool>(
    'oversized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("oversized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nonfoilMeta = const VerificationMeta(
    'nonfoil',
  );
  @override
  late final GeneratedColumn<bool> nonfoil = GeneratedColumn<bool>(
    'nonfoil',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nonfoil" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _foilMeta = const VerificationMeta('foil');
  @override
  late final GeneratedColumn<bool> foil = GeneratedColumn<bool>(
    'foil',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("foil" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _etchedMeta = const VerificationMeta('etched');
  @override
  late final GeneratedColumn<bool> etched = GeneratedColumn<bool>(
    'etched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("etched" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _glossyMeta = const VerificationMeta('glossy');
  @override
  late final GeneratedColumn<bool> glossy = GeneratedColumn<bool>(
    'glossy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("glossy" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paperMeta = const VerificationMeta('paper');
  @override
  late final GeneratedColumn<bool> paper = GeneratedColumn<bool>(
    'paper',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paper" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _legalStandardMeta = const VerificationMeta(
    'legalStandard',
  );
  @override
  late final GeneratedColumn<String> legalStandard = GeneratedColumn<String>(
    'legal_standard',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalFutureMeta = const VerificationMeta(
    'legalFuture',
  );
  @override
  late final GeneratedColumn<String> legalFuture = GeneratedColumn<String>(
    'legal_future',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalHistoricMeta = const VerificationMeta(
    'legalHistoric',
  );
  @override
  late final GeneratedColumn<String> legalHistoric = GeneratedColumn<String>(
    'legal_historic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalTimelessMeta = const VerificationMeta(
    'legalTimeless',
  );
  @override
  late final GeneratedColumn<String> legalTimeless = GeneratedColumn<String>(
    'legal_timeless',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalGladiatorMeta = const VerificationMeta(
    'legalGladiator',
  );
  @override
  late final GeneratedColumn<String> legalGladiator = GeneratedColumn<String>(
    'legal_gladiator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalPioneerMeta = const VerificationMeta(
    'legalPioneer',
  );
  @override
  late final GeneratedColumn<String> legalPioneer = GeneratedColumn<String>(
    'legal_pioneer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalModernMeta = const VerificationMeta(
    'legalModern',
  );
  @override
  late final GeneratedColumn<String> legalModern = GeneratedColumn<String>(
    'legal_modern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalLegacyMeta = const VerificationMeta(
    'legalLegacy',
  );
  @override
  late final GeneratedColumn<String> legalLegacy = GeneratedColumn<String>(
    'legal_legacy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalPauperMeta = const VerificationMeta(
    'legalPauper',
  );
  @override
  late final GeneratedColumn<String> legalPauper = GeneratedColumn<String>(
    'legal_pauper',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalVintageMeta = const VerificationMeta(
    'legalVintage',
  );
  @override
  late final GeneratedColumn<String> legalVintage = GeneratedColumn<String>(
    'legal_vintage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalPennyMeta = const VerificationMeta(
    'legalPenny',
  );
  @override
  late final GeneratedColumn<String> legalPenny = GeneratedColumn<String>(
    'legal_penny',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalCommanderMeta = const VerificationMeta(
    'legalCommander',
  );
  @override
  late final GeneratedColumn<String> legalCommander = GeneratedColumn<String>(
    'legal_commander',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalOathbreakerMeta = const VerificationMeta(
    'legalOathbreaker',
  );
  @override
  late final GeneratedColumn<String> legalOathbreaker = GeneratedColumn<String>(
    'legal_oathbreaker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalStandardBrawlMeta =
      const VerificationMeta('legalStandardBrawl');
  @override
  late final GeneratedColumn<String> legalStandardBrawl =
      GeneratedColumn<String>(
        'legal_standard_brawl',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _legalBrawlMeta = const VerificationMeta(
    'legalBrawl',
  );
  @override
  late final GeneratedColumn<String> legalBrawl = GeneratedColumn<String>(
    'legal_brawl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalCompetitiveBrawlMeta =
      const VerificationMeta('legalCompetitiveBrawl');
  @override
  late final GeneratedColumn<String> legalCompetitiveBrawl =
      GeneratedColumn<String>(
        'legal_competitive_brawl',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _legalAlchemyMeta = const VerificationMeta(
    'legalAlchemy',
  );
  @override
  late final GeneratedColumn<String> legalAlchemy = GeneratedColumn<String>(
    'legal_alchemy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalPauperCommanderMeta =
      const VerificationMeta('legalPauperCommander');
  @override
  late final GeneratedColumn<String> legalPauperCommander =
      GeneratedColumn<String>(
        'legal_pauper_commander',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _legalDuelMeta = const VerificationMeta(
    'legalDuel',
  );
  @override
  late final GeneratedColumn<String> legalDuel = GeneratedColumn<String>(
    'legal_duel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalOldSchoolMeta = const VerificationMeta(
    'legalOldSchool',
  );
  @override
  late final GeneratedColumn<String> legalOldSchool = GeneratedColumn<String>(
    'legal_old_school',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalPremodernMeta = const VerificationMeta(
    'legalPremodern',
  );
  @override
  late final GeneratedColumn<String> legalPremodern = GeneratedColumn<String>(
    'legal_premodern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalPredhMeta = const VerificationMeta(
    'legalPredh',
  );
  @override
  late final GeneratedColumn<String> legalPredh = GeneratedColumn<String>(
    'legal_predh',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalTlrMeta = const VerificationMeta(
    'legalTlr',
  );
  @override
  late final GeneratedColumn<String> legalTlr = GeneratedColumn<String>(
    'legal_tlr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricesUsdMeta = const VerificationMeta(
    'pricesUsd',
  );
  @override
  late final GeneratedColumn<String> pricesUsd = GeneratedColumn<String>(
    'prices_usd',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricesUsdFoilMeta = const VerificationMeta(
    'pricesUsdFoil',
  );
  @override
  late final GeneratedColumn<String> pricesUsdFoil = GeneratedColumn<String>(
    'prices_usd_foil',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricesUsdEtchedMeta = const VerificationMeta(
    'pricesUsdEtched',
  );
  @override
  late final GeneratedColumn<String> pricesUsdEtched = GeneratedColumn<String>(
    'prices_usd_etched',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricesEurMeta = const VerificationMeta(
    'pricesEur',
  );
  @override
  late final GeneratedColumn<String> pricesEur = GeneratedColumn<String>(
    'prices_eur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricesEurFoilMeta = const VerificationMeta(
    'pricesEurFoil',
  );
  @override
  late final GeneratedColumn<String> pricesEurFoil = GeneratedColumn<String>(
    'prices_eur_foil',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricesTixMeta = const VerificationMeta(
    'pricesTix',
  );
  @override
  late final GeneratedColumn<String> pricesTix = GeneratedColumn<String>(
    'prices_tix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedGathererUriMeta =
      const VerificationMeta('relatedGathererUri');
  @override
  late final GeneratedColumn<String> relatedGathererUri =
      GeneratedColumn<String>(
        'related_gatherer_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _relatedTcgplayerInfiniteArticlesUriMeta =
      const VerificationMeta('relatedTcgplayerInfiniteArticlesUri');
  @override
  late final GeneratedColumn<String> relatedTcgplayerInfiniteArticlesUri =
      GeneratedColumn<String>(
        'related_tcgplayer_infinite_articles_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _relatedTcgplayerInfiniteDecksUriMeta =
      const VerificationMeta('relatedTcgplayerInfiniteDecksUri');
  @override
  late final GeneratedColumn<String> relatedTcgplayerInfiniteDecksUri =
      GeneratedColumn<String>(
        'related_tcgplayer_infinite_decks_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _relatedEdhrecUriMeta = const VerificationMeta(
    'relatedEdhrecUri',
  );
  @override
  late final GeneratedColumn<String> relatedEdhrecUri = GeneratedColumn<String>(
    'related_edhrec_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseTcgplayerUriMeta =
      const VerificationMeta('purchaseTcgplayerUri');
  @override
  late final GeneratedColumn<String> purchaseTcgplayerUri =
      GeneratedColumn<String>(
        'purchase_tcgplayer_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseCardmarketUriMeta =
      const VerificationMeta('purchaseCardmarketUri');
  @override
  late final GeneratedColumn<String> purchaseCardmarketUri =
      GeneratedColumn<String>(
        'purchase_cardmarket_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseCardhoarderUriMeta =
      const VerificationMeta('purchaseCardhoarderUri');
  @override
  late final GeneratedColumn<String> purchaseCardhoarderUri =
      GeneratedColumn<String>(
        'purchase_cardhoarder_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cardBackIdMeta = const VerificationMeta(
    'cardBackId',
  );
  @override
  late final GeneratedColumn<String> cardBackId = GeneratedColumn<String>(
    'card_back_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allPartsJsonMeta = const VerificationMeta(
    'allPartsJson',
  );
  @override
  late final GeneratedColumn<String> allPartsJson = GeneratedColumn<String>(
    'all_parts_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    scryfallId,
    oracleId,
    tcgplayerId,
    cardmarketId,
    multiverseIdsJson,
    layout,
    name,
    printedName,
    flavorName,
    setId,
    setCode,
    setName,
    setType,
    setUri,
    setSearchUri,
    scryfallSetUri,
    collectorNumber,
    lang,
    rarity,
    rarityValue,
    releasedAt,
    scryfallUri,
    uri,
    rulingsUri,
    printsSearchUri,
    manaCost,
    typeLine,
    printedTypeLine,
    oracleText,
    printedText,
    flavorText,
    colorsJson,
    colorMask,
    colorIdentityJson,
    colorIdentityMask,
    producedManaJson,
    producedManaMask,
    power,
    toughness,
    loyalty,
    defense,
    cmc,
    keywordsJson,
    hasCardFaces,
    hasColorIndicator,
    borderColor,
    frame,
    frameEffectsJson,
    securityStamp,
    highresImage,
    imageStatus,
    imageUpdatedAt,
    imageSmall,
    imageNormal,
    imageLarge,
    imagePng,
    imageArtCrop,
    imageBorderCrop,
    artist,
    artistIdsJson,
    illustrationId,
    watermark,
    fullArt,
    textless,
    booster,
    storySpotlight,
    promo,
    reprint,
    variation,
    reserved,
    gameChanger,
    oversized,
    nonfoil,
    foil,
    etched,
    glossy,
    paper,
    legalStandard,
    legalFuture,
    legalHistoric,
    legalTimeless,
    legalGladiator,
    legalPioneer,
    legalModern,
    legalLegacy,
    legalPauper,
    legalVintage,
    legalPenny,
    legalCommander,
    legalOathbreaker,
    legalStandardBrawl,
    legalBrawl,
    legalCompetitiveBrawl,
    legalAlchemy,
    legalPauperCommander,
    legalDuel,
    legalOldSchool,
    legalPremodern,
    legalPredh,
    legalTlr,
    pricesUsd,
    pricesUsdFoil,
    pricesUsdEtched,
    pricesEur,
    pricesEurFoil,
    pricesTix,
    relatedGathererUri,
    relatedTcgplayerInfiniteArticlesUri,
    relatedTcgplayerInfiniteDecksUri,
    relatedEdhrecUri,
    purchaseTcgplayerUri,
    purchaseCardmarketUri,
    purchaseCardhoarderUri,
    cardBackId,
    allPartsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scryfall_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScryfallCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scryfall_id')) {
      context.handle(
        _scryfallIdMeta,
        scryfallId.isAcceptableOrUnknown(data['scryfall_id']!, _scryfallIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scryfallIdMeta);
    }
    if (data.containsKey('oracle_id')) {
      context.handle(
        _oracleIdMeta,
        oracleId.isAcceptableOrUnknown(data['oracle_id']!, _oracleIdMeta),
      );
    }
    if (data.containsKey('tcgplayer_id')) {
      context.handle(
        _tcgplayerIdMeta,
        tcgplayerId.isAcceptableOrUnknown(
          data['tcgplayer_id']!,
          _tcgplayerIdMeta,
        ),
      );
    }
    if (data.containsKey('cardmarket_id')) {
      context.handle(
        _cardmarketIdMeta,
        cardmarketId.isAcceptableOrUnknown(
          data['cardmarket_id']!,
          _cardmarketIdMeta,
        ),
      );
    }
    if (data.containsKey('multiverse_ids_json')) {
      context.handle(
        _multiverseIdsJsonMeta,
        multiverseIdsJson.isAcceptableOrUnknown(
          data['multiverse_ids_json']!,
          _multiverseIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('layout')) {
      context.handle(
        _layoutMeta,
        layout.isAcceptableOrUnknown(data['layout']!, _layoutMeta),
      );
    } else if (isInserting) {
      context.missing(_layoutMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('printed_name')) {
      context.handle(
        _printedNameMeta,
        printedName.isAcceptableOrUnknown(
          data['printed_name']!,
          _printedNameMeta,
        ),
      );
    }
    if (data.containsKey('flavor_name')) {
      context.handle(
        _flavorNameMeta,
        flavorName.isAcceptableOrUnknown(data['flavor_name']!, _flavorNameMeta),
      );
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('set_code')) {
      context.handle(
        _setCodeMeta,
        setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    } else if (isInserting) {
      context.missing(_setNameMeta);
    }
    if (data.containsKey('set_type')) {
      context.handle(
        _setTypeMeta,
        setType.isAcceptableOrUnknown(data['set_type']!, _setTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_setTypeMeta);
    }
    if (data.containsKey('set_uri')) {
      context.handle(
        _setUriMeta,
        setUri.isAcceptableOrUnknown(data['set_uri']!, _setUriMeta),
      );
    } else if (isInserting) {
      context.missing(_setUriMeta);
    }
    if (data.containsKey('set_search_uri')) {
      context.handle(
        _setSearchUriMeta,
        setSearchUri.isAcceptableOrUnknown(
          data['set_search_uri']!,
          _setSearchUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_setSearchUriMeta);
    }
    if (data.containsKey('scryfall_set_uri')) {
      context.handle(
        _scryfallSetUriMeta,
        scryfallSetUri.isAcceptableOrUnknown(
          data['scryfall_set_uri']!,
          _scryfallSetUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scryfallSetUriMeta);
    }
    if (data.containsKey('collector_number')) {
      context.handle(
        _collectorNumberMeta,
        collectorNumber.isAcceptableOrUnknown(
          data['collector_number']!,
          _collectorNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectorNumberMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('rarity_value')) {
      context.handle(
        _rarityValueMeta,
        rarityValue.isAcceptableOrUnknown(
          data['rarity_value']!,
          _rarityValueMeta,
        ),
      );
    }
    if (data.containsKey('released_at')) {
      context.handle(
        _releasedAtMeta,
        releasedAt.isAcceptableOrUnknown(data['released_at']!, _releasedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_releasedAtMeta);
    }
    if (data.containsKey('scryfall_uri')) {
      context.handle(
        _scryfallUriMeta,
        scryfallUri.isAcceptableOrUnknown(
          data['scryfall_uri']!,
          _scryfallUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scryfallUriMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('rulings_uri')) {
      context.handle(
        _rulingsUriMeta,
        rulingsUri.isAcceptableOrUnknown(data['rulings_uri']!, _rulingsUriMeta),
      );
    } else if (isInserting) {
      context.missing(_rulingsUriMeta);
    }
    if (data.containsKey('prints_search_uri')) {
      context.handle(
        _printsSearchUriMeta,
        printsSearchUri.isAcceptableOrUnknown(
          data['prints_search_uri']!,
          _printsSearchUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_printsSearchUriMeta);
    }
    if (data.containsKey('mana_cost')) {
      context.handle(
        _manaCostMeta,
        manaCost.isAcceptableOrUnknown(data['mana_cost']!, _manaCostMeta),
      );
    }
    if (data.containsKey('type_line')) {
      context.handle(
        _typeLineMeta,
        typeLine.isAcceptableOrUnknown(data['type_line']!, _typeLineMeta),
      );
    } else if (isInserting) {
      context.missing(_typeLineMeta);
    }
    if (data.containsKey('printed_type_line')) {
      context.handle(
        _printedTypeLineMeta,
        printedTypeLine.isAcceptableOrUnknown(
          data['printed_type_line']!,
          _printedTypeLineMeta,
        ),
      );
    }
    if (data.containsKey('oracle_text')) {
      context.handle(
        _oracleTextMeta,
        oracleText.isAcceptableOrUnknown(data['oracle_text']!, _oracleTextMeta),
      );
    }
    if (data.containsKey('printed_text')) {
      context.handle(
        _printedTextMeta,
        printedText.isAcceptableOrUnknown(
          data['printed_text']!,
          _printedTextMeta,
        ),
      );
    }
    if (data.containsKey('flavor_text')) {
      context.handle(
        _flavorTextMeta,
        flavorText.isAcceptableOrUnknown(data['flavor_text']!, _flavorTextMeta),
      );
    }
    if (data.containsKey('colors_json')) {
      context.handle(
        _colorsJsonMeta,
        colorsJson.isAcceptableOrUnknown(data['colors_json']!, _colorsJsonMeta),
      );
    }
    if (data.containsKey('color_mask')) {
      context.handle(
        _colorMaskMeta,
        colorMask.isAcceptableOrUnknown(data['color_mask']!, _colorMaskMeta),
      );
    }
    if (data.containsKey('color_identity_json')) {
      context.handle(
        _colorIdentityJsonMeta,
        colorIdentityJson.isAcceptableOrUnknown(
          data['color_identity_json']!,
          _colorIdentityJsonMeta,
        ),
      );
    }
    if (data.containsKey('color_identity_mask')) {
      context.handle(
        _colorIdentityMaskMeta,
        colorIdentityMask.isAcceptableOrUnknown(
          data['color_identity_mask']!,
          _colorIdentityMaskMeta,
        ),
      );
    }
    if (data.containsKey('produced_mana_json')) {
      context.handle(
        _producedManaJsonMeta,
        producedManaJson.isAcceptableOrUnknown(
          data['produced_mana_json']!,
          _producedManaJsonMeta,
        ),
      );
    }
    if (data.containsKey('produced_mana_mask')) {
      context.handle(
        _producedManaMaskMeta,
        producedManaMask.isAcceptableOrUnknown(
          data['produced_mana_mask']!,
          _producedManaMaskMeta,
        ),
      );
    }
    if (data.containsKey('power')) {
      context.handle(
        _powerMeta,
        power.isAcceptableOrUnknown(data['power']!, _powerMeta),
      );
    }
    if (data.containsKey('toughness')) {
      context.handle(
        _toughnessMeta,
        toughness.isAcceptableOrUnknown(data['toughness']!, _toughnessMeta),
      );
    }
    if (data.containsKey('loyalty')) {
      context.handle(
        _loyaltyMeta,
        loyalty.isAcceptableOrUnknown(data['loyalty']!, _loyaltyMeta),
      );
    }
    if (data.containsKey('defense')) {
      context.handle(
        _defenseMeta,
        defense.isAcceptableOrUnknown(data['defense']!, _defenseMeta),
      );
    }
    if (data.containsKey('cmc')) {
      context.handle(
        _cmcMeta,
        cmc.isAcceptableOrUnknown(data['cmc']!, _cmcMeta),
      );
    } else if (isInserting) {
      context.missing(_cmcMeta);
    }
    if (data.containsKey('keywords_json')) {
      context.handle(
        _keywordsJsonMeta,
        keywordsJson.isAcceptableOrUnknown(
          data['keywords_json']!,
          _keywordsJsonMeta,
        ),
      );
    }
    if (data.containsKey('has_card_faces')) {
      context.handle(
        _hasCardFacesMeta,
        hasCardFaces.isAcceptableOrUnknown(
          data['has_card_faces']!,
          _hasCardFacesMeta,
        ),
      );
    }
    if (data.containsKey('has_color_indicator')) {
      context.handle(
        _hasColorIndicatorMeta,
        hasColorIndicator.isAcceptableOrUnknown(
          data['has_color_indicator']!,
          _hasColorIndicatorMeta,
        ),
      );
    }
    if (data.containsKey('border_color')) {
      context.handle(
        _borderColorMeta,
        borderColor.isAcceptableOrUnknown(
          data['border_color']!,
          _borderColorMeta,
        ),
      );
    }
    if (data.containsKey('frame')) {
      context.handle(
        _frameMeta,
        frame.isAcceptableOrUnknown(data['frame']!, _frameMeta),
      );
    }
    if (data.containsKey('frame_effects_json')) {
      context.handle(
        _frameEffectsJsonMeta,
        frameEffectsJson.isAcceptableOrUnknown(
          data['frame_effects_json']!,
          _frameEffectsJsonMeta,
        ),
      );
    }
    if (data.containsKey('security_stamp')) {
      context.handle(
        _securityStampMeta,
        securityStamp.isAcceptableOrUnknown(
          data['security_stamp']!,
          _securityStampMeta,
        ),
      );
    }
    if (data.containsKey('highres_image')) {
      context.handle(
        _highresImageMeta,
        highresImage.isAcceptableOrUnknown(
          data['highres_image']!,
          _highresImageMeta,
        ),
      );
    }
    if (data.containsKey('image_status')) {
      context.handle(
        _imageStatusMeta,
        imageStatus.isAcceptableOrUnknown(
          data['image_status']!,
          _imageStatusMeta,
        ),
      );
    }
    if (data.containsKey('image_updated_at')) {
      context.handle(
        _imageUpdatedAtMeta,
        imageUpdatedAt.isAcceptableOrUnknown(
          data['image_updated_at']!,
          _imageUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('image_small')) {
      context.handle(
        _imageSmallMeta,
        imageSmall.isAcceptableOrUnknown(data['image_small']!, _imageSmallMeta),
      );
    }
    if (data.containsKey('image_normal')) {
      context.handle(
        _imageNormalMeta,
        imageNormal.isAcceptableOrUnknown(
          data['image_normal']!,
          _imageNormalMeta,
        ),
      );
    }
    if (data.containsKey('image_large')) {
      context.handle(
        _imageLargeMeta,
        imageLarge.isAcceptableOrUnknown(data['image_large']!, _imageLargeMeta),
      );
    }
    if (data.containsKey('image_png')) {
      context.handle(
        _imagePngMeta,
        imagePng.isAcceptableOrUnknown(data['image_png']!, _imagePngMeta),
      );
    }
    if (data.containsKey('image_art_crop')) {
      context.handle(
        _imageArtCropMeta,
        imageArtCrop.isAcceptableOrUnknown(
          data['image_art_crop']!,
          _imageArtCropMeta,
        ),
      );
    }
    if (data.containsKey('image_border_crop')) {
      context.handle(
        _imageBorderCropMeta,
        imageBorderCrop.isAcceptableOrUnknown(
          data['image_border_crop']!,
          _imageBorderCropMeta,
        ),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('artist_ids_json')) {
      context.handle(
        _artistIdsJsonMeta,
        artistIdsJson.isAcceptableOrUnknown(
          data['artist_ids_json']!,
          _artistIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('illustration_id')) {
      context.handle(
        _illustrationIdMeta,
        illustrationId.isAcceptableOrUnknown(
          data['illustration_id']!,
          _illustrationIdMeta,
        ),
      );
    }
    if (data.containsKey('watermark')) {
      context.handle(
        _watermarkMeta,
        watermark.isAcceptableOrUnknown(data['watermark']!, _watermarkMeta),
      );
    }
    if (data.containsKey('full_art')) {
      context.handle(
        _fullArtMeta,
        fullArt.isAcceptableOrUnknown(data['full_art']!, _fullArtMeta),
      );
    }
    if (data.containsKey('textless')) {
      context.handle(
        _textlessMeta,
        textless.isAcceptableOrUnknown(data['textless']!, _textlessMeta),
      );
    }
    if (data.containsKey('booster')) {
      context.handle(
        _boosterMeta,
        booster.isAcceptableOrUnknown(data['booster']!, _boosterMeta),
      );
    }
    if (data.containsKey('story_spotlight')) {
      context.handle(
        _storySpotlightMeta,
        storySpotlight.isAcceptableOrUnknown(
          data['story_spotlight']!,
          _storySpotlightMeta,
        ),
      );
    }
    if (data.containsKey('promo')) {
      context.handle(
        _promoMeta,
        promo.isAcceptableOrUnknown(data['promo']!, _promoMeta),
      );
    }
    if (data.containsKey('reprint')) {
      context.handle(
        _reprintMeta,
        reprint.isAcceptableOrUnknown(data['reprint']!, _reprintMeta),
      );
    }
    if (data.containsKey('variation')) {
      context.handle(
        _variationMeta,
        variation.isAcceptableOrUnknown(data['variation']!, _variationMeta),
      );
    }
    if (data.containsKey('reserved')) {
      context.handle(
        _reservedMeta,
        reserved.isAcceptableOrUnknown(data['reserved']!, _reservedMeta),
      );
    }
    if (data.containsKey('game_changer')) {
      context.handle(
        _gameChangerMeta,
        gameChanger.isAcceptableOrUnknown(
          data['game_changer']!,
          _gameChangerMeta,
        ),
      );
    }
    if (data.containsKey('oversized')) {
      context.handle(
        _oversizedMeta,
        oversized.isAcceptableOrUnknown(data['oversized']!, _oversizedMeta),
      );
    }
    if (data.containsKey('nonfoil')) {
      context.handle(
        _nonfoilMeta,
        nonfoil.isAcceptableOrUnknown(data['nonfoil']!, _nonfoilMeta),
      );
    }
    if (data.containsKey('foil')) {
      context.handle(
        _foilMeta,
        foil.isAcceptableOrUnknown(data['foil']!, _foilMeta),
      );
    }
    if (data.containsKey('etched')) {
      context.handle(
        _etchedMeta,
        etched.isAcceptableOrUnknown(data['etched']!, _etchedMeta),
      );
    }
    if (data.containsKey('glossy')) {
      context.handle(
        _glossyMeta,
        glossy.isAcceptableOrUnknown(data['glossy']!, _glossyMeta),
      );
    }
    if (data.containsKey('paper')) {
      context.handle(
        _paperMeta,
        paper.isAcceptableOrUnknown(data['paper']!, _paperMeta),
      );
    }
    if (data.containsKey('legal_standard')) {
      context.handle(
        _legalStandardMeta,
        legalStandard.isAcceptableOrUnknown(
          data['legal_standard']!,
          _legalStandardMeta,
        ),
      );
    }
    if (data.containsKey('legal_future')) {
      context.handle(
        _legalFutureMeta,
        legalFuture.isAcceptableOrUnknown(
          data['legal_future']!,
          _legalFutureMeta,
        ),
      );
    }
    if (data.containsKey('legal_historic')) {
      context.handle(
        _legalHistoricMeta,
        legalHistoric.isAcceptableOrUnknown(
          data['legal_historic']!,
          _legalHistoricMeta,
        ),
      );
    }
    if (data.containsKey('legal_timeless')) {
      context.handle(
        _legalTimelessMeta,
        legalTimeless.isAcceptableOrUnknown(
          data['legal_timeless']!,
          _legalTimelessMeta,
        ),
      );
    }
    if (data.containsKey('legal_gladiator')) {
      context.handle(
        _legalGladiatorMeta,
        legalGladiator.isAcceptableOrUnknown(
          data['legal_gladiator']!,
          _legalGladiatorMeta,
        ),
      );
    }
    if (data.containsKey('legal_pioneer')) {
      context.handle(
        _legalPioneerMeta,
        legalPioneer.isAcceptableOrUnknown(
          data['legal_pioneer']!,
          _legalPioneerMeta,
        ),
      );
    }
    if (data.containsKey('legal_modern')) {
      context.handle(
        _legalModernMeta,
        legalModern.isAcceptableOrUnknown(
          data['legal_modern']!,
          _legalModernMeta,
        ),
      );
    }
    if (data.containsKey('legal_legacy')) {
      context.handle(
        _legalLegacyMeta,
        legalLegacy.isAcceptableOrUnknown(
          data['legal_legacy']!,
          _legalLegacyMeta,
        ),
      );
    }
    if (data.containsKey('legal_pauper')) {
      context.handle(
        _legalPauperMeta,
        legalPauper.isAcceptableOrUnknown(
          data['legal_pauper']!,
          _legalPauperMeta,
        ),
      );
    }
    if (data.containsKey('legal_vintage')) {
      context.handle(
        _legalVintageMeta,
        legalVintage.isAcceptableOrUnknown(
          data['legal_vintage']!,
          _legalVintageMeta,
        ),
      );
    }
    if (data.containsKey('legal_penny')) {
      context.handle(
        _legalPennyMeta,
        legalPenny.isAcceptableOrUnknown(data['legal_penny']!, _legalPennyMeta),
      );
    }
    if (data.containsKey('legal_commander')) {
      context.handle(
        _legalCommanderMeta,
        legalCommander.isAcceptableOrUnknown(
          data['legal_commander']!,
          _legalCommanderMeta,
        ),
      );
    }
    if (data.containsKey('legal_oathbreaker')) {
      context.handle(
        _legalOathbreakerMeta,
        legalOathbreaker.isAcceptableOrUnknown(
          data['legal_oathbreaker']!,
          _legalOathbreakerMeta,
        ),
      );
    }
    if (data.containsKey('legal_standard_brawl')) {
      context.handle(
        _legalStandardBrawlMeta,
        legalStandardBrawl.isAcceptableOrUnknown(
          data['legal_standard_brawl']!,
          _legalStandardBrawlMeta,
        ),
      );
    }
    if (data.containsKey('legal_brawl')) {
      context.handle(
        _legalBrawlMeta,
        legalBrawl.isAcceptableOrUnknown(data['legal_brawl']!, _legalBrawlMeta),
      );
    }
    if (data.containsKey('legal_competitive_brawl')) {
      context.handle(
        _legalCompetitiveBrawlMeta,
        legalCompetitiveBrawl.isAcceptableOrUnknown(
          data['legal_competitive_brawl']!,
          _legalCompetitiveBrawlMeta,
        ),
      );
    }
    if (data.containsKey('legal_alchemy')) {
      context.handle(
        _legalAlchemyMeta,
        legalAlchemy.isAcceptableOrUnknown(
          data['legal_alchemy']!,
          _legalAlchemyMeta,
        ),
      );
    }
    if (data.containsKey('legal_pauper_commander')) {
      context.handle(
        _legalPauperCommanderMeta,
        legalPauperCommander.isAcceptableOrUnknown(
          data['legal_pauper_commander']!,
          _legalPauperCommanderMeta,
        ),
      );
    }
    if (data.containsKey('legal_duel')) {
      context.handle(
        _legalDuelMeta,
        legalDuel.isAcceptableOrUnknown(data['legal_duel']!, _legalDuelMeta),
      );
    }
    if (data.containsKey('legal_old_school')) {
      context.handle(
        _legalOldSchoolMeta,
        legalOldSchool.isAcceptableOrUnknown(
          data['legal_old_school']!,
          _legalOldSchoolMeta,
        ),
      );
    }
    if (data.containsKey('legal_premodern')) {
      context.handle(
        _legalPremodernMeta,
        legalPremodern.isAcceptableOrUnknown(
          data['legal_premodern']!,
          _legalPremodernMeta,
        ),
      );
    }
    if (data.containsKey('legal_predh')) {
      context.handle(
        _legalPredhMeta,
        legalPredh.isAcceptableOrUnknown(data['legal_predh']!, _legalPredhMeta),
      );
    }
    if (data.containsKey('legal_tlr')) {
      context.handle(
        _legalTlrMeta,
        legalTlr.isAcceptableOrUnknown(data['legal_tlr']!, _legalTlrMeta),
      );
    }
    if (data.containsKey('prices_usd')) {
      context.handle(
        _pricesUsdMeta,
        pricesUsd.isAcceptableOrUnknown(data['prices_usd']!, _pricesUsdMeta),
      );
    }
    if (data.containsKey('prices_usd_foil')) {
      context.handle(
        _pricesUsdFoilMeta,
        pricesUsdFoil.isAcceptableOrUnknown(
          data['prices_usd_foil']!,
          _pricesUsdFoilMeta,
        ),
      );
    }
    if (data.containsKey('prices_usd_etched')) {
      context.handle(
        _pricesUsdEtchedMeta,
        pricesUsdEtched.isAcceptableOrUnknown(
          data['prices_usd_etched']!,
          _pricesUsdEtchedMeta,
        ),
      );
    }
    if (data.containsKey('prices_eur')) {
      context.handle(
        _pricesEurMeta,
        pricesEur.isAcceptableOrUnknown(data['prices_eur']!, _pricesEurMeta),
      );
    }
    if (data.containsKey('prices_eur_foil')) {
      context.handle(
        _pricesEurFoilMeta,
        pricesEurFoil.isAcceptableOrUnknown(
          data['prices_eur_foil']!,
          _pricesEurFoilMeta,
        ),
      );
    }
    if (data.containsKey('prices_tix')) {
      context.handle(
        _pricesTixMeta,
        pricesTix.isAcceptableOrUnknown(data['prices_tix']!, _pricesTixMeta),
      );
    }
    if (data.containsKey('related_gatherer_uri')) {
      context.handle(
        _relatedGathererUriMeta,
        relatedGathererUri.isAcceptableOrUnknown(
          data['related_gatherer_uri']!,
          _relatedGathererUriMeta,
        ),
      );
    }
    if (data.containsKey('related_tcgplayer_infinite_articles_uri')) {
      context.handle(
        _relatedTcgplayerInfiniteArticlesUriMeta,
        relatedTcgplayerInfiniteArticlesUri.isAcceptableOrUnknown(
          data['related_tcgplayer_infinite_articles_uri']!,
          _relatedTcgplayerInfiniteArticlesUriMeta,
        ),
      );
    }
    if (data.containsKey('related_tcgplayer_infinite_decks_uri')) {
      context.handle(
        _relatedTcgplayerInfiniteDecksUriMeta,
        relatedTcgplayerInfiniteDecksUri.isAcceptableOrUnknown(
          data['related_tcgplayer_infinite_decks_uri']!,
          _relatedTcgplayerInfiniteDecksUriMeta,
        ),
      );
    }
    if (data.containsKey('related_edhrec_uri')) {
      context.handle(
        _relatedEdhrecUriMeta,
        relatedEdhrecUri.isAcceptableOrUnknown(
          data['related_edhrec_uri']!,
          _relatedEdhrecUriMeta,
        ),
      );
    }
    if (data.containsKey('purchase_tcgplayer_uri')) {
      context.handle(
        _purchaseTcgplayerUriMeta,
        purchaseTcgplayerUri.isAcceptableOrUnknown(
          data['purchase_tcgplayer_uri']!,
          _purchaseTcgplayerUriMeta,
        ),
      );
    }
    if (data.containsKey('purchase_cardmarket_uri')) {
      context.handle(
        _purchaseCardmarketUriMeta,
        purchaseCardmarketUri.isAcceptableOrUnknown(
          data['purchase_cardmarket_uri']!,
          _purchaseCardmarketUriMeta,
        ),
      );
    }
    if (data.containsKey('purchase_cardhoarder_uri')) {
      context.handle(
        _purchaseCardhoarderUriMeta,
        purchaseCardhoarderUri.isAcceptableOrUnknown(
          data['purchase_cardhoarder_uri']!,
          _purchaseCardhoarderUriMeta,
        ),
      );
    }
    if (data.containsKey('card_back_id')) {
      context.handle(
        _cardBackIdMeta,
        cardBackId.isAcceptableOrUnknown(
          data['card_back_id']!,
          _cardBackIdMeta,
        ),
      );
    }
    if (data.containsKey('all_parts_json')) {
      context.handle(
        _allPartsJsonMeta,
        allPartsJson.isAcceptableOrUnknown(
          data['all_parts_json']!,
          _allPartsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scryfallId};
  @override
  ScryfallCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScryfallCard(
      scryfallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scryfall_id'],
      )!,
      oracleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oracle_id'],
      ),
      tcgplayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tcgplayer_id'],
      ),
      cardmarketId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cardmarket_id'],
      ),
      multiverseIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}multiverse_ids_json'],
      ),
      layout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      printedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printed_name'],
      ),
      flavorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_name'],
      ),
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      )!,
      setCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_code'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      setType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_type'],
      )!,
      setUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_uri'],
      )!,
      setSearchUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_search_uri'],
      )!,
      scryfallSetUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scryfall_set_uri'],
      )!,
      collectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_number'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      )!,
      rarityValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rarity_value'],
      )!,
      releasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}released_at'],
      )!,
      scryfallUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scryfall_uri'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      rulingsUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rulings_uri'],
      )!,
      printsSearchUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prints_search_uri'],
      )!,
      manaCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mana_cost'],
      ),
      typeLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_line'],
      )!,
      printedTypeLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printed_type_line'],
      ),
      oracleText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oracle_text'],
      ),
      printedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printed_text'],
      ),
      flavorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_text'],
      ),
      colorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colors_json'],
      ),
      colorMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_mask'],
      )!,
      colorIdentityJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_identity_json'],
      ),
      colorIdentityMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_identity_mask'],
      )!,
      producedManaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produced_mana_json'],
      ),
      producedManaMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produced_mana_mask'],
      )!,
      power: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}power'],
      ),
      toughness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toughness'],
      ),
      loyalty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loyalty'],
      ),
      defense: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}defense'],
      ),
      cmc: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cmc'],
      )!,
      keywordsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords_json'],
      ),
      hasCardFaces: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_card_faces'],
      )!,
      hasColorIndicator: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_color_indicator'],
      )!,
      borderColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}border_color'],
      ),
      frame: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame'],
      ),
      frameEffectsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame_effects_json'],
      ),
      securityStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}security_stamp'],
      ),
      highresImage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}highres_image'],
      )!,
      imageStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_status'],
      ),
      imageUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_updated_at'],
      ),
      imageSmall: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_small'],
      ),
      imageNormal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_normal'],
      ),
      imageLarge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_large'],
      ),
      imagePng: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_png'],
      ),
      imageArtCrop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_art_crop'],
      ),
      imageBorderCrop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_border_crop'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      artistIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_ids_json'],
      ),
      illustrationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}illustration_id'],
      ),
      watermark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watermark'],
      ),
      fullArt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}full_art'],
      )!,
      textless: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}textless'],
      )!,
      booster: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}booster'],
      )!,
      storySpotlight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}story_spotlight'],
      )!,
      promo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}promo'],
      )!,
      reprint: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reprint'],
      )!,
      variation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}variation'],
      )!,
      reserved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reserved'],
      )!,
      gameChanger: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}game_changer'],
      )!,
      oversized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}oversized'],
      )!,
      nonfoil: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nonfoil'],
      )!,
      foil: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}foil'],
      )!,
      etched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}etched'],
      )!,
      glossy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}glossy'],
      )!,
      paper: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paper'],
      )!,
      legalStandard: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_standard'],
      ),
      legalFuture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_future'],
      ),
      legalHistoric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_historic'],
      ),
      legalTimeless: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_timeless'],
      ),
      legalGladiator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_gladiator'],
      ),
      legalPioneer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_pioneer'],
      ),
      legalModern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_modern'],
      ),
      legalLegacy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_legacy'],
      ),
      legalPauper: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_pauper'],
      ),
      legalVintage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_vintage'],
      ),
      legalPenny: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_penny'],
      ),
      legalCommander: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_commander'],
      ),
      legalOathbreaker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_oathbreaker'],
      ),
      legalStandardBrawl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_standard_brawl'],
      ),
      legalBrawl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_brawl'],
      ),
      legalCompetitiveBrawl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_competitive_brawl'],
      ),
      legalAlchemy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_alchemy'],
      ),
      legalPauperCommander: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_pauper_commander'],
      ),
      legalDuel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_duel'],
      ),
      legalOldSchool: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_old_school'],
      ),
      legalPremodern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_premodern'],
      ),
      legalPredh: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_predh'],
      ),
      legalTlr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_tlr'],
      ),
      pricesUsd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prices_usd'],
      ),
      pricesUsdFoil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prices_usd_foil'],
      ),
      pricesUsdEtched: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prices_usd_etched'],
      ),
      pricesEur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prices_eur'],
      ),
      pricesEurFoil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prices_eur_foil'],
      ),
      pricesTix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prices_tix'],
      ),
      relatedGathererUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_gatherer_uri'],
      ),
      relatedTcgplayerInfiniteArticlesUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_tcgplayer_infinite_articles_uri'],
      ),
      relatedTcgplayerInfiniteDecksUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_tcgplayer_infinite_decks_uri'],
      ),
      relatedEdhrecUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_edhrec_uri'],
      ),
      purchaseTcgplayerUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_tcgplayer_uri'],
      ),
      purchaseCardmarketUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_cardmarket_uri'],
      ),
      purchaseCardhoarderUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_cardhoarder_uri'],
      ),
      cardBackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_back_id'],
      ),
      allPartsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}all_parts_json'],
      ),
    );
  }

  @override
  $ScryfallCardsTable createAlias(String alias) {
    return $ScryfallCardsTable(attachedDatabase, alias);
  }
}

class ScryfallCard extends DataClass implements Insertable<ScryfallCard> {
  final String scryfallId;
  final String? oracleId;
  final String? tcgplayerId;
  final String? cardmarketId;
  final String? multiverseIdsJson;
  final String layout;
  final String name;
  final String? printedName;
  final String? flavorName;
  final String setId;
  final String setCode;
  final String setName;
  final String setType;
  final String setUri;
  final String setSearchUri;
  final String scryfallSetUri;
  final String collectorNumber;
  final String lang;
  final String rarity;
  final int rarityValue;
  final String releasedAt;
  final String scryfallUri;
  final String uri;
  final String rulingsUri;
  final String printsSearchUri;
  final String? manaCost;
  final String typeLine;
  final String? printedTypeLine;
  final String? oracleText;
  final String? printedText;
  final String? flavorText;
  final String? colorsJson;
  final int colorMask;
  final String? colorIdentityJson;
  final int colorIdentityMask;
  final String? producedManaJson;
  final int producedManaMask;
  final String? power;
  final String? toughness;
  final String? loyalty;
  final String? defense;
  final double cmc;
  final String? keywordsJson;
  final bool hasCardFaces;
  final bool hasColorIndicator;
  final String? borderColor;
  final String? frame;
  final String? frameEffectsJson;
  final String? securityStamp;
  final bool highresImage;
  final String? imageStatus;
  final String? imageUpdatedAt;
  final String? imageSmall;
  final String? imageNormal;
  final String? imageLarge;
  final String? imagePng;
  final String? imageArtCrop;
  final String? imageBorderCrop;
  final String? artist;
  final String? artistIdsJson;
  final String? illustrationId;
  final String? watermark;
  final bool fullArt;
  final bool textless;
  final bool booster;
  final bool storySpotlight;
  final bool promo;
  final bool reprint;
  final bool variation;
  final bool reserved;
  final bool gameChanger;
  final bool oversized;
  final bool nonfoil;
  final bool foil;
  final bool etched;
  final bool glossy;
  final bool paper;
  final String? legalStandard;
  final String? legalFuture;
  final String? legalHistoric;
  final String? legalTimeless;
  final String? legalGladiator;
  final String? legalPioneer;
  final String? legalModern;
  final String? legalLegacy;
  final String? legalPauper;
  final String? legalVintage;
  final String? legalPenny;
  final String? legalCommander;
  final String? legalOathbreaker;
  final String? legalStandardBrawl;
  final String? legalBrawl;
  final String? legalCompetitiveBrawl;
  final String? legalAlchemy;
  final String? legalPauperCommander;
  final String? legalDuel;
  final String? legalOldSchool;
  final String? legalPremodern;
  final String? legalPredh;
  final String? legalTlr;
  final String? pricesUsd;
  final String? pricesUsdFoil;
  final String? pricesUsdEtched;
  final String? pricesEur;
  final String? pricesEurFoil;
  final String? pricesTix;
  final String? relatedGathererUri;
  final String? relatedTcgplayerInfiniteArticlesUri;
  final String? relatedTcgplayerInfiniteDecksUri;
  final String? relatedEdhrecUri;
  final String? purchaseTcgplayerUri;
  final String? purchaseCardmarketUri;
  final String? purchaseCardhoarderUri;
  final String? cardBackId;
  final String? allPartsJson;
  const ScryfallCard({
    required this.scryfallId,
    this.oracleId,
    this.tcgplayerId,
    this.cardmarketId,
    this.multiverseIdsJson,
    required this.layout,
    required this.name,
    this.printedName,
    this.flavorName,
    required this.setId,
    required this.setCode,
    required this.setName,
    required this.setType,
    required this.setUri,
    required this.setSearchUri,
    required this.scryfallSetUri,
    required this.collectorNumber,
    required this.lang,
    required this.rarity,
    required this.rarityValue,
    required this.releasedAt,
    required this.scryfallUri,
    required this.uri,
    required this.rulingsUri,
    required this.printsSearchUri,
    this.manaCost,
    required this.typeLine,
    this.printedTypeLine,
    this.oracleText,
    this.printedText,
    this.flavorText,
    this.colorsJson,
    required this.colorMask,
    this.colorIdentityJson,
    required this.colorIdentityMask,
    this.producedManaJson,
    required this.producedManaMask,
    this.power,
    this.toughness,
    this.loyalty,
    this.defense,
    required this.cmc,
    this.keywordsJson,
    required this.hasCardFaces,
    required this.hasColorIndicator,
    this.borderColor,
    this.frame,
    this.frameEffectsJson,
    this.securityStamp,
    required this.highresImage,
    this.imageStatus,
    this.imageUpdatedAt,
    this.imageSmall,
    this.imageNormal,
    this.imageLarge,
    this.imagePng,
    this.imageArtCrop,
    this.imageBorderCrop,
    this.artist,
    this.artistIdsJson,
    this.illustrationId,
    this.watermark,
    required this.fullArt,
    required this.textless,
    required this.booster,
    required this.storySpotlight,
    required this.promo,
    required this.reprint,
    required this.variation,
    required this.reserved,
    required this.gameChanger,
    required this.oversized,
    required this.nonfoil,
    required this.foil,
    required this.etched,
    required this.glossy,
    required this.paper,
    this.legalStandard,
    this.legalFuture,
    this.legalHistoric,
    this.legalTimeless,
    this.legalGladiator,
    this.legalPioneer,
    this.legalModern,
    this.legalLegacy,
    this.legalPauper,
    this.legalVintage,
    this.legalPenny,
    this.legalCommander,
    this.legalOathbreaker,
    this.legalStandardBrawl,
    this.legalBrawl,
    this.legalCompetitiveBrawl,
    this.legalAlchemy,
    this.legalPauperCommander,
    this.legalDuel,
    this.legalOldSchool,
    this.legalPremodern,
    this.legalPredh,
    this.legalTlr,
    this.pricesUsd,
    this.pricesUsdFoil,
    this.pricesUsdEtched,
    this.pricesEur,
    this.pricesEurFoil,
    this.pricesTix,
    this.relatedGathererUri,
    this.relatedTcgplayerInfiniteArticlesUri,
    this.relatedTcgplayerInfiniteDecksUri,
    this.relatedEdhrecUri,
    this.purchaseTcgplayerUri,
    this.purchaseCardmarketUri,
    this.purchaseCardhoarderUri,
    this.cardBackId,
    this.allPartsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scryfall_id'] = Variable<String>(scryfallId);
    if (!nullToAbsent || oracleId != null) {
      map['oracle_id'] = Variable<String>(oracleId);
    }
    if (!nullToAbsent || tcgplayerId != null) {
      map['tcgplayer_id'] = Variable<String>(tcgplayerId);
    }
    if (!nullToAbsent || cardmarketId != null) {
      map['cardmarket_id'] = Variable<String>(cardmarketId);
    }
    if (!nullToAbsent || multiverseIdsJson != null) {
      map['multiverse_ids_json'] = Variable<String>(multiverseIdsJson);
    }
    map['layout'] = Variable<String>(layout);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || printedName != null) {
      map['printed_name'] = Variable<String>(printedName);
    }
    if (!nullToAbsent || flavorName != null) {
      map['flavor_name'] = Variable<String>(flavorName);
    }
    map['set_id'] = Variable<String>(setId);
    map['set_code'] = Variable<String>(setCode);
    map['set_name'] = Variable<String>(setName);
    map['set_type'] = Variable<String>(setType);
    map['set_uri'] = Variable<String>(setUri);
    map['set_search_uri'] = Variable<String>(setSearchUri);
    map['scryfall_set_uri'] = Variable<String>(scryfallSetUri);
    map['collector_number'] = Variable<String>(collectorNumber);
    map['lang'] = Variable<String>(lang);
    map['rarity'] = Variable<String>(rarity);
    map['rarity_value'] = Variable<int>(rarityValue);
    map['released_at'] = Variable<String>(releasedAt);
    map['scryfall_uri'] = Variable<String>(scryfallUri);
    map['uri'] = Variable<String>(uri);
    map['rulings_uri'] = Variable<String>(rulingsUri);
    map['prints_search_uri'] = Variable<String>(printsSearchUri);
    if (!nullToAbsent || manaCost != null) {
      map['mana_cost'] = Variable<String>(manaCost);
    }
    map['type_line'] = Variable<String>(typeLine);
    if (!nullToAbsent || printedTypeLine != null) {
      map['printed_type_line'] = Variable<String>(printedTypeLine);
    }
    if (!nullToAbsent || oracleText != null) {
      map['oracle_text'] = Variable<String>(oracleText);
    }
    if (!nullToAbsent || printedText != null) {
      map['printed_text'] = Variable<String>(printedText);
    }
    if (!nullToAbsent || flavorText != null) {
      map['flavor_text'] = Variable<String>(flavorText);
    }
    if (!nullToAbsent || colorsJson != null) {
      map['colors_json'] = Variable<String>(colorsJson);
    }
    map['color_mask'] = Variable<int>(colorMask);
    if (!nullToAbsent || colorIdentityJson != null) {
      map['color_identity_json'] = Variable<String>(colorIdentityJson);
    }
    map['color_identity_mask'] = Variable<int>(colorIdentityMask);
    if (!nullToAbsent || producedManaJson != null) {
      map['produced_mana_json'] = Variable<String>(producedManaJson);
    }
    map['produced_mana_mask'] = Variable<int>(producedManaMask);
    if (!nullToAbsent || power != null) {
      map['power'] = Variable<String>(power);
    }
    if (!nullToAbsent || toughness != null) {
      map['toughness'] = Variable<String>(toughness);
    }
    if (!nullToAbsent || loyalty != null) {
      map['loyalty'] = Variable<String>(loyalty);
    }
    if (!nullToAbsent || defense != null) {
      map['defense'] = Variable<String>(defense);
    }
    map['cmc'] = Variable<double>(cmc);
    if (!nullToAbsent || keywordsJson != null) {
      map['keywords_json'] = Variable<String>(keywordsJson);
    }
    map['has_card_faces'] = Variable<bool>(hasCardFaces);
    map['has_color_indicator'] = Variable<bool>(hasColorIndicator);
    if (!nullToAbsent || borderColor != null) {
      map['border_color'] = Variable<String>(borderColor);
    }
    if (!nullToAbsent || frame != null) {
      map['frame'] = Variable<String>(frame);
    }
    if (!nullToAbsent || frameEffectsJson != null) {
      map['frame_effects_json'] = Variable<String>(frameEffectsJson);
    }
    if (!nullToAbsent || securityStamp != null) {
      map['security_stamp'] = Variable<String>(securityStamp);
    }
    map['highres_image'] = Variable<bool>(highresImage);
    if (!nullToAbsent || imageStatus != null) {
      map['image_status'] = Variable<String>(imageStatus);
    }
    if (!nullToAbsent || imageUpdatedAt != null) {
      map['image_updated_at'] = Variable<String>(imageUpdatedAt);
    }
    if (!nullToAbsent || imageSmall != null) {
      map['image_small'] = Variable<String>(imageSmall);
    }
    if (!nullToAbsent || imageNormal != null) {
      map['image_normal'] = Variable<String>(imageNormal);
    }
    if (!nullToAbsent || imageLarge != null) {
      map['image_large'] = Variable<String>(imageLarge);
    }
    if (!nullToAbsent || imagePng != null) {
      map['image_png'] = Variable<String>(imagePng);
    }
    if (!nullToAbsent || imageArtCrop != null) {
      map['image_art_crop'] = Variable<String>(imageArtCrop);
    }
    if (!nullToAbsent || imageBorderCrop != null) {
      map['image_border_crop'] = Variable<String>(imageBorderCrop);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || artistIdsJson != null) {
      map['artist_ids_json'] = Variable<String>(artistIdsJson);
    }
    if (!nullToAbsent || illustrationId != null) {
      map['illustration_id'] = Variable<String>(illustrationId);
    }
    if (!nullToAbsent || watermark != null) {
      map['watermark'] = Variable<String>(watermark);
    }
    map['full_art'] = Variable<bool>(fullArt);
    map['textless'] = Variable<bool>(textless);
    map['booster'] = Variable<bool>(booster);
    map['story_spotlight'] = Variable<bool>(storySpotlight);
    map['promo'] = Variable<bool>(promo);
    map['reprint'] = Variable<bool>(reprint);
    map['variation'] = Variable<bool>(variation);
    map['reserved'] = Variable<bool>(reserved);
    map['game_changer'] = Variable<bool>(gameChanger);
    map['oversized'] = Variable<bool>(oversized);
    map['nonfoil'] = Variable<bool>(nonfoil);
    map['foil'] = Variable<bool>(foil);
    map['etched'] = Variable<bool>(etched);
    map['glossy'] = Variable<bool>(glossy);
    map['paper'] = Variable<bool>(paper);
    if (!nullToAbsent || legalStandard != null) {
      map['legal_standard'] = Variable<String>(legalStandard);
    }
    if (!nullToAbsent || legalFuture != null) {
      map['legal_future'] = Variable<String>(legalFuture);
    }
    if (!nullToAbsent || legalHistoric != null) {
      map['legal_historic'] = Variable<String>(legalHistoric);
    }
    if (!nullToAbsent || legalTimeless != null) {
      map['legal_timeless'] = Variable<String>(legalTimeless);
    }
    if (!nullToAbsent || legalGladiator != null) {
      map['legal_gladiator'] = Variable<String>(legalGladiator);
    }
    if (!nullToAbsent || legalPioneer != null) {
      map['legal_pioneer'] = Variable<String>(legalPioneer);
    }
    if (!nullToAbsent || legalModern != null) {
      map['legal_modern'] = Variable<String>(legalModern);
    }
    if (!nullToAbsent || legalLegacy != null) {
      map['legal_legacy'] = Variable<String>(legalLegacy);
    }
    if (!nullToAbsent || legalPauper != null) {
      map['legal_pauper'] = Variable<String>(legalPauper);
    }
    if (!nullToAbsent || legalVintage != null) {
      map['legal_vintage'] = Variable<String>(legalVintage);
    }
    if (!nullToAbsent || legalPenny != null) {
      map['legal_penny'] = Variable<String>(legalPenny);
    }
    if (!nullToAbsent || legalCommander != null) {
      map['legal_commander'] = Variable<String>(legalCommander);
    }
    if (!nullToAbsent || legalOathbreaker != null) {
      map['legal_oathbreaker'] = Variable<String>(legalOathbreaker);
    }
    if (!nullToAbsent || legalStandardBrawl != null) {
      map['legal_standard_brawl'] = Variable<String>(legalStandardBrawl);
    }
    if (!nullToAbsent || legalBrawl != null) {
      map['legal_brawl'] = Variable<String>(legalBrawl);
    }
    if (!nullToAbsent || legalCompetitiveBrawl != null) {
      map['legal_competitive_brawl'] = Variable<String>(legalCompetitiveBrawl);
    }
    if (!nullToAbsent || legalAlchemy != null) {
      map['legal_alchemy'] = Variable<String>(legalAlchemy);
    }
    if (!nullToAbsent || legalPauperCommander != null) {
      map['legal_pauper_commander'] = Variable<String>(legalPauperCommander);
    }
    if (!nullToAbsent || legalDuel != null) {
      map['legal_duel'] = Variable<String>(legalDuel);
    }
    if (!nullToAbsent || legalOldSchool != null) {
      map['legal_old_school'] = Variable<String>(legalOldSchool);
    }
    if (!nullToAbsent || legalPremodern != null) {
      map['legal_premodern'] = Variable<String>(legalPremodern);
    }
    if (!nullToAbsent || legalPredh != null) {
      map['legal_predh'] = Variable<String>(legalPredh);
    }
    if (!nullToAbsent || legalTlr != null) {
      map['legal_tlr'] = Variable<String>(legalTlr);
    }
    if (!nullToAbsent || pricesUsd != null) {
      map['prices_usd'] = Variable<String>(pricesUsd);
    }
    if (!nullToAbsent || pricesUsdFoil != null) {
      map['prices_usd_foil'] = Variable<String>(pricesUsdFoil);
    }
    if (!nullToAbsent || pricesUsdEtched != null) {
      map['prices_usd_etched'] = Variable<String>(pricesUsdEtched);
    }
    if (!nullToAbsent || pricesEur != null) {
      map['prices_eur'] = Variable<String>(pricesEur);
    }
    if (!nullToAbsent || pricesEurFoil != null) {
      map['prices_eur_foil'] = Variable<String>(pricesEurFoil);
    }
    if (!nullToAbsent || pricesTix != null) {
      map['prices_tix'] = Variable<String>(pricesTix);
    }
    if (!nullToAbsent || relatedGathererUri != null) {
      map['related_gatherer_uri'] = Variable<String>(relatedGathererUri);
    }
    if (!nullToAbsent || relatedTcgplayerInfiniteArticlesUri != null) {
      map['related_tcgplayer_infinite_articles_uri'] = Variable<String>(
        relatedTcgplayerInfiniteArticlesUri,
      );
    }
    if (!nullToAbsent || relatedTcgplayerInfiniteDecksUri != null) {
      map['related_tcgplayer_infinite_decks_uri'] = Variable<String>(
        relatedTcgplayerInfiniteDecksUri,
      );
    }
    if (!nullToAbsent || relatedEdhrecUri != null) {
      map['related_edhrec_uri'] = Variable<String>(relatedEdhrecUri);
    }
    if (!nullToAbsent || purchaseTcgplayerUri != null) {
      map['purchase_tcgplayer_uri'] = Variable<String>(purchaseTcgplayerUri);
    }
    if (!nullToAbsent || purchaseCardmarketUri != null) {
      map['purchase_cardmarket_uri'] = Variable<String>(purchaseCardmarketUri);
    }
    if (!nullToAbsent || purchaseCardhoarderUri != null) {
      map['purchase_cardhoarder_uri'] = Variable<String>(
        purchaseCardhoarderUri,
      );
    }
    if (!nullToAbsent || cardBackId != null) {
      map['card_back_id'] = Variable<String>(cardBackId);
    }
    if (!nullToAbsent || allPartsJson != null) {
      map['all_parts_json'] = Variable<String>(allPartsJson);
    }
    return map;
  }

  ScryfallCardsCompanion toCompanion(bool nullToAbsent) {
    return ScryfallCardsCompanion(
      scryfallId: Value(scryfallId),
      oracleId: oracleId == null && nullToAbsent
          ? const Value.absent()
          : Value(oracleId),
      tcgplayerId: tcgplayerId == null && nullToAbsent
          ? const Value.absent()
          : Value(tcgplayerId),
      cardmarketId: cardmarketId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardmarketId),
      multiverseIdsJson: multiverseIdsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(multiverseIdsJson),
      layout: Value(layout),
      name: Value(name),
      printedName: printedName == null && nullToAbsent
          ? const Value.absent()
          : Value(printedName),
      flavorName: flavorName == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorName),
      setId: Value(setId),
      setCode: Value(setCode),
      setName: Value(setName),
      setType: Value(setType),
      setUri: Value(setUri),
      setSearchUri: Value(setSearchUri),
      scryfallSetUri: Value(scryfallSetUri),
      collectorNumber: Value(collectorNumber),
      lang: Value(lang),
      rarity: Value(rarity),
      rarityValue: Value(rarityValue),
      releasedAt: Value(releasedAt),
      scryfallUri: Value(scryfallUri),
      uri: Value(uri),
      rulingsUri: Value(rulingsUri),
      printsSearchUri: Value(printsSearchUri),
      manaCost: manaCost == null && nullToAbsent
          ? const Value.absent()
          : Value(manaCost),
      typeLine: Value(typeLine),
      printedTypeLine: printedTypeLine == null && nullToAbsent
          ? const Value.absent()
          : Value(printedTypeLine),
      oracleText: oracleText == null && nullToAbsent
          ? const Value.absent()
          : Value(oracleText),
      printedText: printedText == null && nullToAbsent
          ? const Value.absent()
          : Value(printedText),
      flavorText: flavorText == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorText),
      colorsJson: colorsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(colorsJson),
      colorMask: Value(colorMask),
      colorIdentityJson: colorIdentityJson == null && nullToAbsent
          ? const Value.absent()
          : Value(colorIdentityJson),
      colorIdentityMask: Value(colorIdentityMask),
      producedManaJson: producedManaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(producedManaJson),
      producedManaMask: Value(producedManaMask),
      power: power == null && nullToAbsent
          ? const Value.absent()
          : Value(power),
      toughness: toughness == null && nullToAbsent
          ? const Value.absent()
          : Value(toughness),
      loyalty: loyalty == null && nullToAbsent
          ? const Value.absent()
          : Value(loyalty),
      defense: defense == null && nullToAbsent
          ? const Value.absent()
          : Value(defense),
      cmc: Value(cmc),
      keywordsJson: keywordsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(keywordsJson),
      hasCardFaces: Value(hasCardFaces),
      hasColorIndicator: Value(hasColorIndicator),
      borderColor: borderColor == null && nullToAbsent
          ? const Value.absent()
          : Value(borderColor),
      frame: frame == null && nullToAbsent
          ? const Value.absent()
          : Value(frame),
      frameEffectsJson: frameEffectsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(frameEffectsJson),
      securityStamp: securityStamp == null && nullToAbsent
          ? const Value.absent()
          : Value(securityStamp),
      highresImage: Value(highresImage),
      imageStatus: imageStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(imageStatus),
      imageUpdatedAt: imageUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUpdatedAt),
      imageSmall: imageSmall == null && nullToAbsent
          ? const Value.absent()
          : Value(imageSmall),
      imageNormal: imageNormal == null && nullToAbsent
          ? const Value.absent()
          : Value(imageNormal),
      imageLarge: imageLarge == null && nullToAbsent
          ? const Value.absent()
          : Value(imageLarge),
      imagePng: imagePng == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePng),
      imageArtCrop: imageArtCrop == null && nullToAbsent
          ? const Value.absent()
          : Value(imageArtCrop),
      imageBorderCrop: imageBorderCrop == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBorderCrop),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      artistIdsJson: artistIdsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(artistIdsJson),
      illustrationId: illustrationId == null && nullToAbsent
          ? const Value.absent()
          : Value(illustrationId),
      watermark: watermark == null && nullToAbsent
          ? const Value.absent()
          : Value(watermark),
      fullArt: Value(fullArt),
      textless: Value(textless),
      booster: Value(booster),
      storySpotlight: Value(storySpotlight),
      promo: Value(promo),
      reprint: Value(reprint),
      variation: Value(variation),
      reserved: Value(reserved),
      gameChanger: Value(gameChanger),
      oversized: Value(oversized),
      nonfoil: Value(nonfoil),
      foil: Value(foil),
      etched: Value(etched),
      glossy: Value(glossy),
      paper: Value(paper),
      legalStandard: legalStandard == null && nullToAbsent
          ? const Value.absent()
          : Value(legalStandard),
      legalFuture: legalFuture == null && nullToAbsent
          ? const Value.absent()
          : Value(legalFuture),
      legalHistoric: legalHistoric == null && nullToAbsent
          ? const Value.absent()
          : Value(legalHistoric),
      legalTimeless: legalTimeless == null && nullToAbsent
          ? const Value.absent()
          : Value(legalTimeless),
      legalGladiator: legalGladiator == null && nullToAbsent
          ? const Value.absent()
          : Value(legalGladiator),
      legalPioneer: legalPioneer == null && nullToAbsent
          ? const Value.absent()
          : Value(legalPioneer),
      legalModern: legalModern == null && nullToAbsent
          ? const Value.absent()
          : Value(legalModern),
      legalLegacy: legalLegacy == null && nullToAbsent
          ? const Value.absent()
          : Value(legalLegacy),
      legalPauper: legalPauper == null && nullToAbsent
          ? const Value.absent()
          : Value(legalPauper),
      legalVintage: legalVintage == null && nullToAbsent
          ? const Value.absent()
          : Value(legalVintage),
      legalPenny: legalPenny == null && nullToAbsent
          ? const Value.absent()
          : Value(legalPenny),
      legalCommander: legalCommander == null && nullToAbsent
          ? const Value.absent()
          : Value(legalCommander),
      legalOathbreaker: legalOathbreaker == null && nullToAbsent
          ? const Value.absent()
          : Value(legalOathbreaker),
      legalStandardBrawl: legalStandardBrawl == null && nullToAbsent
          ? const Value.absent()
          : Value(legalStandardBrawl),
      legalBrawl: legalBrawl == null && nullToAbsent
          ? const Value.absent()
          : Value(legalBrawl),
      legalCompetitiveBrawl: legalCompetitiveBrawl == null && nullToAbsent
          ? const Value.absent()
          : Value(legalCompetitiveBrawl),
      legalAlchemy: legalAlchemy == null && nullToAbsent
          ? const Value.absent()
          : Value(legalAlchemy),
      legalPauperCommander: legalPauperCommander == null && nullToAbsent
          ? const Value.absent()
          : Value(legalPauperCommander),
      legalDuel: legalDuel == null && nullToAbsent
          ? const Value.absent()
          : Value(legalDuel),
      legalOldSchool: legalOldSchool == null && nullToAbsent
          ? const Value.absent()
          : Value(legalOldSchool),
      legalPremodern: legalPremodern == null && nullToAbsent
          ? const Value.absent()
          : Value(legalPremodern),
      legalPredh: legalPredh == null && nullToAbsent
          ? const Value.absent()
          : Value(legalPredh),
      legalTlr: legalTlr == null && nullToAbsent
          ? const Value.absent()
          : Value(legalTlr),
      pricesUsd: pricesUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(pricesUsd),
      pricesUsdFoil: pricesUsdFoil == null && nullToAbsent
          ? const Value.absent()
          : Value(pricesUsdFoil),
      pricesUsdEtched: pricesUsdEtched == null && nullToAbsent
          ? const Value.absent()
          : Value(pricesUsdEtched),
      pricesEur: pricesEur == null && nullToAbsent
          ? const Value.absent()
          : Value(pricesEur),
      pricesEurFoil: pricesEurFoil == null && nullToAbsent
          ? const Value.absent()
          : Value(pricesEurFoil),
      pricesTix: pricesTix == null && nullToAbsent
          ? const Value.absent()
          : Value(pricesTix),
      relatedGathererUri: relatedGathererUri == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedGathererUri),
      relatedTcgplayerInfiniteArticlesUri:
          relatedTcgplayerInfiniteArticlesUri == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedTcgplayerInfiniteArticlesUri),
      relatedTcgplayerInfiniteDecksUri:
          relatedTcgplayerInfiniteDecksUri == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedTcgplayerInfiniteDecksUri),
      relatedEdhrecUri: relatedEdhrecUri == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEdhrecUri),
      purchaseTcgplayerUri: purchaseTcgplayerUri == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseTcgplayerUri),
      purchaseCardmarketUri: purchaseCardmarketUri == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseCardmarketUri),
      purchaseCardhoarderUri: purchaseCardhoarderUri == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseCardhoarderUri),
      cardBackId: cardBackId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardBackId),
      allPartsJson: allPartsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(allPartsJson),
    );
  }

  factory ScryfallCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScryfallCard(
      scryfallId: serializer.fromJson<String>(json['scryfallId']),
      oracleId: serializer.fromJson<String?>(json['oracleId']),
      tcgplayerId: serializer.fromJson<String?>(json['tcgplayerId']),
      cardmarketId: serializer.fromJson<String?>(json['cardmarketId']),
      multiverseIdsJson: serializer.fromJson<String?>(
        json['multiverseIdsJson'],
      ),
      layout: serializer.fromJson<String>(json['layout']),
      name: serializer.fromJson<String>(json['name']),
      printedName: serializer.fromJson<String?>(json['printedName']),
      flavorName: serializer.fromJson<String?>(json['flavorName']),
      setId: serializer.fromJson<String>(json['setId']),
      setCode: serializer.fromJson<String>(json['setCode']),
      setName: serializer.fromJson<String>(json['setName']),
      setType: serializer.fromJson<String>(json['setType']),
      setUri: serializer.fromJson<String>(json['setUri']),
      setSearchUri: serializer.fromJson<String>(json['setSearchUri']),
      scryfallSetUri: serializer.fromJson<String>(json['scryfallSetUri']),
      collectorNumber: serializer.fromJson<String>(json['collectorNumber']),
      lang: serializer.fromJson<String>(json['lang']),
      rarity: serializer.fromJson<String>(json['rarity']),
      rarityValue: serializer.fromJson<int>(json['rarityValue']),
      releasedAt: serializer.fromJson<String>(json['releasedAt']),
      scryfallUri: serializer.fromJson<String>(json['scryfallUri']),
      uri: serializer.fromJson<String>(json['uri']),
      rulingsUri: serializer.fromJson<String>(json['rulingsUri']),
      printsSearchUri: serializer.fromJson<String>(json['printsSearchUri']),
      manaCost: serializer.fromJson<String?>(json['manaCost']),
      typeLine: serializer.fromJson<String>(json['typeLine']),
      printedTypeLine: serializer.fromJson<String?>(json['printedTypeLine']),
      oracleText: serializer.fromJson<String?>(json['oracleText']),
      printedText: serializer.fromJson<String?>(json['printedText']),
      flavorText: serializer.fromJson<String?>(json['flavorText']),
      colorsJson: serializer.fromJson<String?>(json['colorsJson']),
      colorMask: serializer.fromJson<int>(json['colorMask']),
      colorIdentityJson: serializer.fromJson<String?>(
        json['colorIdentityJson'],
      ),
      colorIdentityMask: serializer.fromJson<int>(json['colorIdentityMask']),
      producedManaJson: serializer.fromJson<String?>(json['producedManaJson']),
      producedManaMask: serializer.fromJson<int>(json['producedManaMask']),
      power: serializer.fromJson<String?>(json['power']),
      toughness: serializer.fromJson<String?>(json['toughness']),
      loyalty: serializer.fromJson<String?>(json['loyalty']),
      defense: serializer.fromJson<String?>(json['defense']),
      cmc: serializer.fromJson<double>(json['cmc']),
      keywordsJson: serializer.fromJson<String?>(json['keywordsJson']),
      hasCardFaces: serializer.fromJson<bool>(json['hasCardFaces']),
      hasColorIndicator: serializer.fromJson<bool>(json['hasColorIndicator']),
      borderColor: serializer.fromJson<String?>(json['borderColor']),
      frame: serializer.fromJson<String?>(json['frame']),
      frameEffectsJson: serializer.fromJson<String?>(json['frameEffectsJson']),
      securityStamp: serializer.fromJson<String?>(json['securityStamp']),
      highresImage: serializer.fromJson<bool>(json['highresImage']),
      imageStatus: serializer.fromJson<String?>(json['imageStatus']),
      imageUpdatedAt: serializer.fromJson<String?>(json['imageUpdatedAt']),
      imageSmall: serializer.fromJson<String?>(json['imageSmall']),
      imageNormal: serializer.fromJson<String?>(json['imageNormal']),
      imageLarge: serializer.fromJson<String?>(json['imageLarge']),
      imagePng: serializer.fromJson<String?>(json['imagePng']),
      imageArtCrop: serializer.fromJson<String?>(json['imageArtCrop']),
      imageBorderCrop: serializer.fromJson<String?>(json['imageBorderCrop']),
      artist: serializer.fromJson<String?>(json['artist']),
      artistIdsJson: serializer.fromJson<String?>(json['artistIdsJson']),
      illustrationId: serializer.fromJson<String?>(json['illustrationId']),
      watermark: serializer.fromJson<String?>(json['watermark']),
      fullArt: serializer.fromJson<bool>(json['fullArt']),
      textless: serializer.fromJson<bool>(json['textless']),
      booster: serializer.fromJson<bool>(json['booster']),
      storySpotlight: serializer.fromJson<bool>(json['storySpotlight']),
      promo: serializer.fromJson<bool>(json['promo']),
      reprint: serializer.fromJson<bool>(json['reprint']),
      variation: serializer.fromJson<bool>(json['variation']),
      reserved: serializer.fromJson<bool>(json['reserved']),
      gameChanger: serializer.fromJson<bool>(json['gameChanger']),
      oversized: serializer.fromJson<bool>(json['oversized']),
      nonfoil: serializer.fromJson<bool>(json['nonfoil']),
      foil: serializer.fromJson<bool>(json['foil']),
      etched: serializer.fromJson<bool>(json['etched']),
      glossy: serializer.fromJson<bool>(json['glossy']),
      paper: serializer.fromJson<bool>(json['paper']),
      legalStandard: serializer.fromJson<String?>(json['legalStandard']),
      legalFuture: serializer.fromJson<String?>(json['legalFuture']),
      legalHistoric: serializer.fromJson<String?>(json['legalHistoric']),
      legalTimeless: serializer.fromJson<String?>(json['legalTimeless']),
      legalGladiator: serializer.fromJson<String?>(json['legalGladiator']),
      legalPioneer: serializer.fromJson<String?>(json['legalPioneer']),
      legalModern: serializer.fromJson<String?>(json['legalModern']),
      legalLegacy: serializer.fromJson<String?>(json['legalLegacy']),
      legalPauper: serializer.fromJson<String?>(json['legalPauper']),
      legalVintage: serializer.fromJson<String?>(json['legalVintage']),
      legalPenny: serializer.fromJson<String?>(json['legalPenny']),
      legalCommander: serializer.fromJson<String?>(json['legalCommander']),
      legalOathbreaker: serializer.fromJson<String?>(json['legalOathbreaker']),
      legalStandardBrawl: serializer.fromJson<String?>(
        json['legalStandardBrawl'],
      ),
      legalBrawl: serializer.fromJson<String?>(json['legalBrawl']),
      legalCompetitiveBrawl: serializer.fromJson<String?>(
        json['legalCompetitiveBrawl'],
      ),
      legalAlchemy: serializer.fromJson<String?>(json['legalAlchemy']),
      legalPauperCommander: serializer.fromJson<String?>(
        json['legalPauperCommander'],
      ),
      legalDuel: serializer.fromJson<String?>(json['legalDuel']),
      legalOldSchool: serializer.fromJson<String?>(json['legalOldSchool']),
      legalPremodern: serializer.fromJson<String?>(json['legalPremodern']),
      legalPredh: serializer.fromJson<String?>(json['legalPredh']),
      legalTlr: serializer.fromJson<String?>(json['legalTlr']),
      pricesUsd: serializer.fromJson<String?>(json['pricesUsd']),
      pricesUsdFoil: serializer.fromJson<String?>(json['pricesUsdFoil']),
      pricesUsdEtched: serializer.fromJson<String?>(json['pricesUsdEtched']),
      pricesEur: serializer.fromJson<String?>(json['pricesEur']),
      pricesEurFoil: serializer.fromJson<String?>(json['pricesEurFoil']),
      pricesTix: serializer.fromJson<String?>(json['pricesTix']),
      relatedGathererUri: serializer.fromJson<String?>(
        json['relatedGathererUri'],
      ),
      relatedTcgplayerInfiniteArticlesUri: serializer.fromJson<String?>(
        json['relatedTcgplayerInfiniteArticlesUri'],
      ),
      relatedTcgplayerInfiniteDecksUri: serializer.fromJson<String?>(
        json['relatedTcgplayerInfiniteDecksUri'],
      ),
      relatedEdhrecUri: serializer.fromJson<String?>(json['relatedEdhrecUri']),
      purchaseTcgplayerUri: serializer.fromJson<String?>(
        json['purchaseTcgplayerUri'],
      ),
      purchaseCardmarketUri: serializer.fromJson<String?>(
        json['purchaseCardmarketUri'],
      ),
      purchaseCardhoarderUri: serializer.fromJson<String?>(
        json['purchaseCardhoarderUri'],
      ),
      cardBackId: serializer.fromJson<String?>(json['cardBackId']),
      allPartsJson: serializer.fromJson<String?>(json['allPartsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scryfallId': serializer.toJson<String>(scryfallId),
      'oracleId': serializer.toJson<String?>(oracleId),
      'tcgplayerId': serializer.toJson<String?>(tcgplayerId),
      'cardmarketId': serializer.toJson<String?>(cardmarketId),
      'multiverseIdsJson': serializer.toJson<String?>(multiverseIdsJson),
      'layout': serializer.toJson<String>(layout),
      'name': serializer.toJson<String>(name),
      'printedName': serializer.toJson<String?>(printedName),
      'flavorName': serializer.toJson<String?>(flavorName),
      'setId': serializer.toJson<String>(setId),
      'setCode': serializer.toJson<String>(setCode),
      'setName': serializer.toJson<String>(setName),
      'setType': serializer.toJson<String>(setType),
      'setUri': serializer.toJson<String>(setUri),
      'setSearchUri': serializer.toJson<String>(setSearchUri),
      'scryfallSetUri': serializer.toJson<String>(scryfallSetUri),
      'collectorNumber': serializer.toJson<String>(collectorNumber),
      'lang': serializer.toJson<String>(lang),
      'rarity': serializer.toJson<String>(rarity),
      'rarityValue': serializer.toJson<int>(rarityValue),
      'releasedAt': serializer.toJson<String>(releasedAt),
      'scryfallUri': serializer.toJson<String>(scryfallUri),
      'uri': serializer.toJson<String>(uri),
      'rulingsUri': serializer.toJson<String>(rulingsUri),
      'printsSearchUri': serializer.toJson<String>(printsSearchUri),
      'manaCost': serializer.toJson<String?>(manaCost),
      'typeLine': serializer.toJson<String>(typeLine),
      'printedTypeLine': serializer.toJson<String?>(printedTypeLine),
      'oracleText': serializer.toJson<String?>(oracleText),
      'printedText': serializer.toJson<String?>(printedText),
      'flavorText': serializer.toJson<String?>(flavorText),
      'colorsJson': serializer.toJson<String?>(colorsJson),
      'colorMask': serializer.toJson<int>(colorMask),
      'colorIdentityJson': serializer.toJson<String?>(colorIdentityJson),
      'colorIdentityMask': serializer.toJson<int>(colorIdentityMask),
      'producedManaJson': serializer.toJson<String?>(producedManaJson),
      'producedManaMask': serializer.toJson<int>(producedManaMask),
      'power': serializer.toJson<String?>(power),
      'toughness': serializer.toJson<String?>(toughness),
      'loyalty': serializer.toJson<String?>(loyalty),
      'defense': serializer.toJson<String?>(defense),
      'cmc': serializer.toJson<double>(cmc),
      'keywordsJson': serializer.toJson<String?>(keywordsJson),
      'hasCardFaces': serializer.toJson<bool>(hasCardFaces),
      'hasColorIndicator': serializer.toJson<bool>(hasColorIndicator),
      'borderColor': serializer.toJson<String?>(borderColor),
      'frame': serializer.toJson<String?>(frame),
      'frameEffectsJson': serializer.toJson<String?>(frameEffectsJson),
      'securityStamp': serializer.toJson<String?>(securityStamp),
      'highresImage': serializer.toJson<bool>(highresImage),
      'imageStatus': serializer.toJson<String?>(imageStatus),
      'imageUpdatedAt': serializer.toJson<String?>(imageUpdatedAt),
      'imageSmall': serializer.toJson<String?>(imageSmall),
      'imageNormal': serializer.toJson<String?>(imageNormal),
      'imageLarge': serializer.toJson<String?>(imageLarge),
      'imagePng': serializer.toJson<String?>(imagePng),
      'imageArtCrop': serializer.toJson<String?>(imageArtCrop),
      'imageBorderCrop': serializer.toJson<String?>(imageBorderCrop),
      'artist': serializer.toJson<String?>(artist),
      'artistIdsJson': serializer.toJson<String?>(artistIdsJson),
      'illustrationId': serializer.toJson<String?>(illustrationId),
      'watermark': serializer.toJson<String?>(watermark),
      'fullArt': serializer.toJson<bool>(fullArt),
      'textless': serializer.toJson<bool>(textless),
      'booster': serializer.toJson<bool>(booster),
      'storySpotlight': serializer.toJson<bool>(storySpotlight),
      'promo': serializer.toJson<bool>(promo),
      'reprint': serializer.toJson<bool>(reprint),
      'variation': serializer.toJson<bool>(variation),
      'reserved': serializer.toJson<bool>(reserved),
      'gameChanger': serializer.toJson<bool>(gameChanger),
      'oversized': serializer.toJson<bool>(oversized),
      'nonfoil': serializer.toJson<bool>(nonfoil),
      'foil': serializer.toJson<bool>(foil),
      'etched': serializer.toJson<bool>(etched),
      'glossy': serializer.toJson<bool>(glossy),
      'paper': serializer.toJson<bool>(paper),
      'legalStandard': serializer.toJson<String?>(legalStandard),
      'legalFuture': serializer.toJson<String?>(legalFuture),
      'legalHistoric': serializer.toJson<String?>(legalHistoric),
      'legalTimeless': serializer.toJson<String?>(legalTimeless),
      'legalGladiator': serializer.toJson<String?>(legalGladiator),
      'legalPioneer': serializer.toJson<String?>(legalPioneer),
      'legalModern': serializer.toJson<String?>(legalModern),
      'legalLegacy': serializer.toJson<String?>(legalLegacy),
      'legalPauper': serializer.toJson<String?>(legalPauper),
      'legalVintage': serializer.toJson<String?>(legalVintage),
      'legalPenny': serializer.toJson<String?>(legalPenny),
      'legalCommander': serializer.toJson<String?>(legalCommander),
      'legalOathbreaker': serializer.toJson<String?>(legalOathbreaker),
      'legalStandardBrawl': serializer.toJson<String?>(legalStandardBrawl),
      'legalBrawl': serializer.toJson<String?>(legalBrawl),
      'legalCompetitiveBrawl': serializer.toJson<String?>(
        legalCompetitiveBrawl,
      ),
      'legalAlchemy': serializer.toJson<String?>(legalAlchemy),
      'legalPauperCommander': serializer.toJson<String?>(legalPauperCommander),
      'legalDuel': serializer.toJson<String?>(legalDuel),
      'legalOldSchool': serializer.toJson<String?>(legalOldSchool),
      'legalPremodern': serializer.toJson<String?>(legalPremodern),
      'legalPredh': serializer.toJson<String?>(legalPredh),
      'legalTlr': serializer.toJson<String?>(legalTlr),
      'pricesUsd': serializer.toJson<String?>(pricesUsd),
      'pricesUsdFoil': serializer.toJson<String?>(pricesUsdFoil),
      'pricesUsdEtched': serializer.toJson<String?>(pricesUsdEtched),
      'pricesEur': serializer.toJson<String?>(pricesEur),
      'pricesEurFoil': serializer.toJson<String?>(pricesEurFoil),
      'pricesTix': serializer.toJson<String?>(pricesTix),
      'relatedGathererUri': serializer.toJson<String?>(relatedGathererUri),
      'relatedTcgplayerInfiniteArticlesUri': serializer.toJson<String?>(
        relatedTcgplayerInfiniteArticlesUri,
      ),
      'relatedTcgplayerInfiniteDecksUri': serializer.toJson<String?>(
        relatedTcgplayerInfiniteDecksUri,
      ),
      'relatedEdhrecUri': serializer.toJson<String?>(relatedEdhrecUri),
      'purchaseTcgplayerUri': serializer.toJson<String?>(purchaseTcgplayerUri),
      'purchaseCardmarketUri': serializer.toJson<String?>(
        purchaseCardmarketUri,
      ),
      'purchaseCardhoarderUri': serializer.toJson<String?>(
        purchaseCardhoarderUri,
      ),
      'cardBackId': serializer.toJson<String?>(cardBackId),
      'allPartsJson': serializer.toJson<String?>(allPartsJson),
    };
  }

  ScryfallCard copyWith({
    String? scryfallId,
    Value<String?> oracleId = const Value.absent(),
    Value<String?> tcgplayerId = const Value.absent(),
    Value<String?> cardmarketId = const Value.absent(),
    Value<String?> multiverseIdsJson = const Value.absent(),
    String? layout,
    String? name,
    Value<String?> printedName = const Value.absent(),
    Value<String?> flavorName = const Value.absent(),
    String? setId,
    String? setCode,
    String? setName,
    String? setType,
    String? setUri,
    String? setSearchUri,
    String? scryfallSetUri,
    String? collectorNumber,
    String? lang,
    String? rarity,
    int? rarityValue,
    String? releasedAt,
    String? scryfallUri,
    String? uri,
    String? rulingsUri,
    String? printsSearchUri,
    Value<String?> manaCost = const Value.absent(),
    String? typeLine,
    Value<String?> printedTypeLine = const Value.absent(),
    Value<String?> oracleText = const Value.absent(),
    Value<String?> printedText = const Value.absent(),
    Value<String?> flavorText = const Value.absent(),
    Value<String?> colorsJson = const Value.absent(),
    int? colorMask,
    Value<String?> colorIdentityJson = const Value.absent(),
    int? colorIdentityMask,
    Value<String?> producedManaJson = const Value.absent(),
    int? producedManaMask,
    Value<String?> power = const Value.absent(),
    Value<String?> toughness = const Value.absent(),
    Value<String?> loyalty = const Value.absent(),
    Value<String?> defense = const Value.absent(),
    double? cmc,
    Value<String?> keywordsJson = const Value.absent(),
    bool? hasCardFaces,
    bool? hasColorIndicator,
    Value<String?> borderColor = const Value.absent(),
    Value<String?> frame = const Value.absent(),
    Value<String?> frameEffectsJson = const Value.absent(),
    Value<String?> securityStamp = const Value.absent(),
    bool? highresImage,
    Value<String?> imageStatus = const Value.absent(),
    Value<String?> imageUpdatedAt = const Value.absent(),
    Value<String?> imageSmall = const Value.absent(),
    Value<String?> imageNormal = const Value.absent(),
    Value<String?> imageLarge = const Value.absent(),
    Value<String?> imagePng = const Value.absent(),
    Value<String?> imageArtCrop = const Value.absent(),
    Value<String?> imageBorderCrop = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<String?> artistIdsJson = const Value.absent(),
    Value<String?> illustrationId = const Value.absent(),
    Value<String?> watermark = const Value.absent(),
    bool? fullArt,
    bool? textless,
    bool? booster,
    bool? storySpotlight,
    bool? promo,
    bool? reprint,
    bool? variation,
    bool? reserved,
    bool? gameChanger,
    bool? oversized,
    bool? nonfoil,
    bool? foil,
    bool? etched,
    bool? glossy,
    bool? paper,
    Value<String?> legalStandard = const Value.absent(),
    Value<String?> legalFuture = const Value.absent(),
    Value<String?> legalHistoric = const Value.absent(),
    Value<String?> legalTimeless = const Value.absent(),
    Value<String?> legalGladiator = const Value.absent(),
    Value<String?> legalPioneer = const Value.absent(),
    Value<String?> legalModern = const Value.absent(),
    Value<String?> legalLegacy = const Value.absent(),
    Value<String?> legalPauper = const Value.absent(),
    Value<String?> legalVintage = const Value.absent(),
    Value<String?> legalPenny = const Value.absent(),
    Value<String?> legalCommander = const Value.absent(),
    Value<String?> legalOathbreaker = const Value.absent(),
    Value<String?> legalStandardBrawl = const Value.absent(),
    Value<String?> legalBrawl = const Value.absent(),
    Value<String?> legalCompetitiveBrawl = const Value.absent(),
    Value<String?> legalAlchemy = const Value.absent(),
    Value<String?> legalPauperCommander = const Value.absent(),
    Value<String?> legalDuel = const Value.absent(),
    Value<String?> legalOldSchool = const Value.absent(),
    Value<String?> legalPremodern = const Value.absent(),
    Value<String?> legalPredh = const Value.absent(),
    Value<String?> legalTlr = const Value.absent(),
    Value<String?> pricesUsd = const Value.absent(),
    Value<String?> pricesUsdFoil = const Value.absent(),
    Value<String?> pricesUsdEtched = const Value.absent(),
    Value<String?> pricesEur = const Value.absent(),
    Value<String?> pricesEurFoil = const Value.absent(),
    Value<String?> pricesTix = const Value.absent(),
    Value<String?> relatedGathererUri = const Value.absent(),
    Value<String?> relatedTcgplayerInfiniteArticlesUri = const Value.absent(),
    Value<String?> relatedTcgplayerInfiniteDecksUri = const Value.absent(),
    Value<String?> relatedEdhrecUri = const Value.absent(),
    Value<String?> purchaseTcgplayerUri = const Value.absent(),
    Value<String?> purchaseCardmarketUri = const Value.absent(),
    Value<String?> purchaseCardhoarderUri = const Value.absent(),
    Value<String?> cardBackId = const Value.absent(),
    Value<String?> allPartsJson = const Value.absent(),
  }) => ScryfallCard(
    scryfallId: scryfallId ?? this.scryfallId,
    oracleId: oracleId.present ? oracleId.value : this.oracleId,
    tcgplayerId: tcgplayerId.present ? tcgplayerId.value : this.tcgplayerId,
    cardmarketId: cardmarketId.present ? cardmarketId.value : this.cardmarketId,
    multiverseIdsJson: multiverseIdsJson.present
        ? multiverseIdsJson.value
        : this.multiverseIdsJson,
    layout: layout ?? this.layout,
    name: name ?? this.name,
    printedName: printedName.present ? printedName.value : this.printedName,
    flavorName: flavorName.present ? flavorName.value : this.flavorName,
    setId: setId ?? this.setId,
    setCode: setCode ?? this.setCode,
    setName: setName ?? this.setName,
    setType: setType ?? this.setType,
    setUri: setUri ?? this.setUri,
    setSearchUri: setSearchUri ?? this.setSearchUri,
    scryfallSetUri: scryfallSetUri ?? this.scryfallSetUri,
    collectorNumber: collectorNumber ?? this.collectorNumber,
    lang: lang ?? this.lang,
    rarity: rarity ?? this.rarity,
    rarityValue: rarityValue ?? this.rarityValue,
    releasedAt: releasedAt ?? this.releasedAt,
    scryfallUri: scryfallUri ?? this.scryfallUri,
    uri: uri ?? this.uri,
    rulingsUri: rulingsUri ?? this.rulingsUri,
    printsSearchUri: printsSearchUri ?? this.printsSearchUri,
    manaCost: manaCost.present ? manaCost.value : this.manaCost,
    typeLine: typeLine ?? this.typeLine,
    printedTypeLine: printedTypeLine.present
        ? printedTypeLine.value
        : this.printedTypeLine,
    oracleText: oracleText.present ? oracleText.value : this.oracleText,
    printedText: printedText.present ? printedText.value : this.printedText,
    flavorText: flavorText.present ? flavorText.value : this.flavorText,
    colorsJson: colorsJson.present ? colorsJson.value : this.colorsJson,
    colorMask: colorMask ?? this.colorMask,
    colorIdentityJson: colorIdentityJson.present
        ? colorIdentityJson.value
        : this.colorIdentityJson,
    colorIdentityMask: colorIdentityMask ?? this.colorIdentityMask,
    producedManaJson: producedManaJson.present
        ? producedManaJson.value
        : this.producedManaJson,
    producedManaMask: producedManaMask ?? this.producedManaMask,
    power: power.present ? power.value : this.power,
    toughness: toughness.present ? toughness.value : this.toughness,
    loyalty: loyalty.present ? loyalty.value : this.loyalty,
    defense: defense.present ? defense.value : this.defense,
    cmc: cmc ?? this.cmc,
    keywordsJson: keywordsJson.present ? keywordsJson.value : this.keywordsJson,
    hasCardFaces: hasCardFaces ?? this.hasCardFaces,
    hasColorIndicator: hasColorIndicator ?? this.hasColorIndicator,
    borderColor: borderColor.present ? borderColor.value : this.borderColor,
    frame: frame.present ? frame.value : this.frame,
    frameEffectsJson: frameEffectsJson.present
        ? frameEffectsJson.value
        : this.frameEffectsJson,
    securityStamp: securityStamp.present
        ? securityStamp.value
        : this.securityStamp,
    highresImage: highresImage ?? this.highresImage,
    imageStatus: imageStatus.present ? imageStatus.value : this.imageStatus,
    imageUpdatedAt: imageUpdatedAt.present
        ? imageUpdatedAt.value
        : this.imageUpdatedAt,
    imageSmall: imageSmall.present ? imageSmall.value : this.imageSmall,
    imageNormal: imageNormal.present ? imageNormal.value : this.imageNormal,
    imageLarge: imageLarge.present ? imageLarge.value : this.imageLarge,
    imagePng: imagePng.present ? imagePng.value : this.imagePng,
    imageArtCrop: imageArtCrop.present ? imageArtCrop.value : this.imageArtCrop,
    imageBorderCrop: imageBorderCrop.present
        ? imageBorderCrop.value
        : this.imageBorderCrop,
    artist: artist.present ? artist.value : this.artist,
    artistIdsJson: artistIdsJson.present
        ? artistIdsJson.value
        : this.artistIdsJson,
    illustrationId: illustrationId.present
        ? illustrationId.value
        : this.illustrationId,
    watermark: watermark.present ? watermark.value : this.watermark,
    fullArt: fullArt ?? this.fullArt,
    textless: textless ?? this.textless,
    booster: booster ?? this.booster,
    storySpotlight: storySpotlight ?? this.storySpotlight,
    promo: promo ?? this.promo,
    reprint: reprint ?? this.reprint,
    variation: variation ?? this.variation,
    reserved: reserved ?? this.reserved,
    gameChanger: gameChanger ?? this.gameChanger,
    oversized: oversized ?? this.oversized,
    nonfoil: nonfoil ?? this.nonfoil,
    foil: foil ?? this.foil,
    etched: etched ?? this.etched,
    glossy: glossy ?? this.glossy,
    paper: paper ?? this.paper,
    legalStandard: legalStandard.present
        ? legalStandard.value
        : this.legalStandard,
    legalFuture: legalFuture.present ? legalFuture.value : this.legalFuture,
    legalHistoric: legalHistoric.present
        ? legalHistoric.value
        : this.legalHistoric,
    legalTimeless: legalTimeless.present
        ? legalTimeless.value
        : this.legalTimeless,
    legalGladiator: legalGladiator.present
        ? legalGladiator.value
        : this.legalGladiator,
    legalPioneer: legalPioneer.present ? legalPioneer.value : this.legalPioneer,
    legalModern: legalModern.present ? legalModern.value : this.legalModern,
    legalLegacy: legalLegacy.present ? legalLegacy.value : this.legalLegacy,
    legalPauper: legalPauper.present ? legalPauper.value : this.legalPauper,
    legalVintage: legalVintage.present ? legalVintage.value : this.legalVintage,
    legalPenny: legalPenny.present ? legalPenny.value : this.legalPenny,
    legalCommander: legalCommander.present
        ? legalCommander.value
        : this.legalCommander,
    legalOathbreaker: legalOathbreaker.present
        ? legalOathbreaker.value
        : this.legalOathbreaker,
    legalStandardBrawl: legalStandardBrawl.present
        ? legalStandardBrawl.value
        : this.legalStandardBrawl,
    legalBrawl: legalBrawl.present ? legalBrawl.value : this.legalBrawl,
    legalCompetitiveBrawl: legalCompetitiveBrawl.present
        ? legalCompetitiveBrawl.value
        : this.legalCompetitiveBrawl,
    legalAlchemy: legalAlchemy.present ? legalAlchemy.value : this.legalAlchemy,
    legalPauperCommander: legalPauperCommander.present
        ? legalPauperCommander.value
        : this.legalPauperCommander,
    legalDuel: legalDuel.present ? legalDuel.value : this.legalDuel,
    legalOldSchool: legalOldSchool.present
        ? legalOldSchool.value
        : this.legalOldSchool,
    legalPremodern: legalPremodern.present
        ? legalPremodern.value
        : this.legalPremodern,
    legalPredh: legalPredh.present ? legalPredh.value : this.legalPredh,
    legalTlr: legalTlr.present ? legalTlr.value : this.legalTlr,
    pricesUsd: pricesUsd.present ? pricesUsd.value : this.pricesUsd,
    pricesUsdFoil: pricesUsdFoil.present
        ? pricesUsdFoil.value
        : this.pricesUsdFoil,
    pricesUsdEtched: pricesUsdEtched.present
        ? pricesUsdEtched.value
        : this.pricesUsdEtched,
    pricesEur: pricesEur.present ? pricesEur.value : this.pricesEur,
    pricesEurFoil: pricesEurFoil.present
        ? pricesEurFoil.value
        : this.pricesEurFoil,
    pricesTix: pricesTix.present ? pricesTix.value : this.pricesTix,
    relatedGathererUri: relatedGathererUri.present
        ? relatedGathererUri.value
        : this.relatedGathererUri,
    relatedTcgplayerInfiniteArticlesUri:
        relatedTcgplayerInfiniteArticlesUri.present
        ? relatedTcgplayerInfiniteArticlesUri.value
        : this.relatedTcgplayerInfiniteArticlesUri,
    relatedTcgplayerInfiniteDecksUri: relatedTcgplayerInfiniteDecksUri.present
        ? relatedTcgplayerInfiniteDecksUri.value
        : this.relatedTcgplayerInfiniteDecksUri,
    relatedEdhrecUri: relatedEdhrecUri.present
        ? relatedEdhrecUri.value
        : this.relatedEdhrecUri,
    purchaseTcgplayerUri: purchaseTcgplayerUri.present
        ? purchaseTcgplayerUri.value
        : this.purchaseTcgplayerUri,
    purchaseCardmarketUri: purchaseCardmarketUri.present
        ? purchaseCardmarketUri.value
        : this.purchaseCardmarketUri,
    purchaseCardhoarderUri: purchaseCardhoarderUri.present
        ? purchaseCardhoarderUri.value
        : this.purchaseCardhoarderUri,
    cardBackId: cardBackId.present ? cardBackId.value : this.cardBackId,
    allPartsJson: allPartsJson.present ? allPartsJson.value : this.allPartsJson,
  );
  ScryfallCard copyWithCompanion(ScryfallCardsCompanion data) {
    return ScryfallCard(
      scryfallId: data.scryfallId.present
          ? data.scryfallId.value
          : this.scryfallId,
      oracleId: data.oracleId.present ? data.oracleId.value : this.oracleId,
      tcgplayerId: data.tcgplayerId.present
          ? data.tcgplayerId.value
          : this.tcgplayerId,
      cardmarketId: data.cardmarketId.present
          ? data.cardmarketId.value
          : this.cardmarketId,
      multiverseIdsJson: data.multiverseIdsJson.present
          ? data.multiverseIdsJson.value
          : this.multiverseIdsJson,
      layout: data.layout.present ? data.layout.value : this.layout,
      name: data.name.present ? data.name.value : this.name,
      printedName: data.printedName.present
          ? data.printedName.value
          : this.printedName,
      flavorName: data.flavorName.present
          ? data.flavorName.value
          : this.flavorName,
      setId: data.setId.present ? data.setId.value : this.setId,
      setCode: data.setCode.present ? data.setCode.value : this.setCode,
      setName: data.setName.present ? data.setName.value : this.setName,
      setType: data.setType.present ? data.setType.value : this.setType,
      setUri: data.setUri.present ? data.setUri.value : this.setUri,
      setSearchUri: data.setSearchUri.present
          ? data.setSearchUri.value
          : this.setSearchUri,
      scryfallSetUri: data.scryfallSetUri.present
          ? data.scryfallSetUri.value
          : this.scryfallSetUri,
      collectorNumber: data.collectorNumber.present
          ? data.collectorNumber.value
          : this.collectorNumber,
      lang: data.lang.present ? data.lang.value : this.lang,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      rarityValue: data.rarityValue.present
          ? data.rarityValue.value
          : this.rarityValue,
      releasedAt: data.releasedAt.present
          ? data.releasedAt.value
          : this.releasedAt,
      scryfallUri: data.scryfallUri.present
          ? data.scryfallUri.value
          : this.scryfallUri,
      uri: data.uri.present ? data.uri.value : this.uri,
      rulingsUri: data.rulingsUri.present
          ? data.rulingsUri.value
          : this.rulingsUri,
      printsSearchUri: data.printsSearchUri.present
          ? data.printsSearchUri.value
          : this.printsSearchUri,
      manaCost: data.manaCost.present ? data.manaCost.value : this.manaCost,
      typeLine: data.typeLine.present ? data.typeLine.value : this.typeLine,
      printedTypeLine: data.printedTypeLine.present
          ? data.printedTypeLine.value
          : this.printedTypeLine,
      oracleText: data.oracleText.present
          ? data.oracleText.value
          : this.oracleText,
      printedText: data.printedText.present
          ? data.printedText.value
          : this.printedText,
      flavorText: data.flavorText.present
          ? data.flavorText.value
          : this.flavorText,
      colorsJson: data.colorsJson.present
          ? data.colorsJson.value
          : this.colorsJson,
      colorMask: data.colorMask.present ? data.colorMask.value : this.colorMask,
      colorIdentityJson: data.colorIdentityJson.present
          ? data.colorIdentityJson.value
          : this.colorIdentityJson,
      colorIdentityMask: data.colorIdentityMask.present
          ? data.colorIdentityMask.value
          : this.colorIdentityMask,
      producedManaJson: data.producedManaJson.present
          ? data.producedManaJson.value
          : this.producedManaJson,
      producedManaMask: data.producedManaMask.present
          ? data.producedManaMask.value
          : this.producedManaMask,
      power: data.power.present ? data.power.value : this.power,
      toughness: data.toughness.present ? data.toughness.value : this.toughness,
      loyalty: data.loyalty.present ? data.loyalty.value : this.loyalty,
      defense: data.defense.present ? data.defense.value : this.defense,
      cmc: data.cmc.present ? data.cmc.value : this.cmc,
      keywordsJson: data.keywordsJson.present
          ? data.keywordsJson.value
          : this.keywordsJson,
      hasCardFaces: data.hasCardFaces.present
          ? data.hasCardFaces.value
          : this.hasCardFaces,
      hasColorIndicator: data.hasColorIndicator.present
          ? data.hasColorIndicator.value
          : this.hasColorIndicator,
      borderColor: data.borderColor.present
          ? data.borderColor.value
          : this.borderColor,
      frame: data.frame.present ? data.frame.value : this.frame,
      frameEffectsJson: data.frameEffectsJson.present
          ? data.frameEffectsJson.value
          : this.frameEffectsJson,
      securityStamp: data.securityStamp.present
          ? data.securityStamp.value
          : this.securityStamp,
      highresImage: data.highresImage.present
          ? data.highresImage.value
          : this.highresImage,
      imageStatus: data.imageStatus.present
          ? data.imageStatus.value
          : this.imageStatus,
      imageUpdatedAt: data.imageUpdatedAt.present
          ? data.imageUpdatedAt.value
          : this.imageUpdatedAt,
      imageSmall: data.imageSmall.present
          ? data.imageSmall.value
          : this.imageSmall,
      imageNormal: data.imageNormal.present
          ? data.imageNormal.value
          : this.imageNormal,
      imageLarge: data.imageLarge.present
          ? data.imageLarge.value
          : this.imageLarge,
      imagePng: data.imagePng.present ? data.imagePng.value : this.imagePng,
      imageArtCrop: data.imageArtCrop.present
          ? data.imageArtCrop.value
          : this.imageArtCrop,
      imageBorderCrop: data.imageBorderCrop.present
          ? data.imageBorderCrop.value
          : this.imageBorderCrop,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistIdsJson: data.artistIdsJson.present
          ? data.artistIdsJson.value
          : this.artistIdsJson,
      illustrationId: data.illustrationId.present
          ? data.illustrationId.value
          : this.illustrationId,
      watermark: data.watermark.present ? data.watermark.value : this.watermark,
      fullArt: data.fullArt.present ? data.fullArt.value : this.fullArt,
      textless: data.textless.present ? data.textless.value : this.textless,
      booster: data.booster.present ? data.booster.value : this.booster,
      storySpotlight: data.storySpotlight.present
          ? data.storySpotlight.value
          : this.storySpotlight,
      promo: data.promo.present ? data.promo.value : this.promo,
      reprint: data.reprint.present ? data.reprint.value : this.reprint,
      variation: data.variation.present ? data.variation.value : this.variation,
      reserved: data.reserved.present ? data.reserved.value : this.reserved,
      gameChanger: data.gameChanger.present
          ? data.gameChanger.value
          : this.gameChanger,
      oversized: data.oversized.present ? data.oversized.value : this.oversized,
      nonfoil: data.nonfoil.present ? data.nonfoil.value : this.nonfoil,
      foil: data.foil.present ? data.foil.value : this.foil,
      etched: data.etched.present ? data.etched.value : this.etched,
      glossy: data.glossy.present ? data.glossy.value : this.glossy,
      paper: data.paper.present ? data.paper.value : this.paper,
      legalStandard: data.legalStandard.present
          ? data.legalStandard.value
          : this.legalStandard,
      legalFuture: data.legalFuture.present
          ? data.legalFuture.value
          : this.legalFuture,
      legalHistoric: data.legalHistoric.present
          ? data.legalHistoric.value
          : this.legalHistoric,
      legalTimeless: data.legalTimeless.present
          ? data.legalTimeless.value
          : this.legalTimeless,
      legalGladiator: data.legalGladiator.present
          ? data.legalGladiator.value
          : this.legalGladiator,
      legalPioneer: data.legalPioneer.present
          ? data.legalPioneer.value
          : this.legalPioneer,
      legalModern: data.legalModern.present
          ? data.legalModern.value
          : this.legalModern,
      legalLegacy: data.legalLegacy.present
          ? data.legalLegacy.value
          : this.legalLegacy,
      legalPauper: data.legalPauper.present
          ? data.legalPauper.value
          : this.legalPauper,
      legalVintage: data.legalVintage.present
          ? data.legalVintage.value
          : this.legalVintage,
      legalPenny: data.legalPenny.present
          ? data.legalPenny.value
          : this.legalPenny,
      legalCommander: data.legalCommander.present
          ? data.legalCommander.value
          : this.legalCommander,
      legalOathbreaker: data.legalOathbreaker.present
          ? data.legalOathbreaker.value
          : this.legalOathbreaker,
      legalStandardBrawl: data.legalStandardBrawl.present
          ? data.legalStandardBrawl.value
          : this.legalStandardBrawl,
      legalBrawl: data.legalBrawl.present
          ? data.legalBrawl.value
          : this.legalBrawl,
      legalCompetitiveBrawl: data.legalCompetitiveBrawl.present
          ? data.legalCompetitiveBrawl.value
          : this.legalCompetitiveBrawl,
      legalAlchemy: data.legalAlchemy.present
          ? data.legalAlchemy.value
          : this.legalAlchemy,
      legalPauperCommander: data.legalPauperCommander.present
          ? data.legalPauperCommander.value
          : this.legalPauperCommander,
      legalDuel: data.legalDuel.present ? data.legalDuel.value : this.legalDuel,
      legalOldSchool: data.legalOldSchool.present
          ? data.legalOldSchool.value
          : this.legalOldSchool,
      legalPremodern: data.legalPremodern.present
          ? data.legalPremodern.value
          : this.legalPremodern,
      legalPredh: data.legalPredh.present
          ? data.legalPredh.value
          : this.legalPredh,
      legalTlr: data.legalTlr.present ? data.legalTlr.value : this.legalTlr,
      pricesUsd: data.pricesUsd.present ? data.pricesUsd.value : this.pricesUsd,
      pricesUsdFoil: data.pricesUsdFoil.present
          ? data.pricesUsdFoil.value
          : this.pricesUsdFoil,
      pricesUsdEtched: data.pricesUsdEtched.present
          ? data.pricesUsdEtched.value
          : this.pricesUsdEtched,
      pricesEur: data.pricesEur.present ? data.pricesEur.value : this.pricesEur,
      pricesEurFoil: data.pricesEurFoil.present
          ? data.pricesEurFoil.value
          : this.pricesEurFoil,
      pricesTix: data.pricesTix.present ? data.pricesTix.value : this.pricesTix,
      relatedGathererUri: data.relatedGathererUri.present
          ? data.relatedGathererUri.value
          : this.relatedGathererUri,
      relatedTcgplayerInfiniteArticlesUri:
          data.relatedTcgplayerInfiniteArticlesUri.present
          ? data.relatedTcgplayerInfiniteArticlesUri.value
          : this.relatedTcgplayerInfiniteArticlesUri,
      relatedTcgplayerInfiniteDecksUri:
          data.relatedTcgplayerInfiniteDecksUri.present
          ? data.relatedTcgplayerInfiniteDecksUri.value
          : this.relatedTcgplayerInfiniteDecksUri,
      relatedEdhrecUri: data.relatedEdhrecUri.present
          ? data.relatedEdhrecUri.value
          : this.relatedEdhrecUri,
      purchaseTcgplayerUri: data.purchaseTcgplayerUri.present
          ? data.purchaseTcgplayerUri.value
          : this.purchaseTcgplayerUri,
      purchaseCardmarketUri: data.purchaseCardmarketUri.present
          ? data.purchaseCardmarketUri.value
          : this.purchaseCardmarketUri,
      purchaseCardhoarderUri: data.purchaseCardhoarderUri.present
          ? data.purchaseCardhoarderUri.value
          : this.purchaseCardhoarderUri,
      cardBackId: data.cardBackId.present
          ? data.cardBackId.value
          : this.cardBackId,
      allPartsJson: data.allPartsJson.present
          ? data.allPartsJson.value
          : this.allPartsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScryfallCard(')
          ..write('scryfallId: $scryfallId, ')
          ..write('oracleId: $oracleId, ')
          ..write('tcgplayerId: $tcgplayerId, ')
          ..write('cardmarketId: $cardmarketId, ')
          ..write('multiverseIdsJson: $multiverseIdsJson, ')
          ..write('layout: $layout, ')
          ..write('name: $name, ')
          ..write('printedName: $printedName, ')
          ..write('flavorName: $flavorName, ')
          ..write('setId: $setId, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('setType: $setType, ')
          ..write('setUri: $setUri, ')
          ..write('setSearchUri: $setSearchUri, ')
          ..write('scryfallSetUri: $scryfallSetUri, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('lang: $lang, ')
          ..write('rarity: $rarity, ')
          ..write('rarityValue: $rarityValue, ')
          ..write('releasedAt: $releasedAt, ')
          ..write('scryfallUri: $scryfallUri, ')
          ..write('uri: $uri, ')
          ..write('rulingsUri: $rulingsUri, ')
          ..write('printsSearchUri: $printsSearchUri, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('printedTypeLine: $printedTypeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('printedText: $printedText, ')
          ..write('flavorText: $flavorText, ')
          ..write('colorsJson: $colorsJson, ')
          ..write('colorMask: $colorMask, ')
          ..write('colorIdentityJson: $colorIdentityJson, ')
          ..write('colorIdentityMask: $colorIdentityMask, ')
          ..write('producedManaJson: $producedManaJson, ')
          ..write('producedManaMask: $producedManaMask, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('defense: $defense, ')
          ..write('cmc: $cmc, ')
          ..write('keywordsJson: $keywordsJson, ')
          ..write('hasCardFaces: $hasCardFaces, ')
          ..write('hasColorIndicator: $hasColorIndicator, ')
          ..write('borderColor: $borderColor, ')
          ..write('frame: $frame, ')
          ..write('frameEffectsJson: $frameEffectsJson, ')
          ..write('securityStamp: $securityStamp, ')
          ..write('highresImage: $highresImage, ')
          ..write('imageStatus: $imageStatus, ')
          ..write('imageUpdatedAt: $imageUpdatedAt, ')
          ..write('imageSmall: $imageSmall, ')
          ..write('imageNormal: $imageNormal, ')
          ..write('imageLarge: $imageLarge, ')
          ..write('imagePng: $imagePng, ')
          ..write('imageArtCrop: $imageArtCrop, ')
          ..write('imageBorderCrop: $imageBorderCrop, ')
          ..write('artist: $artist, ')
          ..write('artistIdsJson: $artistIdsJson, ')
          ..write('illustrationId: $illustrationId, ')
          ..write('watermark: $watermark, ')
          ..write('fullArt: $fullArt, ')
          ..write('textless: $textless, ')
          ..write('booster: $booster, ')
          ..write('storySpotlight: $storySpotlight, ')
          ..write('promo: $promo, ')
          ..write('reprint: $reprint, ')
          ..write('variation: $variation, ')
          ..write('reserved: $reserved, ')
          ..write('gameChanger: $gameChanger, ')
          ..write('oversized: $oversized, ')
          ..write('nonfoil: $nonfoil, ')
          ..write('foil: $foil, ')
          ..write('etched: $etched, ')
          ..write('glossy: $glossy, ')
          ..write('paper: $paper, ')
          ..write('legalStandard: $legalStandard, ')
          ..write('legalFuture: $legalFuture, ')
          ..write('legalHistoric: $legalHistoric, ')
          ..write('legalTimeless: $legalTimeless, ')
          ..write('legalGladiator: $legalGladiator, ')
          ..write('legalPioneer: $legalPioneer, ')
          ..write('legalModern: $legalModern, ')
          ..write('legalLegacy: $legalLegacy, ')
          ..write('legalPauper: $legalPauper, ')
          ..write('legalVintage: $legalVintage, ')
          ..write('legalPenny: $legalPenny, ')
          ..write('legalCommander: $legalCommander, ')
          ..write('legalOathbreaker: $legalOathbreaker, ')
          ..write('legalStandardBrawl: $legalStandardBrawl, ')
          ..write('legalBrawl: $legalBrawl, ')
          ..write('legalCompetitiveBrawl: $legalCompetitiveBrawl, ')
          ..write('legalAlchemy: $legalAlchemy, ')
          ..write('legalPauperCommander: $legalPauperCommander, ')
          ..write('legalDuel: $legalDuel, ')
          ..write('legalOldSchool: $legalOldSchool, ')
          ..write('legalPremodern: $legalPremodern, ')
          ..write('legalPredh: $legalPredh, ')
          ..write('legalTlr: $legalTlr, ')
          ..write('pricesUsd: $pricesUsd, ')
          ..write('pricesUsdFoil: $pricesUsdFoil, ')
          ..write('pricesUsdEtched: $pricesUsdEtched, ')
          ..write('pricesEur: $pricesEur, ')
          ..write('pricesEurFoil: $pricesEurFoil, ')
          ..write('pricesTix: $pricesTix, ')
          ..write('relatedGathererUri: $relatedGathererUri, ')
          ..write(
            'relatedTcgplayerInfiniteArticlesUri: $relatedTcgplayerInfiniteArticlesUri, ',
          )
          ..write(
            'relatedTcgplayerInfiniteDecksUri: $relatedTcgplayerInfiniteDecksUri, ',
          )
          ..write('relatedEdhrecUri: $relatedEdhrecUri, ')
          ..write('purchaseTcgplayerUri: $purchaseTcgplayerUri, ')
          ..write('purchaseCardmarketUri: $purchaseCardmarketUri, ')
          ..write('purchaseCardhoarderUri: $purchaseCardhoarderUri, ')
          ..write('cardBackId: $cardBackId, ')
          ..write('allPartsJson: $allPartsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    scryfallId,
    oracleId,
    tcgplayerId,
    cardmarketId,
    multiverseIdsJson,
    layout,
    name,
    printedName,
    flavorName,
    setId,
    setCode,
    setName,
    setType,
    setUri,
    setSearchUri,
    scryfallSetUri,
    collectorNumber,
    lang,
    rarity,
    rarityValue,
    releasedAt,
    scryfallUri,
    uri,
    rulingsUri,
    printsSearchUri,
    manaCost,
    typeLine,
    printedTypeLine,
    oracleText,
    printedText,
    flavorText,
    colorsJson,
    colorMask,
    colorIdentityJson,
    colorIdentityMask,
    producedManaJson,
    producedManaMask,
    power,
    toughness,
    loyalty,
    defense,
    cmc,
    keywordsJson,
    hasCardFaces,
    hasColorIndicator,
    borderColor,
    frame,
    frameEffectsJson,
    securityStamp,
    highresImage,
    imageStatus,
    imageUpdatedAt,
    imageSmall,
    imageNormal,
    imageLarge,
    imagePng,
    imageArtCrop,
    imageBorderCrop,
    artist,
    artistIdsJson,
    illustrationId,
    watermark,
    fullArt,
    textless,
    booster,
    storySpotlight,
    promo,
    reprint,
    variation,
    reserved,
    gameChanger,
    oversized,
    nonfoil,
    foil,
    etched,
    glossy,
    paper,
    legalStandard,
    legalFuture,
    legalHistoric,
    legalTimeless,
    legalGladiator,
    legalPioneer,
    legalModern,
    legalLegacy,
    legalPauper,
    legalVintage,
    legalPenny,
    legalCommander,
    legalOathbreaker,
    legalStandardBrawl,
    legalBrawl,
    legalCompetitiveBrawl,
    legalAlchemy,
    legalPauperCommander,
    legalDuel,
    legalOldSchool,
    legalPremodern,
    legalPredh,
    legalTlr,
    pricesUsd,
    pricesUsdFoil,
    pricesUsdEtched,
    pricesEur,
    pricesEurFoil,
    pricesTix,
    relatedGathererUri,
    relatedTcgplayerInfiniteArticlesUri,
    relatedTcgplayerInfiniteDecksUri,
    relatedEdhrecUri,
    purchaseTcgplayerUri,
    purchaseCardmarketUri,
    purchaseCardhoarderUri,
    cardBackId,
    allPartsJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScryfallCard &&
          other.scryfallId == this.scryfallId &&
          other.oracleId == this.oracleId &&
          other.tcgplayerId == this.tcgplayerId &&
          other.cardmarketId == this.cardmarketId &&
          other.multiverseIdsJson == this.multiverseIdsJson &&
          other.layout == this.layout &&
          other.name == this.name &&
          other.printedName == this.printedName &&
          other.flavorName == this.flavorName &&
          other.setId == this.setId &&
          other.setCode == this.setCode &&
          other.setName == this.setName &&
          other.setType == this.setType &&
          other.setUri == this.setUri &&
          other.setSearchUri == this.setSearchUri &&
          other.scryfallSetUri == this.scryfallSetUri &&
          other.collectorNumber == this.collectorNumber &&
          other.lang == this.lang &&
          other.rarity == this.rarity &&
          other.rarityValue == this.rarityValue &&
          other.releasedAt == this.releasedAt &&
          other.scryfallUri == this.scryfallUri &&
          other.uri == this.uri &&
          other.rulingsUri == this.rulingsUri &&
          other.printsSearchUri == this.printsSearchUri &&
          other.manaCost == this.manaCost &&
          other.typeLine == this.typeLine &&
          other.printedTypeLine == this.printedTypeLine &&
          other.oracleText == this.oracleText &&
          other.printedText == this.printedText &&
          other.flavorText == this.flavorText &&
          other.colorsJson == this.colorsJson &&
          other.colorMask == this.colorMask &&
          other.colorIdentityJson == this.colorIdentityJson &&
          other.colorIdentityMask == this.colorIdentityMask &&
          other.producedManaJson == this.producedManaJson &&
          other.producedManaMask == this.producedManaMask &&
          other.power == this.power &&
          other.toughness == this.toughness &&
          other.loyalty == this.loyalty &&
          other.defense == this.defense &&
          other.cmc == this.cmc &&
          other.keywordsJson == this.keywordsJson &&
          other.hasCardFaces == this.hasCardFaces &&
          other.hasColorIndicator == this.hasColorIndicator &&
          other.borderColor == this.borderColor &&
          other.frame == this.frame &&
          other.frameEffectsJson == this.frameEffectsJson &&
          other.securityStamp == this.securityStamp &&
          other.highresImage == this.highresImage &&
          other.imageStatus == this.imageStatus &&
          other.imageUpdatedAt == this.imageUpdatedAt &&
          other.imageSmall == this.imageSmall &&
          other.imageNormal == this.imageNormal &&
          other.imageLarge == this.imageLarge &&
          other.imagePng == this.imagePng &&
          other.imageArtCrop == this.imageArtCrop &&
          other.imageBorderCrop == this.imageBorderCrop &&
          other.artist == this.artist &&
          other.artistIdsJson == this.artistIdsJson &&
          other.illustrationId == this.illustrationId &&
          other.watermark == this.watermark &&
          other.fullArt == this.fullArt &&
          other.textless == this.textless &&
          other.booster == this.booster &&
          other.storySpotlight == this.storySpotlight &&
          other.promo == this.promo &&
          other.reprint == this.reprint &&
          other.variation == this.variation &&
          other.reserved == this.reserved &&
          other.gameChanger == this.gameChanger &&
          other.oversized == this.oversized &&
          other.nonfoil == this.nonfoil &&
          other.foil == this.foil &&
          other.etched == this.etched &&
          other.glossy == this.glossy &&
          other.paper == this.paper &&
          other.legalStandard == this.legalStandard &&
          other.legalFuture == this.legalFuture &&
          other.legalHistoric == this.legalHistoric &&
          other.legalTimeless == this.legalTimeless &&
          other.legalGladiator == this.legalGladiator &&
          other.legalPioneer == this.legalPioneer &&
          other.legalModern == this.legalModern &&
          other.legalLegacy == this.legalLegacy &&
          other.legalPauper == this.legalPauper &&
          other.legalVintage == this.legalVintage &&
          other.legalPenny == this.legalPenny &&
          other.legalCommander == this.legalCommander &&
          other.legalOathbreaker == this.legalOathbreaker &&
          other.legalStandardBrawl == this.legalStandardBrawl &&
          other.legalBrawl == this.legalBrawl &&
          other.legalCompetitiveBrawl == this.legalCompetitiveBrawl &&
          other.legalAlchemy == this.legalAlchemy &&
          other.legalPauperCommander == this.legalPauperCommander &&
          other.legalDuel == this.legalDuel &&
          other.legalOldSchool == this.legalOldSchool &&
          other.legalPremodern == this.legalPremodern &&
          other.legalPredh == this.legalPredh &&
          other.legalTlr == this.legalTlr &&
          other.pricesUsd == this.pricesUsd &&
          other.pricesUsdFoil == this.pricesUsdFoil &&
          other.pricesUsdEtched == this.pricesUsdEtched &&
          other.pricesEur == this.pricesEur &&
          other.pricesEurFoil == this.pricesEurFoil &&
          other.pricesTix == this.pricesTix &&
          other.relatedGathererUri == this.relatedGathererUri &&
          other.relatedTcgplayerInfiniteArticlesUri ==
              this.relatedTcgplayerInfiniteArticlesUri &&
          other.relatedTcgplayerInfiniteDecksUri ==
              this.relatedTcgplayerInfiniteDecksUri &&
          other.relatedEdhrecUri == this.relatedEdhrecUri &&
          other.purchaseTcgplayerUri == this.purchaseTcgplayerUri &&
          other.purchaseCardmarketUri == this.purchaseCardmarketUri &&
          other.purchaseCardhoarderUri == this.purchaseCardhoarderUri &&
          other.cardBackId == this.cardBackId &&
          other.allPartsJson == this.allPartsJson);
}

class ScryfallCardsCompanion extends UpdateCompanion<ScryfallCard> {
  final Value<String> scryfallId;
  final Value<String?> oracleId;
  final Value<String?> tcgplayerId;
  final Value<String?> cardmarketId;
  final Value<String?> multiverseIdsJson;
  final Value<String> layout;
  final Value<String> name;
  final Value<String?> printedName;
  final Value<String?> flavorName;
  final Value<String> setId;
  final Value<String> setCode;
  final Value<String> setName;
  final Value<String> setType;
  final Value<String> setUri;
  final Value<String> setSearchUri;
  final Value<String> scryfallSetUri;
  final Value<String> collectorNumber;
  final Value<String> lang;
  final Value<String> rarity;
  final Value<int> rarityValue;
  final Value<String> releasedAt;
  final Value<String> scryfallUri;
  final Value<String> uri;
  final Value<String> rulingsUri;
  final Value<String> printsSearchUri;
  final Value<String?> manaCost;
  final Value<String> typeLine;
  final Value<String?> printedTypeLine;
  final Value<String?> oracleText;
  final Value<String?> printedText;
  final Value<String?> flavorText;
  final Value<String?> colorsJson;
  final Value<int> colorMask;
  final Value<String?> colorIdentityJson;
  final Value<int> colorIdentityMask;
  final Value<String?> producedManaJson;
  final Value<int> producedManaMask;
  final Value<String?> power;
  final Value<String?> toughness;
  final Value<String?> loyalty;
  final Value<String?> defense;
  final Value<double> cmc;
  final Value<String?> keywordsJson;
  final Value<bool> hasCardFaces;
  final Value<bool> hasColorIndicator;
  final Value<String?> borderColor;
  final Value<String?> frame;
  final Value<String?> frameEffectsJson;
  final Value<String?> securityStamp;
  final Value<bool> highresImage;
  final Value<String?> imageStatus;
  final Value<String?> imageUpdatedAt;
  final Value<String?> imageSmall;
  final Value<String?> imageNormal;
  final Value<String?> imageLarge;
  final Value<String?> imagePng;
  final Value<String?> imageArtCrop;
  final Value<String?> imageBorderCrop;
  final Value<String?> artist;
  final Value<String?> artistIdsJson;
  final Value<String?> illustrationId;
  final Value<String?> watermark;
  final Value<bool> fullArt;
  final Value<bool> textless;
  final Value<bool> booster;
  final Value<bool> storySpotlight;
  final Value<bool> promo;
  final Value<bool> reprint;
  final Value<bool> variation;
  final Value<bool> reserved;
  final Value<bool> gameChanger;
  final Value<bool> oversized;
  final Value<bool> nonfoil;
  final Value<bool> foil;
  final Value<bool> etched;
  final Value<bool> glossy;
  final Value<bool> paper;
  final Value<String?> legalStandard;
  final Value<String?> legalFuture;
  final Value<String?> legalHistoric;
  final Value<String?> legalTimeless;
  final Value<String?> legalGladiator;
  final Value<String?> legalPioneer;
  final Value<String?> legalModern;
  final Value<String?> legalLegacy;
  final Value<String?> legalPauper;
  final Value<String?> legalVintage;
  final Value<String?> legalPenny;
  final Value<String?> legalCommander;
  final Value<String?> legalOathbreaker;
  final Value<String?> legalStandardBrawl;
  final Value<String?> legalBrawl;
  final Value<String?> legalCompetitiveBrawl;
  final Value<String?> legalAlchemy;
  final Value<String?> legalPauperCommander;
  final Value<String?> legalDuel;
  final Value<String?> legalOldSchool;
  final Value<String?> legalPremodern;
  final Value<String?> legalPredh;
  final Value<String?> legalTlr;
  final Value<String?> pricesUsd;
  final Value<String?> pricesUsdFoil;
  final Value<String?> pricesUsdEtched;
  final Value<String?> pricesEur;
  final Value<String?> pricesEurFoil;
  final Value<String?> pricesTix;
  final Value<String?> relatedGathererUri;
  final Value<String?> relatedTcgplayerInfiniteArticlesUri;
  final Value<String?> relatedTcgplayerInfiniteDecksUri;
  final Value<String?> relatedEdhrecUri;
  final Value<String?> purchaseTcgplayerUri;
  final Value<String?> purchaseCardmarketUri;
  final Value<String?> purchaseCardhoarderUri;
  final Value<String?> cardBackId;
  final Value<String?> allPartsJson;
  final Value<int> rowid;
  const ScryfallCardsCompanion({
    this.scryfallId = const Value.absent(),
    this.oracleId = const Value.absent(),
    this.tcgplayerId = const Value.absent(),
    this.cardmarketId = const Value.absent(),
    this.multiverseIdsJson = const Value.absent(),
    this.layout = const Value.absent(),
    this.name = const Value.absent(),
    this.printedName = const Value.absent(),
    this.flavorName = const Value.absent(),
    this.setId = const Value.absent(),
    this.setCode = const Value.absent(),
    this.setName = const Value.absent(),
    this.setType = const Value.absent(),
    this.setUri = const Value.absent(),
    this.setSearchUri = const Value.absent(),
    this.scryfallSetUri = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.lang = const Value.absent(),
    this.rarity = const Value.absent(),
    this.rarityValue = const Value.absent(),
    this.releasedAt = const Value.absent(),
    this.scryfallUri = const Value.absent(),
    this.uri = const Value.absent(),
    this.rulingsUri = const Value.absent(),
    this.printsSearchUri = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.printedTypeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.printedText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.colorsJson = const Value.absent(),
    this.colorMask = const Value.absent(),
    this.colorIdentityJson = const Value.absent(),
    this.colorIdentityMask = const Value.absent(),
    this.producedManaJson = const Value.absent(),
    this.producedManaMask = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.defense = const Value.absent(),
    this.cmc = const Value.absent(),
    this.keywordsJson = const Value.absent(),
    this.hasCardFaces = const Value.absent(),
    this.hasColorIndicator = const Value.absent(),
    this.borderColor = const Value.absent(),
    this.frame = const Value.absent(),
    this.frameEffectsJson = const Value.absent(),
    this.securityStamp = const Value.absent(),
    this.highresImage = const Value.absent(),
    this.imageStatus = const Value.absent(),
    this.imageUpdatedAt = const Value.absent(),
    this.imageSmall = const Value.absent(),
    this.imageNormal = const Value.absent(),
    this.imageLarge = const Value.absent(),
    this.imagePng = const Value.absent(),
    this.imageArtCrop = const Value.absent(),
    this.imageBorderCrop = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistIdsJson = const Value.absent(),
    this.illustrationId = const Value.absent(),
    this.watermark = const Value.absent(),
    this.fullArt = const Value.absent(),
    this.textless = const Value.absent(),
    this.booster = const Value.absent(),
    this.storySpotlight = const Value.absent(),
    this.promo = const Value.absent(),
    this.reprint = const Value.absent(),
    this.variation = const Value.absent(),
    this.reserved = const Value.absent(),
    this.gameChanger = const Value.absent(),
    this.oversized = const Value.absent(),
    this.nonfoil = const Value.absent(),
    this.foil = const Value.absent(),
    this.etched = const Value.absent(),
    this.glossy = const Value.absent(),
    this.paper = const Value.absent(),
    this.legalStandard = const Value.absent(),
    this.legalFuture = const Value.absent(),
    this.legalHistoric = const Value.absent(),
    this.legalTimeless = const Value.absent(),
    this.legalGladiator = const Value.absent(),
    this.legalPioneer = const Value.absent(),
    this.legalModern = const Value.absent(),
    this.legalLegacy = const Value.absent(),
    this.legalPauper = const Value.absent(),
    this.legalVintage = const Value.absent(),
    this.legalPenny = const Value.absent(),
    this.legalCommander = const Value.absent(),
    this.legalOathbreaker = const Value.absent(),
    this.legalStandardBrawl = const Value.absent(),
    this.legalBrawl = const Value.absent(),
    this.legalCompetitiveBrawl = const Value.absent(),
    this.legalAlchemy = const Value.absent(),
    this.legalPauperCommander = const Value.absent(),
    this.legalDuel = const Value.absent(),
    this.legalOldSchool = const Value.absent(),
    this.legalPremodern = const Value.absent(),
    this.legalPredh = const Value.absent(),
    this.legalTlr = const Value.absent(),
    this.pricesUsd = const Value.absent(),
    this.pricesUsdFoil = const Value.absent(),
    this.pricesUsdEtched = const Value.absent(),
    this.pricesEur = const Value.absent(),
    this.pricesEurFoil = const Value.absent(),
    this.pricesTix = const Value.absent(),
    this.relatedGathererUri = const Value.absent(),
    this.relatedTcgplayerInfiniteArticlesUri = const Value.absent(),
    this.relatedTcgplayerInfiniteDecksUri = const Value.absent(),
    this.relatedEdhrecUri = const Value.absent(),
    this.purchaseTcgplayerUri = const Value.absent(),
    this.purchaseCardmarketUri = const Value.absent(),
    this.purchaseCardhoarderUri = const Value.absent(),
    this.cardBackId = const Value.absent(),
    this.allPartsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScryfallCardsCompanion.insert({
    required String scryfallId,
    this.oracleId = const Value.absent(),
    this.tcgplayerId = const Value.absent(),
    this.cardmarketId = const Value.absent(),
    this.multiverseIdsJson = const Value.absent(),
    required String layout,
    required String name,
    this.printedName = const Value.absent(),
    this.flavorName = const Value.absent(),
    required String setId,
    required String setCode,
    required String setName,
    required String setType,
    required String setUri,
    required String setSearchUri,
    required String scryfallSetUri,
    required String collectorNumber,
    required String lang,
    required String rarity,
    this.rarityValue = const Value.absent(),
    required String releasedAt,
    required String scryfallUri,
    required String uri,
    required String rulingsUri,
    required String printsSearchUri,
    this.manaCost = const Value.absent(),
    required String typeLine,
    this.printedTypeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.printedText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.colorsJson = const Value.absent(),
    this.colorMask = const Value.absent(),
    this.colorIdentityJson = const Value.absent(),
    this.colorIdentityMask = const Value.absent(),
    this.producedManaJson = const Value.absent(),
    this.producedManaMask = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.defense = const Value.absent(),
    required double cmc,
    this.keywordsJson = const Value.absent(),
    this.hasCardFaces = const Value.absent(),
    this.hasColorIndicator = const Value.absent(),
    this.borderColor = const Value.absent(),
    this.frame = const Value.absent(),
    this.frameEffectsJson = const Value.absent(),
    this.securityStamp = const Value.absent(),
    this.highresImage = const Value.absent(),
    this.imageStatus = const Value.absent(),
    this.imageUpdatedAt = const Value.absent(),
    this.imageSmall = const Value.absent(),
    this.imageNormal = const Value.absent(),
    this.imageLarge = const Value.absent(),
    this.imagePng = const Value.absent(),
    this.imageArtCrop = const Value.absent(),
    this.imageBorderCrop = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistIdsJson = const Value.absent(),
    this.illustrationId = const Value.absent(),
    this.watermark = const Value.absent(),
    this.fullArt = const Value.absent(),
    this.textless = const Value.absent(),
    this.booster = const Value.absent(),
    this.storySpotlight = const Value.absent(),
    this.promo = const Value.absent(),
    this.reprint = const Value.absent(),
    this.variation = const Value.absent(),
    this.reserved = const Value.absent(),
    this.gameChanger = const Value.absent(),
    this.oversized = const Value.absent(),
    this.nonfoil = const Value.absent(),
    this.foil = const Value.absent(),
    this.etched = const Value.absent(),
    this.glossy = const Value.absent(),
    this.paper = const Value.absent(),
    this.legalStandard = const Value.absent(),
    this.legalFuture = const Value.absent(),
    this.legalHistoric = const Value.absent(),
    this.legalTimeless = const Value.absent(),
    this.legalGladiator = const Value.absent(),
    this.legalPioneer = const Value.absent(),
    this.legalModern = const Value.absent(),
    this.legalLegacy = const Value.absent(),
    this.legalPauper = const Value.absent(),
    this.legalVintage = const Value.absent(),
    this.legalPenny = const Value.absent(),
    this.legalCommander = const Value.absent(),
    this.legalOathbreaker = const Value.absent(),
    this.legalStandardBrawl = const Value.absent(),
    this.legalBrawl = const Value.absent(),
    this.legalCompetitiveBrawl = const Value.absent(),
    this.legalAlchemy = const Value.absent(),
    this.legalPauperCommander = const Value.absent(),
    this.legalDuel = const Value.absent(),
    this.legalOldSchool = const Value.absent(),
    this.legalPremodern = const Value.absent(),
    this.legalPredh = const Value.absent(),
    this.legalTlr = const Value.absent(),
    this.pricesUsd = const Value.absent(),
    this.pricesUsdFoil = const Value.absent(),
    this.pricesUsdEtched = const Value.absent(),
    this.pricesEur = const Value.absent(),
    this.pricesEurFoil = const Value.absent(),
    this.pricesTix = const Value.absent(),
    this.relatedGathererUri = const Value.absent(),
    this.relatedTcgplayerInfiniteArticlesUri = const Value.absent(),
    this.relatedTcgplayerInfiniteDecksUri = const Value.absent(),
    this.relatedEdhrecUri = const Value.absent(),
    this.purchaseTcgplayerUri = const Value.absent(),
    this.purchaseCardmarketUri = const Value.absent(),
    this.purchaseCardhoarderUri = const Value.absent(),
    this.cardBackId = const Value.absent(),
    this.allPartsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scryfallId = Value(scryfallId),
       layout = Value(layout),
       name = Value(name),
       setId = Value(setId),
       setCode = Value(setCode),
       setName = Value(setName),
       setType = Value(setType),
       setUri = Value(setUri),
       setSearchUri = Value(setSearchUri),
       scryfallSetUri = Value(scryfallSetUri),
       collectorNumber = Value(collectorNumber),
       lang = Value(lang),
       rarity = Value(rarity),
       releasedAt = Value(releasedAt),
       scryfallUri = Value(scryfallUri),
       uri = Value(uri),
       rulingsUri = Value(rulingsUri),
       printsSearchUri = Value(printsSearchUri),
       typeLine = Value(typeLine),
       cmc = Value(cmc);
  static Insertable<ScryfallCard> custom({
    Expression<String>? scryfallId,
    Expression<String>? oracleId,
    Expression<String>? tcgplayerId,
    Expression<String>? cardmarketId,
    Expression<String>? multiverseIdsJson,
    Expression<String>? layout,
    Expression<String>? name,
    Expression<String>? printedName,
    Expression<String>? flavorName,
    Expression<String>? setId,
    Expression<String>? setCode,
    Expression<String>? setName,
    Expression<String>? setType,
    Expression<String>? setUri,
    Expression<String>? setSearchUri,
    Expression<String>? scryfallSetUri,
    Expression<String>? collectorNumber,
    Expression<String>? lang,
    Expression<String>? rarity,
    Expression<int>? rarityValue,
    Expression<String>? releasedAt,
    Expression<String>? scryfallUri,
    Expression<String>? uri,
    Expression<String>? rulingsUri,
    Expression<String>? printsSearchUri,
    Expression<String>? manaCost,
    Expression<String>? typeLine,
    Expression<String>? printedTypeLine,
    Expression<String>? oracleText,
    Expression<String>? printedText,
    Expression<String>? flavorText,
    Expression<String>? colorsJson,
    Expression<int>? colorMask,
    Expression<String>? colorIdentityJson,
    Expression<int>? colorIdentityMask,
    Expression<String>? producedManaJson,
    Expression<int>? producedManaMask,
    Expression<String>? power,
    Expression<String>? toughness,
    Expression<String>? loyalty,
    Expression<String>? defense,
    Expression<double>? cmc,
    Expression<String>? keywordsJson,
    Expression<bool>? hasCardFaces,
    Expression<bool>? hasColorIndicator,
    Expression<String>? borderColor,
    Expression<String>? frame,
    Expression<String>? frameEffectsJson,
    Expression<String>? securityStamp,
    Expression<bool>? highresImage,
    Expression<String>? imageStatus,
    Expression<String>? imageUpdatedAt,
    Expression<String>? imageSmall,
    Expression<String>? imageNormal,
    Expression<String>? imageLarge,
    Expression<String>? imagePng,
    Expression<String>? imageArtCrop,
    Expression<String>? imageBorderCrop,
    Expression<String>? artist,
    Expression<String>? artistIdsJson,
    Expression<String>? illustrationId,
    Expression<String>? watermark,
    Expression<bool>? fullArt,
    Expression<bool>? textless,
    Expression<bool>? booster,
    Expression<bool>? storySpotlight,
    Expression<bool>? promo,
    Expression<bool>? reprint,
    Expression<bool>? variation,
    Expression<bool>? reserved,
    Expression<bool>? gameChanger,
    Expression<bool>? oversized,
    Expression<bool>? nonfoil,
    Expression<bool>? foil,
    Expression<bool>? etched,
    Expression<bool>? glossy,
    Expression<bool>? paper,
    Expression<String>? legalStandard,
    Expression<String>? legalFuture,
    Expression<String>? legalHistoric,
    Expression<String>? legalTimeless,
    Expression<String>? legalGladiator,
    Expression<String>? legalPioneer,
    Expression<String>? legalModern,
    Expression<String>? legalLegacy,
    Expression<String>? legalPauper,
    Expression<String>? legalVintage,
    Expression<String>? legalPenny,
    Expression<String>? legalCommander,
    Expression<String>? legalOathbreaker,
    Expression<String>? legalStandardBrawl,
    Expression<String>? legalBrawl,
    Expression<String>? legalCompetitiveBrawl,
    Expression<String>? legalAlchemy,
    Expression<String>? legalPauperCommander,
    Expression<String>? legalDuel,
    Expression<String>? legalOldSchool,
    Expression<String>? legalPremodern,
    Expression<String>? legalPredh,
    Expression<String>? legalTlr,
    Expression<String>? pricesUsd,
    Expression<String>? pricesUsdFoil,
    Expression<String>? pricesUsdEtched,
    Expression<String>? pricesEur,
    Expression<String>? pricesEurFoil,
    Expression<String>? pricesTix,
    Expression<String>? relatedGathererUri,
    Expression<String>? relatedTcgplayerInfiniteArticlesUri,
    Expression<String>? relatedTcgplayerInfiniteDecksUri,
    Expression<String>? relatedEdhrecUri,
    Expression<String>? purchaseTcgplayerUri,
    Expression<String>? purchaseCardmarketUri,
    Expression<String>? purchaseCardhoarderUri,
    Expression<String>? cardBackId,
    Expression<String>? allPartsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scryfallId != null) 'scryfall_id': scryfallId,
      if (oracleId != null) 'oracle_id': oracleId,
      if (tcgplayerId != null) 'tcgplayer_id': tcgplayerId,
      if (cardmarketId != null) 'cardmarket_id': cardmarketId,
      if (multiverseIdsJson != null) 'multiverse_ids_json': multiverseIdsJson,
      if (layout != null) 'layout': layout,
      if (name != null) 'name': name,
      if (printedName != null) 'printed_name': printedName,
      if (flavorName != null) 'flavor_name': flavorName,
      if (setId != null) 'set_id': setId,
      if (setCode != null) 'set_code': setCode,
      if (setName != null) 'set_name': setName,
      if (setType != null) 'set_type': setType,
      if (setUri != null) 'set_uri': setUri,
      if (setSearchUri != null) 'set_search_uri': setSearchUri,
      if (scryfallSetUri != null) 'scryfall_set_uri': scryfallSetUri,
      if (collectorNumber != null) 'collector_number': collectorNumber,
      if (lang != null) 'lang': lang,
      if (rarity != null) 'rarity': rarity,
      if (rarityValue != null) 'rarity_value': rarityValue,
      if (releasedAt != null) 'released_at': releasedAt,
      if (scryfallUri != null) 'scryfall_uri': scryfallUri,
      if (uri != null) 'uri': uri,
      if (rulingsUri != null) 'rulings_uri': rulingsUri,
      if (printsSearchUri != null) 'prints_search_uri': printsSearchUri,
      if (manaCost != null) 'mana_cost': manaCost,
      if (typeLine != null) 'type_line': typeLine,
      if (printedTypeLine != null) 'printed_type_line': printedTypeLine,
      if (oracleText != null) 'oracle_text': oracleText,
      if (printedText != null) 'printed_text': printedText,
      if (flavorText != null) 'flavor_text': flavorText,
      if (colorsJson != null) 'colors_json': colorsJson,
      if (colorMask != null) 'color_mask': colorMask,
      if (colorIdentityJson != null) 'color_identity_json': colorIdentityJson,
      if (colorIdentityMask != null) 'color_identity_mask': colorIdentityMask,
      if (producedManaJson != null) 'produced_mana_json': producedManaJson,
      if (producedManaMask != null) 'produced_mana_mask': producedManaMask,
      if (power != null) 'power': power,
      if (toughness != null) 'toughness': toughness,
      if (loyalty != null) 'loyalty': loyalty,
      if (defense != null) 'defense': defense,
      if (cmc != null) 'cmc': cmc,
      if (keywordsJson != null) 'keywords_json': keywordsJson,
      if (hasCardFaces != null) 'has_card_faces': hasCardFaces,
      if (hasColorIndicator != null) 'has_color_indicator': hasColorIndicator,
      if (borderColor != null) 'border_color': borderColor,
      if (frame != null) 'frame': frame,
      if (frameEffectsJson != null) 'frame_effects_json': frameEffectsJson,
      if (securityStamp != null) 'security_stamp': securityStamp,
      if (highresImage != null) 'highres_image': highresImage,
      if (imageStatus != null) 'image_status': imageStatus,
      if (imageUpdatedAt != null) 'image_updated_at': imageUpdatedAt,
      if (imageSmall != null) 'image_small': imageSmall,
      if (imageNormal != null) 'image_normal': imageNormal,
      if (imageLarge != null) 'image_large': imageLarge,
      if (imagePng != null) 'image_png': imagePng,
      if (imageArtCrop != null) 'image_art_crop': imageArtCrop,
      if (imageBorderCrop != null) 'image_border_crop': imageBorderCrop,
      if (artist != null) 'artist': artist,
      if (artistIdsJson != null) 'artist_ids_json': artistIdsJson,
      if (illustrationId != null) 'illustration_id': illustrationId,
      if (watermark != null) 'watermark': watermark,
      if (fullArt != null) 'full_art': fullArt,
      if (textless != null) 'textless': textless,
      if (booster != null) 'booster': booster,
      if (storySpotlight != null) 'story_spotlight': storySpotlight,
      if (promo != null) 'promo': promo,
      if (reprint != null) 'reprint': reprint,
      if (variation != null) 'variation': variation,
      if (reserved != null) 'reserved': reserved,
      if (gameChanger != null) 'game_changer': gameChanger,
      if (oversized != null) 'oversized': oversized,
      if (nonfoil != null) 'nonfoil': nonfoil,
      if (foil != null) 'foil': foil,
      if (etched != null) 'etched': etched,
      if (glossy != null) 'glossy': glossy,
      if (paper != null) 'paper': paper,
      if (legalStandard != null) 'legal_standard': legalStandard,
      if (legalFuture != null) 'legal_future': legalFuture,
      if (legalHistoric != null) 'legal_historic': legalHistoric,
      if (legalTimeless != null) 'legal_timeless': legalTimeless,
      if (legalGladiator != null) 'legal_gladiator': legalGladiator,
      if (legalPioneer != null) 'legal_pioneer': legalPioneer,
      if (legalModern != null) 'legal_modern': legalModern,
      if (legalLegacy != null) 'legal_legacy': legalLegacy,
      if (legalPauper != null) 'legal_pauper': legalPauper,
      if (legalVintage != null) 'legal_vintage': legalVintage,
      if (legalPenny != null) 'legal_penny': legalPenny,
      if (legalCommander != null) 'legal_commander': legalCommander,
      if (legalOathbreaker != null) 'legal_oathbreaker': legalOathbreaker,
      if (legalStandardBrawl != null)
        'legal_standard_brawl': legalStandardBrawl,
      if (legalBrawl != null) 'legal_brawl': legalBrawl,
      if (legalCompetitiveBrawl != null)
        'legal_competitive_brawl': legalCompetitiveBrawl,
      if (legalAlchemy != null) 'legal_alchemy': legalAlchemy,
      if (legalPauperCommander != null)
        'legal_pauper_commander': legalPauperCommander,
      if (legalDuel != null) 'legal_duel': legalDuel,
      if (legalOldSchool != null) 'legal_old_school': legalOldSchool,
      if (legalPremodern != null) 'legal_premodern': legalPremodern,
      if (legalPredh != null) 'legal_predh': legalPredh,
      if (legalTlr != null) 'legal_tlr': legalTlr,
      if (pricesUsd != null) 'prices_usd': pricesUsd,
      if (pricesUsdFoil != null) 'prices_usd_foil': pricesUsdFoil,
      if (pricesUsdEtched != null) 'prices_usd_etched': pricesUsdEtched,
      if (pricesEur != null) 'prices_eur': pricesEur,
      if (pricesEurFoil != null) 'prices_eur_foil': pricesEurFoil,
      if (pricesTix != null) 'prices_tix': pricesTix,
      if (relatedGathererUri != null)
        'related_gatherer_uri': relatedGathererUri,
      if (relatedTcgplayerInfiniteArticlesUri != null)
        'related_tcgplayer_infinite_articles_uri':
            relatedTcgplayerInfiniteArticlesUri,
      if (relatedTcgplayerInfiniteDecksUri != null)
        'related_tcgplayer_infinite_decks_uri':
            relatedTcgplayerInfiniteDecksUri,
      if (relatedEdhrecUri != null) 'related_edhrec_uri': relatedEdhrecUri,
      if (purchaseTcgplayerUri != null)
        'purchase_tcgplayer_uri': purchaseTcgplayerUri,
      if (purchaseCardmarketUri != null)
        'purchase_cardmarket_uri': purchaseCardmarketUri,
      if (purchaseCardhoarderUri != null)
        'purchase_cardhoarder_uri': purchaseCardhoarderUri,
      if (cardBackId != null) 'card_back_id': cardBackId,
      if (allPartsJson != null) 'all_parts_json': allPartsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScryfallCardsCompanion copyWith({
    Value<String>? scryfallId,
    Value<String?>? oracleId,
    Value<String?>? tcgplayerId,
    Value<String?>? cardmarketId,
    Value<String?>? multiverseIdsJson,
    Value<String>? layout,
    Value<String>? name,
    Value<String?>? printedName,
    Value<String?>? flavorName,
    Value<String>? setId,
    Value<String>? setCode,
    Value<String>? setName,
    Value<String>? setType,
    Value<String>? setUri,
    Value<String>? setSearchUri,
    Value<String>? scryfallSetUri,
    Value<String>? collectorNumber,
    Value<String>? lang,
    Value<String>? rarity,
    Value<int>? rarityValue,
    Value<String>? releasedAt,
    Value<String>? scryfallUri,
    Value<String>? uri,
    Value<String>? rulingsUri,
    Value<String>? printsSearchUri,
    Value<String?>? manaCost,
    Value<String>? typeLine,
    Value<String?>? printedTypeLine,
    Value<String?>? oracleText,
    Value<String?>? printedText,
    Value<String?>? flavorText,
    Value<String?>? colorsJson,
    Value<int>? colorMask,
    Value<String?>? colorIdentityJson,
    Value<int>? colorIdentityMask,
    Value<String?>? producedManaJson,
    Value<int>? producedManaMask,
    Value<String?>? power,
    Value<String?>? toughness,
    Value<String?>? loyalty,
    Value<String?>? defense,
    Value<double>? cmc,
    Value<String?>? keywordsJson,
    Value<bool>? hasCardFaces,
    Value<bool>? hasColorIndicator,
    Value<String?>? borderColor,
    Value<String?>? frame,
    Value<String?>? frameEffectsJson,
    Value<String?>? securityStamp,
    Value<bool>? highresImage,
    Value<String?>? imageStatus,
    Value<String?>? imageUpdatedAt,
    Value<String?>? imageSmall,
    Value<String?>? imageNormal,
    Value<String?>? imageLarge,
    Value<String?>? imagePng,
    Value<String?>? imageArtCrop,
    Value<String?>? imageBorderCrop,
    Value<String?>? artist,
    Value<String?>? artistIdsJson,
    Value<String?>? illustrationId,
    Value<String?>? watermark,
    Value<bool>? fullArt,
    Value<bool>? textless,
    Value<bool>? booster,
    Value<bool>? storySpotlight,
    Value<bool>? promo,
    Value<bool>? reprint,
    Value<bool>? variation,
    Value<bool>? reserved,
    Value<bool>? gameChanger,
    Value<bool>? oversized,
    Value<bool>? nonfoil,
    Value<bool>? foil,
    Value<bool>? etched,
    Value<bool>? glossy,
    Value<bool>? paper,
    Value<String?>? legalStandard,
    Value<String?>? legalFuture,
    Value<String?>? legalHistoric,
    Value<String?>? legalTimeless,
    Value<String?>? legalGladiator,
    Value<String?>? legalPioneer,
    Value<String?>? legalModern,
    Value<String?>? legalLegacy,
    Value<String?>? legalPauper,
    Value<String?>? legalVintage,
    Value<String?>? legalPenny,
    Value<String?>? legalCommander,
    Value<String?>? legalOathbreaker,
    Value<String?>? legalStandardBrawl,
    Value<String?>? legalBrawl,
    Value<String?>? legalCompetitiveBrawl,
    Value<String?>? legalAlchemy,
    Value<String?>? legalPauperCommander,
    Value<String?>? legalDuel,
    Value<String?>? legalOldSchool,
    Value<String?>? legalPremodern,
    Value<String?>? legalPredh,
    Value<String?>? legalTlr,
    Value<String?>? pricesUsd,
    Value<String?>? pricesUsdFoil,
    Value<String?>? pricesUsdEtched,
    Value<String?>? pricesEur,
    Value<String?>? pricesEurFoil,
    Value<String?>? pricesTix,
    Value<String?>? relatedGathererUri,
    Value<String?>? relatedTcgplayerInfiniteArticlesUri,
    Value<String?>? relatedTcgplayerInfiniteDecksUri,
    Value<String?>? relatedEdhrecUri,
    Value<String?>? purchaseTcgplayerUri,
    Value<String?>? purchaseCardmarketUri,
    Value<String?>? purchaseCardhoarderUri,
    Value<String?>? cardBackId,
    Value<String?>? allPartsJson,
    Value<int>? rowid,
  }) {
    return ScryfallCardsCompanion(
      scryfallId: scryfallId ?? this.scryfallId,
      oracleId: oracleId ?? this.oracleId,
      tcgplayerId: tcgplayerId ?? this.tcgplayerId,
      cardmarketId: cardmarketId ?? this.cardmarketId,
      multiverseIdsJson: multiverseIdsJson ?? this.multiverseIdsJson,
      layout: layout ?? this.layout,
      name: name ?? this.name,
      printedName: printedName ?? this.printedName,
      flavorName: flavorName ?? this.flavorName,
      setId: setId ?? this.setId,
      setCode: setCode ?? this.setCode,
      setName: setName ?? this.setName,
      setType: setType ?? this.setType,
      setUri: setUri ?? this.setUri,
      setSearchUri: setSearchUri ?? this.setSearchUri,
      scryfallSetUri: scryfallSetUri ?? this.scryfallSetUri,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      lang: lang ?? this.lang,
      rarity: rarity ?? this.rarity,
      rarityValue: rarityValue ?? this.rarityValue,
      releasedAt: releasedAt ?? this.releasedAt,
      scryfallUri: scryfallUri ?? this.scryfallUri,
      uri: uri ?? this.uri,
      rulingsUri: rulingsUri ?? this.rulingsUri,
      printsSearchUri: printsSearchUri ?? this.printsSearchUri,
      manaCost: manaCost ?? this.manaCost,
      typeLine: typeLine ?? this.typeLine,
      printedTypeLine: printedTypeLine ?? this.printedTypeLine,
      oracleText: oracleText ?? this.oracleText,
      printedText: printedText ?? this.printedText,
      flavorText: flavorText ?? this.flavorText,
      colorsJson: colorsJson ?? this.colorsJson,
      colorMask: colorMask ?? this.colorMask,
      colorIdentityJson: colorIdentityJson ?? this.colorIdentityJson,
      colorIdentityMask: colorIdentityMask ?? this.colorIdentityMask,
      producedManaJson: producedManaJson ?? this.producedManaJson,
      producedManaMask: producedManaMask ?? this.producedManaMask,
      power: power ?? this.power,
      toughness: toughness ?? this.toughness,
      loyalty: loyalty ?? this.loyalty,
      defense: defense ?? this.defense,
      cmc: cmc ?? this.cmc,
      keywordsJson: keywordsJson ?? this.keywordsJson,
      hasCardFaces: hasCardFaces ?? this.hasCardFaces,
      hasColorIndicator: hasColorIndicator ?? this.hasColorIndicator,
      borderColor: borderColor ?? this.borderColor,
      frame: frame ?? this.frame,
      frameEffectsJson: frameEffectsJson ?? this.frameEffectsJson,
      securityStamp: securityStamp ?? this.securityStamp,
      highresImage: highresImage ?? this.highresImage,
      imageStatus: imageStatus ?? this.imageStatus,
      imageUpdatedAt: imageUpdatedAt ?? this.imageUpdatedAt,
      imageSmall: imageSmall ?? this.imageSmall,
      imageNormal: imageNormal ?? this.imageNormal,
      imageLarge: imageLarge ?? this.imageLarge,
      imagePng: imagePng ?? this.imagePng,
      imageArtCrop: imageArtCrop ?? this.imageArtCrop,
      imageBorderCrop: imageBorderCrop ?? this.imageBorderCrop,
      artist: artist ?? this.artist,
      artistIdsJson: artistIdsJson ?? this.artistIdsJson,
      illustrationId: illustrationId ?? this.illustrationId,
      watermark: watermark ?? this.watermark,
      fullArt: fullArt ?? this.fullArt,
      textless: textless ?? this.textless,
      booster: booster ?? this.booster,
      storySpotlight: storySpotlight ?? this.storySpotlight,
      promo: promo ?? this.promo,
      reprint: reprint ?? this.reprint,
      variation: variation ?? this.variation,
      reserved: reserved ?? this.reserved,
      gameChanger: gameChanger ?? this.gameChanger,
      oversized: oversized ?? this.oversized,
      nonfoil: nonfoil ?? this.nonfoil,
      foil: foil ?? this.foil,
      etched: etched ?? this.etched,
      glossy: glossy ?? this.glossy,
      paper: paper ?? this.paper,
      legalStandard: legalStandard ?? this.legalStandard,
      legalFuture: legalFuture ?? this.legalFuture,
      legalHistoric: legalHistoric ?? this.legalHistoric,
      legalTimeless: legalTimeless ?? this.legalTimeless,
      legalGladiator: legalGladiator ?? this.legalGladiator,
      legalPioneer: legalPioneer ?? this.legalPioneer,
      legalModern: legalModern ?? this.legalModern,
      legalLegacy: legalLegacy ?? this.legalLegacy,
      legalPauper: legalPauper ?? this.legalPauper,
      legalVintage: legalVintage ?? this.legalVintage,
      legalPenny: legalPenny ?? this.legalPenny,
      legalCommander: legalCommander ?? this.legalCommander,
      legalOathbreaker: legalOathbreaker ?? this.legalOathbreaker,
      legalStandardBrawl: legalStandardBrawl ?? this.legalStandardBrawl,
      legalBrawl: legalBrawl ?? this.legalBrawl,
      legalCompetitiveBrawl:
          legalCompetitiveBrawl ?? this.legalCompetitiveBrawl,
      legalAlchemy: legalAlchemy ?? this.legalAlchemy,
      legalPauperCommander: legalPauperCommander ?? this.legalPauperCommander,
      legalDuel: legalDuel ?? this.legalDuel,
      legalOldSchool: legalOldSchool ?? this.legalOldSchool,
      legalPremodern: legalPremodern ?? this.legalPremodern,
      legalPredh: legalPredh ?? this.legalPredh,
      legalTlr: legalTlr ?? this.legalTlr,
      pricesUsd: pricesUsd ?? this.pricesUsd,
      pricesUsdFoil: pricesUsdFoil ?? this.pricesUsdFoil,
      pricesUsdEtched: pricesUsdEtched ?? this.pricesUsdEtched,
      pricesEur: pricesEur ?? this.pricesEur,
      pricesEurFoil: pricesEurFoil ?? this.pricesEurFoil,
      pricesTix: pricesTix ?? this.pricesTix,
      relatedGathererUri: relatedGathererUri ?? this.relatedGathererUri,
      relatedTcgplayerInfiniteArticlesUri:
          relatedTcgplayerInfiniteArticlesUri ??
          this.relatedTcgplayerInfiniteArticlesUri,
      relatedTcgplayerInfiniteDecksUri:
          relatedTcgplayerInfiniteDecksUri ??
          this.relatedTcgplayerInfiniteDecksUri,
      relatedEdhrecUri: relatedEdhrecUri ?? this.relatedEdhrecUri,
      purchaseTcgplayerUri: purchaseTcgplayerUri ?? this.purchaseTcgplayerUri,
      purchaseCardmarketUri:
          purchaseCardmarketUri ?? this.purchaseCardmarketUri,
      purchaseCardhoarderUri:
          purchaseCardhoarderUri ?? this.purchaseCardhoarderUri,
      cardBackId: cardBackId ?? this.cardBackId,
      allPartsJson: allPartsJson ?? this.allPartsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scryfallId.present) {
      map['scryfall_id'] = Variable<String>(scryfallId.value);
    }
    if (oracleId.present) {
      map['oracle_id'] = Variable<String>(oracleId.value);
    }
    if (tcgplayerId.present) {
      map['tcgplayer_id'] = Variable<String>(tcgplayerId.value);
    }
    if (cardmarketId.present) {
      map['cardmarket_id'] = Variable<String>(cardmarketId.value);
    }
    if (multiverseIdsJson.present) {
      map['multiverse_ids_json'] = Variable<String>(multiverseIdsJson.value);
    }
    if (layout.present) {
      map['layout'] = Variable<String>(layout.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (printedName.present) {
      map['printed_name'] = Variable<String>(printedName.value);
    }
    if (flavorName.present) {
      map['flavor_name'] = Variable<String>(flavorName.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (setType.present) {
      map['set_type'] = Variable<String>(setType.value);
    }
    if (setUri.present) {
      map['set_uri'] = Variable<String>(setUri.value);
    }
    if (setSearchUri.present) {
      map['set_search_uri'] = Variable<String>(setSearchUri.value);
    }
    if (scryfallSetUri.present) {
      map['scryfall_set_uri'] = Variable<String>(scryfallSetUri.value);
    }
    if (collectorNumber.present) {
      map['collector_number'] = Variable<String>(collectorNumber.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (rarityValue.present) {
      map['rarity_value'] = Variable<int>(rarityValue.value);
    }
    if (releasedAt.present) {
      map['released_at'] = Variable<String>(releasedAt.value);
    }
    if (scryfallUri.present) {
      map['scryfall_uri'] = Variable<String>(scryfallUri.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (rulingsUri.present) {
      map['rulings_uri'] = Variable<String>(rulingsUri.value);
    }
    if (printsSearchUri.present) {
      map['prints_search_uri'] = Variable<String>(printsSearchUri.value);
    }
    if (manaCost.present) {
      map['mana_cost'] = Variable<String>(manaCost.value);
    }
    if (typeLine.present) {
      map['type_line'] = Variable<String>(typeLine.value);
    }
    if (printedTypeLine.present) {
      map['printed_type_line'] = Variable<String>(printedTypeLine.value);
    }
    if (oracleText.present) {
      map['oracle_text'] = Variable<String>(oracleText.value);
    }
    if (printedText.present) {
      map['printed_text'] = Variable<String>(printedText.value);
    }
    if (flavorText.present) {
      map['flavor_text'] = Variable<String>(flavorText.value);
    }
    if (colorsJson.present) {
      map['colors_json'] = Variable<String>(colorsJson.value);
    }
    if (colorMask.present) {
      map['color_mask'] = Variable<int>(colorMask.value);
    }
    if (colorIdentityJson.present) {
      map['color_identity_json'] = Variable<String>(colorIdentityJson.value);
    }
    if (colorIdentityMask.present) {
      map['color_identity_mask'] = Variable<int>(colorIdentityMask.value);
    }
    if (producedManaJson.present) {
      map['produced_mana_json'] = Variable<String>(producedManaJson.value);
    }
    if (producedManaMask.present) {
      map['produced_mana_mask'] = Variable<int>(producedManaMask.value);
    }
    if (power.present) {
      map['power'] = Variable<String>(power.value);
    }
    if (toughness.present) {
      map['toughness'] = Variable<String>(toughness.value);
    }
    if (loyalty.present) {
      map['loyalty'] = Variable<String>(loyalty.value);
    }
    if (defense.present) {
      map['defense'] = Variable<String>(defense.value);
    }
    if (cmc.present) {
      map['cmc'] = Variable<double>(cmc.value);
    }
    if (keywordsJson.present) {
      map['keywords_json'] = Variable<String>(keywordsJson.value);
    }
    if (hasCardFaces.present) {
      map['has_card_faces'] = Variable<bool>(hasCardFaces.value);
    }
    if (hasColorIndicator.present) {
      map['has_color_indicator'] = Variable<bool>(hasColorIndicator.value);
    }
    if (borderColor.present) {
      map['border_color'] = Variable<String>(borderColor.value);
    }
    if (frame.present) {
      map['frame'] = Variable<String>(frame.value);
    }
    if (frameEffectsJson.present) {
      map['frame_effects_json'] = Variable<String>(frameEffectsJson.value);
    }
    if (securityStamp.present) {
      map['security_stamp'] = Variable<String>(securityStamp.value);
    }
    if (highresImage.present) {
      map['highres_image'] = Variable<bool>(highresImage.value);
    }
    if (imageStatus.present) {
      map['image_status'] = Variable<String>(imageStatus.value);
    }
    if (imageUpdatedAt.present) {
      map['image_updated_at'] = Variable<String>(imageUpdatedAt.value);
    }
    if (imageSmall.present) {
      map['image_small'] = Variable<String>(imageSmall.value);
    }
    if (imageNormal.present) {
      map['image_normal'] = Variable<String>(imageNormal.value);
    }
    if (imageLarge.present) {
      map['image_large'] = Variable<String>(imageLarge.value);
    }
    if (imagePng.present) {
      map['image_png'] = Variable<String>(imagePng.value);
    }
    if (imageArtCrop.present) {
      map['image_art_crop'] = Variable<String>(imageArtCrop.value);
    }
    if (imageBorderCrop.present) {
      map['image_border_crop'] = Variable<String>(imageBorderCrop.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistIdsJson.present) {
      map['artist_ids_json'] = Variable<String>(artistIdsJson.value);
    }
    if (illustrationId.present) {
      map['illustration_id'] = Variable<String>(illustrationId.value);
    }
    if (watermark.present) {
      map['watermark'] = Variable<String>(watermark.value);
    }
    if (fullArt.present) {
      map['full_art'] = Variable<bool>(fullArt.value);
    }
    if (textless.present) {
      map['textless'] = Variable<bool>(textless.value);
    }
    if (booster.present) {
      map['booster'] = Variable<bool>(booster.value);
    }
    if (storySpotlight.present) {
      map['story_spotlight'] = Variable<bool>(storySpotlight.value);
    }
    if (promo.present) {
      map['promo'] = Variable<bool>(promo.value);
    }
    if (reprint.present) {
      map['reprint'] = Variable<bool>(reprint.value);
    }
    if (variation.present) {
      map['variation'] = Variable<bool>(variation.value);
    }
    if (reserved.present) {
      map['reserved'] = Variable<bool>(reserved.value);
    }
    if (gameChanger.present) {
      map['game_changer'] = Variable<bool>(gameChanger.value);
    }
    if (oversized.present) {
      map['oversized'] = Variable<bool>(oversized.value);
    }
    if (nonfoil.present) {
      map['nonfoil'] = Variable<bool>(nonfoil.value);
    }
    if (foil.present) {
      map['foil'] = Variable<bool>(foil.value);
    }
    if (etched.present) {
      map['etched'] = Variable<bool>(etched.value);
    }
    if (glossy.present) {
      map['glossy'] = Variable<bool>(glossy.value);
    }
    if (paper.present) {
      map['paper'] = Variable<bool>(paper.value);
    }
    if (legalStandard.present) {
      map['legal_standard'] = Variable<String>(legalStandard.value);
    }
    if (legalFuture.present) {
      map['legal_future'] = Variable<String>(legalFuture.value);
    }
    if (legalHistoric.present) {
      map['legal_historic'] = Variable<String>(legalHistoric.value);
    }
    if (legalTimeless.present) {
      map['legal_timeless'] = Variable<String>(legalTimeless.value);
    }
    if (legalGladiator.present) {
      map['legal_gladiator'] = Variable<String>(legalGladiator.value);
    }
    if (legalPioneer.present) {
      map['legal_pioneer'] = Variable<String>(legalPioneer.value);
    }
    if (legalModern.present) {
      map['legal_modern'] = Variable<String>(legalModern.value);
    }
    if (legalLegacy.present) {
      map['legal_legacy'] = Variable<String>(legalLegacy.value);
    }
    if (legalPauper.present) {
      map['legal_pauper'] = Variable<String>(legalPauper.value);
    }
    if (legalVintage.present) {
      map['legal_vintage'] = Variable<String>(legalVintage.value);
    }
    if (legalPenny.present) {
      map['legal_penny'] = Variable<String>(legalPenny.value);
    }
    if (legalCommander.present) {
      map['legal_commander'] = Variable<String>(legalCommander.value);
    }
    if (legalOathbreaker.present) {
      map['legal_oathbreaker'] = Variable<String>(legalOathbreaker.value);
    }
    if (legalStandardBrawl.present) {
      map['legal_standard_brawl'] = Variable<String>(legalStandardBrawl.value);
    }
    if (legalBrawl.present) {
      map['legal_brawl'] = Variable<String>(legalBrawl.value);
    }
    if (legalCompetitiveBrawl.present) {
      map['legal_competitive_brawl'] = Variable<String>(
        legalCompetitiveBrawl.value,
      );
    }
    if (legalAlchemy.present) {
      map['legal_alchemy'] = Variable<String>(legalAlchemy.value);
    }
    if (legalPauperCommander.present) {
      map['legal_pauper_commander'] = Variable<String>(
        legalPauperCommander.value,
      );
    }
    if (legalDuel.present) {
      map['legal_duel'] = Variable<String>(legalDuel.value);
    }
    if (legalOldSchool.present) {
      map['legal_old_school'] = Variable<String>(legalOldSchool.value);
    }
    if (legalPremodern.present) {
      map['legal_premodern'] = Variable<String>(legalPremodern.value);
    }
    if (legalPredh.present) {
      map['legal_predh'] = Variable<String>(legalPredh.value);
    }
    if (legalTlr.present) {
      map['legal_tlr'] = Variable<String>(legalTlr.value);
    }
    if (pricesUsd.present) {
      map['prices_usd'] = Variable<String>(pricesUsd.value);
    }
    if (pricesUsdFoil.present) {
      map['prices_usd_foil'] = Variable<String>(pricesUsdFoil.value);
    }
    if (pricesUsdEtched.present) {
      map['prices_usd_etched'] = Variable<String>(pricesUsdEtched.value);
    }
    if (pricesEur.present) {
      map['prices_eur'] = Variable<String>(pricesEur.value);
    }
    if (pricesEurFoil.present) {
      map['prices_eur_foil'] = Variable<String>(pricesEurFoil.value);
    }
    if (pricesTix.present) {
      map['prices_tix'] = Variable<String>(pricesTix.value);
    }
    if (relatedGathererUri.present) {
      map['related_gatherer_uri'] = Variable<String>(relatedGathererUri.value);
    }
    if (relatedTcgplayerInfiniteArticlesUri.present) {
      map['related_tcgplayer_infinite_articles_uri'] = Variable<String>(
        relatedTcgplayerInfiniteArticlesUri.value,
      );
    }
    if (relatedTcgplayerInfiniteDecksUri.present) {
      map['related_tcgplayer_infinite_decks_uri'] = Variable<String>(
        relatedTcgplayerInfiniteDecksUri.value,
      );
    }
    if (relatedEdhrecUri.present) {
      map['related_edhrec_uri'] = Variable<String>(relatedEdhrecUri.value);
    }
    if (purchaseTcgplayerUri.present) {
      map['purchase_tcgplayer_uri'] = Variable<String>(
        purchaseTcgplayerUri.value,
      );
    }
    if (purchaseCardmarketUri.present) {
      map['purchase_cardmarket_uri'] = Variable<String>(
        purchaseCardmarketUri.value,
      );
    }
    if (purchaseCardhoarderUri.present) {
      map['purchase_cardhoarder_uri'] = Variable<String>(
        purchaseCardhoarderUri.value,
      );
    }
    if (cardBackId.present) {
      map['card_back_id'] = Variable<String>(cardBackId.value);
    }
    if (allPartsJson.present) {
      map['all_parts_json'] = Variable<String>(allPartsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScryfallCardsCompanion(')
          ..write('scryfallId: $scryfallId, ')
          ..write('oracleId: $oracleId, ')
          ..write('tcgplayerId: $tcgplayerId, ')
          ..write('cardmarketId: $cardmarketId, ')
          ..write('multiverseIdsJson: $multiverseIdsJson, ')
          ..write('layout: $layout, ')
          ..write('name: $name, ')
          ..write('printedName: $printedName, ')
          ..write('flavorName: $flavorName, ')
          ..write('setId: $setId, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('setType: $setType, ')
          ..write('setUri: $setUri, ')
          ..write('setSearchUri: $setSearchUri, ')
          ..write('scryfallSetUri: $scryfallSetUri, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('lang: $lang, ')
          ..write('rarity: $rarity, ')
          ..write('rarityValue: $rarityValue, ')
          ..write('releasedAt: $releasedAt, ')
          ..write('scryfallUri: $scryfallUri, ')
          ..write('uri: $uri, ')
          ..write('rulingsUri: $rulingsUri, ')
          ..write('printsSearchUri: $printsSearchUri, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('printedTypeLine: $printedTypeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('printedText: $printedText, ')
          ..write('flavorText: $flavorText, ')
          ..write('colorsJson: $colorsJson, ')
          ..write('colorMask: $colorMask, ')
          ..write('colorIdentityJson: $colorIdentityJson, ')
          ..write('colorIdentityMask: $colorIdentityMask, ')
          ..write('producedManaJson: $producedManaJson, ')
          ..write('producedManaMask: $producedManaMask, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('defense: $defense, ')
          ..write('cmc: $cmc, ')
          ..write('keywordsJson: $keywordsJson, ')
          ..write('hasCardFaces: $hasCardFaces, ')
          ..write('hasColorIndicator: $hasColorIndicator, ')
          ..write('borderColor: $borderColor, ')
          ..write('frame: $frame, ')
          ..write('frameEffectsJson: $frameEffectsJson, ')
          ..write('securityStamp: $securityStamp, ')
          ..write('highresImage: $highresImage, ')
          ..write('imageStatus: $imageStatus, ')
          ..write('imageUpdatedAt: $imageUpdatedAt, ')
          ..write('imageSmall: $imageSmall, ')
          ..write('imageNormal: $imageNormal, ')
          ..write('imageLarge: $imageLarge, ')
          ..write('imagePng: $imagePng, ')
          ..write('imageArtCrop: $imageArtCrop, ')
          ..write('imageBorderCrop: $imageBorderCrop, ')
          ..write('artist: $artist, ')
          ..write('artistIdsJson: $artistIdsJson, ')
          ..write('illustrationId: $illustrationId, ')
          ..write('watermark: $watermark, ')
          ..write('fullArt: $fullArt, ')
          ..write('textless: $textless, ')
          ..write('booster: $booster, ')
          ..write('storySpotlight: $storySpotlight, ')
          ..write('promo: $promo, ')
          ..write('reprint: $reprint, ')
          ..write('variation: $variation, ')
          ..write('reserved: $reserved, ')
          ..write('gameChanger: $gameChanger, ')
          ..write('oversized: $oversized, ')
          ..write('nonfoil: $nonfoil, ')
          ..write('foil: $foil, ')
          ..write('etched: $etched, ')
          ..write('glossy: $glossy, ')
          ..write('paper: $paper, ')
          ..write('legalStandard: $legalStandard, ')
          ..write('legalFuture: $legalFuture, ')
          ..write('legalHistoric: $legalHistoric, ')
          ..write('legalTimeless: $legalTimeless, ')
          ..write('legalGladiator: $legalGladiator, ')
          ..write('legalPioneer: $legalPioneer, ')
          ..write('legalModern: $legalModern, ')
          ..write('legalLegacy: $legalLegacy, ')
          ..write('legalPauper: $legalPauper, ')
          ..write('legalVintage: $legalVintage, ')
          ..write('legalPenny: $legalPenny, ')
          ..write('legalCommander: $legalCommander, ')
          ..write('legalOathbreaker: $legalOathbreaker, ')
          ..write('legalStandardBrawl: $legalStandardBrawl, ')
          ..write('legalBrawl: $legalBrawl, ')
          ..write('legalCompetitiveBrawl: $legalCompetitiveBrawl, ')
          ..write('legalAlchemy: $legalAlchemy, ')
          ..write('legalPauperCommander: $legalPauperCommander, ')
          ..write('legalDuel: $legalDuel, ')
          ..write('legalOldSchool: $legalOldSchool, ')
          ..write('legalPremodern: $legalPremodern, ')
          ..write('legalPredh: $legalPredh, ')
          ..write('legalTlr: $legalTlr, ')
          ..write('pricesUsd: $pricesUsd, ')
          ..write('pricesUsdFoil: $pricesUsdFoil, ')
          ..write('pricesUsdEtched: $pricesUsdEtched, ')
          ..write('pricesEur: $pricesEur, ')
          ..write('pricesEurFoil: $pricesEurFoil, ')
          ..write('pricesTix: $pricesTix, ')
          ..write('relatedGathererUri: $relatedGathererUri, ')
          ..write(
            'relatedTcgplayerInfiniteArticlesUri: $relatedTcgplayerInfiniteArticlesUri, ',
          )
          ..write(
            'relatedTcgplayerInfiniteDecksUri: $relatedTcgplayerInfiniteDecksUri, ',
          )
          ..write('relatedEdhrecUri: $relatedEdhrecUri, ')
          ..write('purchaseTcgplayerUri: $purchaseTcgplayerUri, ')
          ..write('purchaseCardmarketUri: $purchaseCardmarketUri, ')
          ..write('purchaseCardhoarderUri: $purchaseCardhoarderUri, ')
          ..write('cardBackId: $cardBackId, ')
          ..write('allPartsJson: $allPartsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScryfallCardFacesTable extends ScryfallCardFaces
    with TableInfo<$ScryfallCardFacesTable, ScryfallCardFace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScryfallCardFacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scryfall_cards (scryfall_id)',
    ),
  );
  static const VerificationMeta _faceIndexMeta = const VerificationMeta(
    'faceIndex',
  );
  @override
  late final GeneratedColumn<int> faceIndex = GeneratedColumn<int>(
    'face_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printedNameMeta = const VerificationMeta(
    'printedName',
  );
  @override
  late final GeneratedColumn<String> printedName = GeneratedColumn<String>(
    'printed_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorNameMeta = const VerificationMeta(
    'flavorName',
  );
  @override
  late final GeneratedColumn<String> flavorName = GeneratedColumn<String>(
    'flavor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manaCostMeta = const VerificationMeta(
    'manaCost',
  );
  @override
  late final GeneratedColumn<String> manaCost = GeneratedColumn<String>(
    'mana_cost',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeLineMeta = const VerificationMeta(
    'typeLine',
  );
  @override
  late final GeneratedColumn<String> typeLine = GeneratedColumn<String>(
    'type_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printedTypeLineMeta = const VerificationMeta(
    'printedTypeLine',
  );
  @override
  late final GeneratedColumn<String> printedTypeLine = GeneratedColumn<String>(
    'printed_type_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oracleTextMeta = const VerificationMeta(
    'oracleText',
  );
  @override
  late final GeneratedColumn<String> oracleText = GeneratedColumn<String>(
    'oracle_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printedTextMeta = const VerificationMeta(
    'printedText',
  );
  @override
  late final GeneratedColumn<String> printedText = GeneratedColumn<String>(
    'printed_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorTextMeta = const VerificationMeta(
    'flavorText',
  );
  @override
  late final GeneratedColumn<String> flavorText = GeneratedColumn<String>(
    'flavor_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorsJsonMeta = const VerificationMeta(
    'colorsJson',
  );
  @override
  late final GeneratedColumn<String> colorsJson = GeneratedColumn<String>(
    'colors_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMaskMeta = const VerificationMeta(
    'colorMask',
  );
  @override
  late final GeneratedColumn<int> colorMask = GeneratedColumn<int>(
    'color_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorIndicatorJsonMeta =
      const VerificationMeta('colorIndicatorJson');
  @override
  late final GeneratedColumn<String> colorIndicatorJson =
      GeneratedColumn<String>(
        'color_indicator_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _colorIndicatorMaskMeta =
      const VerificationMeta('colorIndicatorMask');
  @override
  late final GeneratedColumn<int> colorIndicatorMask = GeneratedColumn<int>(
    'color_indicator_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<String> power = GeneratedColumn<String>(
    'power',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toughnessMeta = const VerificationMeta(
    'toughness',
  );
  @override
  late final GeneratedColumn<String> toughness = GeneratedColumn<String>(
    'toughness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loyaltyMeta = const VerificationMeta(
    'loyalty',
  );
  @override
  late final GeneratedColumn<String> loyalty = GeneratedColumn<String>(
    'loyalty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defenseMeta = const VerificationMeta(
    'defense',
  );
  @override
  late final GeneratedColumn<String> defense = GeneratedColumn<String>(
    'defense',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cmcMeta = const VerificationMeta('cmc');
  @override
  late final GeneratedColumn<double> cmc = GeneratedColumn<double>(
    'cmc',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _illustrationIdMeta = const VerificationMeta(
    'illustrationId',
  );
  @override
  late final GeneratedColumn<String> illustrationId = GeneratedColumn<String>(
    'illustration_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _highresImageMeta = const VerificationMeta(
    'highresImage',
  );
  @override
  late final GeneratedColumn<bool> highresImage = GeneratedColumn<bool>(
    'highres_image',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("highres_image" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _imageStatusMeta = const VerificationMeta(
    'imageStatus',
  );
  @override
  late final GeneratedColumn<String> imageStatus = GeneratedColumn<String>(
    'image_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageSmallMeta = const VerificationMeta(
    'imageSmall',
  );
  @override
  late final GeneratedColumn<String> imageSmall = GeneratedColumn<String>(
    'image_small',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageNormalMeta = const VerificationMeta(
    'imageNormal',
  );
  @override
  late final GeneratedColumn<String> imageNormal = GeneratedColumn<String>(
    'image_normal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageLargeMeta = const VerificationMeta(
    'imageLarge',
  );
  @override
  late final GeneratedColumn<String> imageLarge = GeneratedColumn<String>(
    'image_large',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePngMeta = const VerificationMeta(
    'imagePng',
  );
  @override
  late final GeneratedColumn<String> imagePng = GeneratedColumn<String>(
    'image_png',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageArtCropMeta = const VerificationMeta(
    'imageArtCrop',
  );
  @override
  late final GeneratedColumn<String> imageArtCrop = GeneratedColumn<String>(
    'image_art_crop',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageBorderCropMeta = const VerificationMeta(
    'imageBorderCrop',
  );
  @override
  late final GeneratedColumn<String> imageBorderCrop = GeneratedColumn<String>(
    'image_border_crop',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watermarkMeta = const VerificationMeta(
    'watermark',
  );
  @override
  late final GeneratedColumn<String> watermark = GeneratedColumn<String>(
    'watermark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    faceIndex,
    name,
    printedName,
    flavorName,
    manaCost,
    typeLine,
    printedTypeLine,
    oracleText,
    printedText,
    flavorText,
    colorsJson,
    colorMask,
    colorIndicatorJson,
    colorIndicatorMask,
    power,
    toughness,
    loyalty,
    defense,
    cmc,
    artist,
    artistId,
    illustrationId,
    highresImage,
    imageStatus,
    imageSmall,
    imageNormal,
    imageLarge,
    imagePng,
    imageArtCrop,
    imageBorderCrop,
    watermark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scryfall_card_faces';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScryfallCardFace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('face_index')) {
      context.handle(
        _faceIndexMeta,
        faceIndex.isAcceptableOrUnknown(data['face_index']!, _faceIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_faceIndexMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('printed_name')) {
      context.handle(
        _printedNameMeta,
        printedName.isAcceptableOrUnknown(
          data['printed_name']!,
          _printedNameMeta,
        ),
      );
    }
    if (data.containsKey('flavor_name')) {
      context.handle(
        _flavorNameMeta,
        flavorName.isAcceptableOrUnknown(data['flavor_name']!, _flavorNameMeta),
      );
    }
    if (data.containsKey('mana_cost')) {
      context.handle(
        _manaCostMeta,
        manaCost.isAcceptableOrUnknown(data['mana_cost']!, _manaCostMeta),
      );
    }
    if (data.containsKey('type_line')) {
      context.handle(
        _typeLineMeta,
        typeLine.isAcceptableOrUnknown(data['type_line']!, _typeLineMeta),
      );
    }
    if (data.containsKey('printed_type_line')) {
      context.handle(
        _printedTypeLineMeta,
        printedTypeLine.isAcceptableOrUnknown(
          data['printed_type_line']!,
          _printedTypeLineMeta,
        ),
      );
    }
    if (data.containsKey('oracle_text')) {
      context.handle(
        _oracleTextMeta,
        oracleText.isAcceptableOrUnknown(data['oracle_text']!, _oracleTextMeta),
      );
    }
    if (data.containsKey('printed_text')) {
      context.handle(
        _printedTextMeta,
        printedText.isAcceptableOrUnknown(
          data['printed_text']!,
          _printedTextMeta,
        ),
      );
    }
    if (data.containsKey('flavor_text')) {
      context.handle(
        _flavorTextMeta,
        flavorText.isAcceptableOrUnknown(data['flavor_text']!, _flavorTextMeta),
      );
    }
    if (data.containsKey('colors_json')) {
      context.handle(
        _colorsJsonMeta,
        colorsJson.isAcceptableOrUnknown(data['colors_json']!, _colorsJsonMeta),
      );
    }
    if (data.containsKey('color_mask')) {
      context.handle(
        _colorMaskMeta,
        colorMask.isAcceptableOrUnknown(data['color_mask']!, _colorMaskMeta),
      );
    }
    if (data.containsKey('color_indicator_json')) {
      context.handle(
        _colorIndicatorJsonMeta,
        colorIndicatorJson.isAcceptableOrUnknown(
          data['color_indicator_json']!,
          _colorIndicatorJsonMeta,
        ),
      );
    }
    if (data.containsKey('color_indicator_mask')) {
      context.handle(
        _colorIndicatorMaskMeta,
        colorIndicatorMask.isAcceptableOrUnknown(
          data['color_indicator_mask']!,
          _colorIndicatorMaskMeta,
        ),
      );
    }
    if (data.containsKey('power')) {
      context.handle(
        _powerMeta,
        power.isAcceptableOrUnknown(data['power']!, _powerMeta),
      );
    }
    if (data.containsKey('toughness')) {
      context.handle(
        _toughnessMeta,
        toughness.isAcceptableOrUnknown(data['toughness']!, _toughnessMeta),
      );
    }
    if (data.containsKey('loyalty')) {
      context.handle(
        _loyaltyMeta,
        loyalty.isAcceptableOrUnknown(data['loyalty']!, _loyaltyMeta),
      );
    }
    if (data.containsKey('defense')) {
      context.handle(
        _defenseMeta,
        defense.isAcceptableOrUnknown(data['defense']!, _defenseMeta),
      );
    }
    if (data.containsKey('cmc')) {
      context.handle(
        _cmcMeta,
        cmc.isAcceptableOrUnknown(data['cmc']!, _cmcMeta),
      );
    } else if (isInserting) {
      context.missing(_cmcMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('illustration_id')) {
      context.handle(
        _illustrationIdMeta,
        illustrationId.isAcceptableOrUnknown(
          data['illustration_id']!,
          _illustrationIdMeta,
        ),
      );
    }
    if (data.containsKey('highres_image')) {
      context.handle(
        _highresImageMeta,
        highresImage.isAcceptableOrUnknown(
          data['highres_image']!,
          _highresImageMeta,
        ),
      );
    }
    if (data.containsKey('image_status')) {
      context.handle(
        _imageStatusMeta,
        imageStatus.isAcceptableOrUnknown(
          data['image_status']!,
          _imageStatusMeta,
        ),
      );
    }
    if (data.containsKey('image_small')) {
      context.handle(
        _imageSmallMeta,
        imageSmall.isAcceptableOrUnknown(data['image_small']!, _imageSmallMeta),
      );
    }
    if (data.containsKey('image_normal')) {
      context.handle(
        _imageNormalMeta,
        imageNormal.isAcceptableOrUnknown(
          data['image_normal']!,
          _imageNormalMeta,
        ),
      );
    }
    if (data.containsKey('image_large')) {
      context.handle(
        _imageLargeMeta,
        imageLarge.isAcceptableOrUnknown(data['image_large']!, _imageLargeMeta),
      );
    }
    if (data.containsKey('image_png')) {
      context.handle(
        _imagePngMeta,
        imagePng.isAcceptableOrUnknown(data['image_png']!, _imagePngMeta),
      );
    }
    if (data.containsKey('image_art_crop')) {
      context.handle(
        _imageArtCropMeta,
        imageArtCrop.isAcceptableOrUnknown(
          data['image_art_crop']!,
          _imageArtCropMeta,
        ),
      );
    }
    if (data.containsKey('image_border_crop')) {
      context.handle(
        _imageBorderCropMeta,
        imageBorderCrop.isAcceptableOrUnknown(
          data['image_border_crop']!,
          _imageBorderCropMeta,
        ),
      );
    }
    if (data.containsKey('watermark')) {
      context.handle(
        _watermarkMeta,
        watermark.isAcceptableOrUnknown(data['watermark']!, _watermarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, faceIndex};
  @override
  ScryfallCardFace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScryfallCardFace(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      faceIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}face_index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      printedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printed_name'],
      ),
      flavorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_name'],
      ),
      manaCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mana_cost'],
      ),
      typeLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_line'],
      ),
      printedTypeLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printed_type_line'],
      ),
      oracleText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oracle_text'],
      ),
      printedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printed_text'],
      ),
      flavorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_text'],
      ),
      colorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colors_json'],
      ),
      colorMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_mask'],
      )!,
      colorIndicatorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_indicator_json'],
      ),
      colorIndicatorMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_indicator_mask'],
      )!,
      power: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}power'],
      ),
      toughness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toughness'],
      ),
      loyalty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loyalty'],
      ),
      defense: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}defense'],
      ),
      cmc: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cmc'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      illustrationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}illustration_id'],
      ),
      highresImage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}highres_image'],
      )!,
      imageStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_status'],
      ),
      imageSmall: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_small'],
      ),
      imageNormal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_normal'],
      ),
      imageLarge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_large'],
      ),
      imagePng: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_png'],
      ),
      imageArtCrop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_art_crop'],
      ),
      imageBorderCrop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_border_crop'],
      ),
      watermark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watermark'],
      ),
    );
  }

  @override
  $ScryfallCardFacesTable createAlias(String alias) {
    return $ScryfallCardFacesTable(attachedDatabase, alias);
  }
}

class ScryfallCardFace extends DataClass
    implements Insertable<ScryfallCardFace> {
  final String cardId;
  final int faceIndex;
  final String name;
  final String? printedName;
  final String? flavorName;
  final String? manaCost;
  final String? typeLine;
  final String? printedTypeLine;
  final String? oracleText;
  final String? printedText;
  final String? flavorText;
  final String? colorsJson;
  final int colorMask;
  final String? colorIndicatorJson;
  final int colorIndicatorMask;
  final String? power;
  final String? toughness;
  final String? loyalty;
  final String? defense;
  final double cmc;
  final String? artist;
  final String? artistId;
  final String? illustrationId;
  final bool highresImage;
  final String? imageStatus;
  final String? imageSmall;
  final String? imageNormal;
  final String? imageLarge;
  final String? imagePng;
  final String? imageArtCrop;
  final String? imageBorderCrop;
  final String? watermark;
  const ScryfallCardFace({
    required this.cardId,
    required this.faceIndex,
    required this.name,
    this.printedName,
    this.flavorName,
    this.manaCost,
    this.typeLine,
    this.printedTypeLine,
    this.oracleText,
    this.printedText,
    this.flavorText,
    this.colorsJson,
    required this.colorMask,
    this.colorIndicatorJson,
    required this.colorIndicatorMask,
    this.power,
    this.toughness,
    this.loyalty,
    this.defense,
    required this.cmc,
    this.artist,
    this.artistId,
    this.illustrationId,
    required this.highresImage,
    this.imageStatus,
    this.imageSmall,
    this.imageNormal,
    this.imageLarge,
    this.imagePng,
    this.imageArtCrop,
    this.imageBorderCrop,
    this.watermark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['face_index'] = Variable<int>(faceIndex);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || printedName != null) {
      map['printed_name'] = Variable<String>(printedName);
    }
    if (!nullToAbsent || flavorName != null) {
      map['flavor_name'] = Variable<String>(flavorName);
    }
    if (!nullToAbsent || manaCost != null) {
      map['mana_cost'] = Variable<String>(manaCost);
    }
    if (!nullToAbsent || typeLine != null) {
      map['type_line'] = Variable<String>(typeLine);
    }
    if (!nullToAbsent || printedTypeLine != null) {
      map['printed_type_line'] = Variable<String>(printedTypeLine);
    }
    if (!nullToAbsent || oracleText != null) {
      map['oracle_text'] = Variable<String>(oracleText);
    }
    if (!nullToAbsent || printedText != null) {
      map['printed_text'] = Variable<String>(printedText);
    }
    if (!nullToAbsent || flavorText != null) {
      map['flavor_text'] = Variable<String>(flavorText);
    }
    if (!nullToAbsent || colorsJson != null) {
      map['colors_json'] = Variable<String>(colorsJson);
    }
    map['color_mask'] = Variable<int>(colorMask);
    if (!nullToAbsent || colorIndicatorJson != null) {
      map['color_indicator_json'] = Variable<String>(colorIndicatorJson);
    }
    map['color_indicator_mask'] = Variable<int>(colorIndicatorMask);
    if (!nullToAbsent || power != null) {
      map['power'] = Variable<String>(power);
    }
    if (!nullToAbsent || toughness != null) {
      map['toughness'] = Variable<String>(toughness);
    }
    if (!nullToAbsent || loyalty != null) {
      map['loyalty'] = Variable<String>(loyalty);
    }
    if (!nullToAbsent || defense != null) {
      map['defense'] = Variable<String>(defense);
    }
    map['cmc'] = Variable<double>(cmc);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    if (!nullToAbsent || illustrationId != null) {
      map['illustration_id'] = Variable<String>(illustrationId);
    }
    map['highres_image'] = Variable<bool>(highresImage);
    if (!nullToAbsent || imageStatus != null) {
      map['image_status'] = Variable<String>(imageStatus);
    }
    if (!nullToAbsent || imageSmall != null) {
      map['image_small'] = Variable<String>(imageSmall);
    }
    if (!nullToAbsent || imageNormal != null) {
      map['image_normal'] = Variable<String>(imageNormal);
    }
    if (!nullToAbsent || imageLarge != null) {
      map['image_large'] = Variable<String>(imageLarge);
    }
    if (!nullToAbsent || imagePng != null) {
      map['image_png'] = Variable<String>(imagePng);
    }
    if (!nullToAbsent || imageArtCrop != null) {
      map['image_art_crop'] = Variable<String>(imageArtCrop);
    }
    if (!nullToAbsent || imageBorderCrop != null) {
      map['image_border_crop'] = Variable<String>(imageBorderCrop);
    }
    if (!nullToAbsent || watermark != null) {
      map['watermark'] = Variable<String>(watermark);
    }
    return map;
  }

  ScryfallCardFacesCompanion toCompanion(bool nullToAbsent) {
    return ScryfallCardFacesCompanion(
      cardId: Value(cardId),
      faceIndex: Value(faceIndex),
      name: Value(name),
      printedName: printedName == null && nullToAbsent
          ? const Value.absent()
          : Value(printedName),
      flavorName: flavorName == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorName),
      manaCost: manaCost == null && nullToAbsent
          ? const Value.absent()
          : Value(manaCost),
      typeLine: typeLine == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLine),
      printedTypeLine: printedTypeLine == null && nullToAbsent
          ? const Value.absent()
          : Value(printedTypeLine),
      oracleText: oracleText == null && nullToAbsent
          ? const Value.absent()
          : Value(oracleText),
      printedText: printedText == null && nullToAbsent
          ? const Value.absent()
          : Value(printedText),
      flavorText: flavorText == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorText),
      colorsJson: colorsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(colorsJson),
      colorMask: Value(colorMask),
      colorIndicatorJson: colorIndicatorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(colorIndicatorJson),
      colorIndicatorMask: Value(colorIndicatorMask),
      power: power == null && nullToAbsent
          ? const Value.absent()
          : Value(power),
      toughness: toughness == null && nullToAbsent
          ? const Value.absent()
          : Value(toughness),
      loyalty: loyalty == null && nullToAbsent
          ? const Value.absent()
          : Value(loyalty),
      defense: defense == null && nullToAbsent
          ? const Value.absent()
          : Value(defense),
      cmc: Value(cmc),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      illustrationId: illustrationId == null && nullToAbsent
          ? const Value.absent()
          : Value(illustrationId),
      highresImage: Value(highresImage),
      imageStatus: imageStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(imageStatus),
      imageSmall: imageSmall == null && nullToAbsent
          ? const Value.absent()
          : Value(imageSmall),
      imageNormal: imageNormal == null && nullToAbsent
          ? const Value.absent()
          : Value(imageNormal),
      imageLarge: imageLarge == null && nullToAbsent
          ? const Value.absent()
          : Value(imageLarge),
      imagePng: imagePng == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePng),
      imageArtCrop: imageArtCrop == null && nullToAbsent
          ? const Value.absent()
          : Value(imageArtCrop),
      imageBorderCrop: imageBorderCrop == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBorderCrop),
      watermark: watermark == null && nullToAbsent
          ? const Value.absent()
          : Value(watermark),
    );
  }

  factory ScryfallCardFace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScryfallCardFace(
      cardId: serializer.fromJson<String>(json['cardId']),
      faceIndex: serializer.fromJson<int>(json['faceIndex']),
      name: serializer.fromJson<String>(json['name']),
      printedName: serializer.fromJson<String?>(json['printedName']),
      flavorName: serializer.fromJson<String?>(json['flavorName']),
      manaCost: serializer.fromJson<String?>(json['manaCost']),
      typeLine: serializer.fromJson<String?>(json['typeLine']),
      printedTypeLine: serializer.fromJson<String?>(json['printedTypeLine']),
      oracleText: serializer.fromJson<String?>(json['oracleText']),
      printedText: serializer.fromJson<String?>(json['printedText']),
      flavorText: serializer.fromJson<String?>(json['flavorText']),
      colorsJson: serializer.fromJson<String?>(json['colorsJson']),
      colorMask: serializer.fromJson<int>(json['colorMask']),
      colorIndicatorJson: serializer.fromJson<String?>(
        json['colorIndicatorJson'],
      ),
      colorIndicatorMask: serializer.fromJson<int>(json['colorIndicatorMask']),
      power: serializer.fromJson<String?>(json['power']),
      toughness: serializer.fromJson<String?>(json['toughness']),
      loyalty: serializer.fromJson<String?>(json['loyalty']),
      defense: serializer.fromJson<String?>(json['defense']),
      cmc: serializer.fromJson<double>(json['cmc']),
      artist: serializer.fromJson<String?>(json['artist']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      illustrationId: serializer.fromJson<String?>(json['illustrationId']),
      highresImage: serializer.fromJson<bool>(json['highresImage']),
      imageStatus: serializer.fromJson<String?>(json['imageStatus']),
      imageSmall: serializer.fromJson<String?>(json['imageSmall']),
      imageNormal: serializer.fromJson<String?>(json['imageNormal']),
      imageLarge: serializer.fromJson<String?>(json['imageLarge']),
      imagePng: serializer.fromJson<String?>(json['imagePng']),
      imageArtCrop: serializer.fromJson<String?>(json['imageArtCrop']),
      imageBorderCrop: serializer.fromJson<String?>(json['imageBorderCrop']),
      watermark: serializer.fromJson<String?>(json['watermark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'faceIndex': serializer.toJson<int>(faceIndex),
      'name': serializer.toJson<String>(name),
      'printedName': serializer.toJson<String?>(printedName),
      'flavorName': serializer.toJson<String?>(flavorName),
      'manaCost': serializer.toJson<String?>(manaCost),
      'typeLine': serializer.toJson<String?>(typeLine),
      'printedTypeLine': serializer.toJson<String?>(printedTypeLine),
      'oracleText': serializer.toJson<String?>(oracleText),
      'printedText': serializer.toJson<String?>(printedText),
      'flavorText': serializer.toJson<String?>(flavorText),
      'colorsJson': serializer.toJson<String?>(colorsJson),
      'colorMask': serializer.toJson<int>(colorMask),
      'colorIndicatorJson': serializer.toJson<String?>(colorIndicatorJson),
      'colorIndicatorMask': serializer.toJson<int>(colorIndicatorMask),
      'power': serializer.toJson<String?>(power),
      'toughness': serializer.toJson<String?>(toughness),
      'loyalty': serializer.toJson<String?>(loyalty),
      'defense': serializer.toJson<String?>(defense),
      'cmc': serializer.toJson<double>(cmc),
      'artist': serializer.toJson<String?>(artist),
      'artistId': serializer.toJson<String?>(artistId),
      'illustrationId': serializer.toJson<String?>(illustrationId),
      'highresImage': serializer.toJson<bool>(highresImage),
      'imageStatus': serializer.toJson<String?>(imageStatus),
      'imageSmall': serializer.toJson<String?>(imageSmall),
      'imageNormal': serializer.toJson<String?>(imageNormal),
      'imageLarge': serializer.toJson<String?>(imageLarge),
      'imagePng': serializer.toJson<String?>(imagePng),
      'imageArtCrop': serializer.toJson<String?>(imageArtCrop),
      'imageBorderCrop': serializer.toJson<String?>(imageBorderCrop),
      'watermark': serializer.toJson<String?>(watermark),
    };
  }

  ScryfallCardFace copyWith({
    String? cardId,
    int? faceIndex,
    String? name,
    Value<String?> printedName = const Value.absent(),
    Value<String?> flavorName = const Value.absent(),
    Value<String?> manaCost = const Value.absent(),
    Value<String?> typeLine = const Value.absent(),
    Value<String?> printedTypeLine = const Value.absent(),
    Value<String?> oracleText = const Value.absent(),
    Value<String?> printedText = const Value.absent(),
    Value<String?> flavorText = const Value.absent(),
    Value<String?> colorsJson = const Value.absent(),
    int? colorMask,
    Value<String?> colorIndicatorJson = const Value.absent(),
    int? colorIndicatorMask,
    Value<String?> power = const Value.absent(),
    Value<String?> toughness = const Value.absent(),
    Value<String?> loyalty = const Value.absent(),
    Value<String?> defense = const Value.absent(),
    double? cmc,
    Value<String?> artist = const Value.absent(),
    Value<String?> artistId = const Value.absent(),
    Value<String?> illustrationId = const Value.absent(),
    bool? highresImage,
    Value<String?> imageStatus = const Value.absent(),
    Value<String?> imageSmall = const Value.absent(),
    Value<String?> imageNormal = const Value.absent(),
    Value<String?> imageLarge = const Value.absent(),
    Value<String?> imagePng = const Value.absent(),
    Value<String?> imageArtCrop = const Value.absent(),
    Value<String?> imageBorderCrop = const Value.absent(),
    Value<String?> watermark = const Value.absent(),
  }) => ScryfallCardFace(
    cardId: cardId ?? this.cardId,
    faceIndex: faceIndex ?? this.faceIndex,
    name: name ?? this.name,
    printedName: printedName.present ? printedName.value : this.printedName,
    flavorName: flavorName.present ? flavorName.value : this.flavorName,
    manaCost: manaCost.present ? manaCost.value : this.manaCost,
    typeLine: typeLine.present ? typeLine.value : this.typeLine,
    printedTypeLine: printedTypeLine.present
        ? printedTypeLine.value
        : this.printedTypeLine,
    oracleText: oracleText.present ? oracleText.value : this.oracleText,
    printedText: printedText.present ? printedText.value : this.printedText,
    flavorText: flavorText.present ? flavorText.value : this.flavorText,
    colorsJson: colorsJson.present ? colorsJson.value : this.colorsJson,
    colorMask: colorMask ?? this.colorMask,
    colorIndicatorJson: colorIndicatorJson.present
        ? colorIndicatorJson.value
        : this.colorIndicatorJson,
    colorIndicatorMask: colorIndicatorMask ?? this.colorIndicatorMask,
    power: power.present ? power.value : this.power,
    toughness: toughness.present ? toughness.value : this.toughness,
    loyalty: loyalty.present ? loyalty.value : this.loyalty,
    defense: defense.present ? defense.value : this.defense,
    cmc: cmc ?? this.cmc,
    artist: artist.present ? artist.value : this.artist,
    artistId: artistId.present ? artistId.value : this.artistId,
    illustrationId: illustrationId.present
        ? illustrationId.value
        : this.illustrationId,
    highresImage: highresImage ?? this.highresImage,
    imageStatus: imageStatus.present ? imageStatus.value : this.imageStatus,
    imageSmall: imageSmall.present ? imageSmall.value : this.imageSmall,
    imageNormal: imageNormal.present ? imageNormal.value : this.imageNormal,
    imageLarge: imageLarge.present ? imageLarge.value : this.imageLarge,
    imagePng: imagePng.present ? imagePng.value : this.imagePng,
    imageArtCrop: imageArtCrop.present ? imageArtCrop.value : this.imageArtCrop,
    imageBorderCrop: imageBorderCrop.present
        ? imageBorderCrop.value
        : this.imageBorderCrop,
    watermark: watermark.present ? watermark.value : this.watermark,
  );
  ScryfallCardFace copyWithCompanion(ScryfallCardFacesCompanion data) {
    return ScryfallCardFace(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      faceIndex: data.faceIndex.present ? data.faceIndex.value : this.faceIndex,
      name: data.name.present ? data.name.value : this.name,
      printedName: data.printedName.present
          ? data.printedName.value
          : this.printedName,
      flavorName: data.flavorName.present
          ? data.flavorName.value
          : this.flavorName,
      manaCost: data.manaCost.present ? data.manaCost.value : this.manaCost,
      typeLine: data.typeLine.present ? data.typeLine.value : this.typeLine,
      printedTypeLine: data.printedTypeLine.present
          ? data.printedTypeLine.value
          : this.printedTypeLine,
      oracleText: data.oracleText.present
          ? data.oracleText.value
          : this.oracleText,
      printedText: data.printedText.present
          ? data.printedText.value
          : this.printedText,
      flavorText: data.flavorText.present
          ? data.flavorText.value
          : this.flavorText,
      colorsJson: data.colorsJson.present
          ? data.colorsJson.value
          : this.colorsJson,
      colorMask: data.colorMask.present ? data.colorMask.value : this.colorMask,
      colorIndicatorJson: data.colorIndicatorJson.present
          ? data.colorIndicatorJson.value
          : this.colorIndicatorJson,
      colorIndicatorMask: data.colorIndicatorMask.present
          ? data.colorIndicatorMask.value
          : this.colorIndicatorMask,
      power: data.power.present ? data.power.value : this.power,
      toughness: data.toughness.present ? data.toughness.value : this.toughness,
      loyalty: data.loyalty.present ? data.loyalty.value : this.loyalty,
      defense: data.defense.present ? data.defense.value : this.defense,
      cmc: data.cmc.present ? data.cmc.value : this.cmc,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      illustrationId: data.illustrationId.present
          ? data.illustrationId.value
          : this.illustrationId,
      highresImage: data.highresImage.present
          ? data.highresImage.value
          : this.highresImage,
      imageStatus: data.imageStatus.present
          ? data.imageStatus.value
          : this.imageStatus,
      imageSmall: data.imageSmall.present
          ? data.imageSmall.value
          : this.imageSmall,
      imageNormal: data.imageNormal.present
          ? data.imageNormal.value
          : this.imageNormal,
      imageLarge: data.imageLarge.present
          ? data.imageLarge.value
          : this.imageLarge,
      imagePng: data.imagePng.present ? data.imagePng.value : this.imagePng,
      imageArtCrop: data.imageArtCrop.present
          ? data.imageArtCrop.value
          : this.imageArtCrop,
      imageBorderCrop: data.imageBorderCrop.present
          ? data.imageBorderCrop.value
          : this.imageBorderCrop,
      watermark: data.watermark.present ? data.watermark.value : this.watermark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScryfallCardFace(')
          ..write('cardId: $cardId, ')
          ..write('faceIndex: $faceIndex, ')
          ..write('name: $name, ')
          ..write('printedName: $printedName, ')
          ..write('flavorName: $flavorName, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('printedTypeLine: $printedTypeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('printedText: $printedText, ')
          ..write('flavorText: $flavorText, ')
          ..write('colorsJson: $colorsJson, ')
          ..write('colorMask: $colorMask, ')
          ..write('colorIndicatorJson: $colorIndicatorJson, ')
          ..write('colorIndicatorMask: $colorIndicatorMask, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('defense: $defense, ')
          ..write('cmc: $cmc, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('illustrationId: $illustrationId, ')
          ..write('highresImage: $highresImage, ')
          ..write('imageStatus: $imageStatus, ')
          ..write('imageSmall: $imageSmall, ')
          ..write('imageNormal: $imageNormal, ')
          ..write('imageLarge: $imageLarge, ')
          ..write('imagePng: $imagePng, ')
          ..write('imageArtCrop: $imageArtCrop, ')
          ..write('imageBorderCrop: $imageBorderCrop, ')
          ..write('watermark: $watermark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    cardId,
    faceIndex,
    name,
    printedName,
    flavorName,
    manaCost,
    typeLine,
    printedTypeLine,
    oracleText,
    printedText,
    flavorText,
    colorsJson,
    colorMask,
    colorIndicatorJson,
    colorIndicatorMask,
    power,
    toughness,
    loyalty,
    defense,
    cmc,
    artist,
    artistId,
    illustrationId,
    highresImage,
    imageStatus,
    imageSmall,
    imageNormal,
    imageLarge,
    imagePng,
    imageArtCrop,
    imageBorderCrop,
    watermark,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScryfallCardFace &&
          other.cardId == this.cardId &&
          other.faceIndex == this.faceIndex &&
          other.name == this.name &&
          other.printedName == this.printedName &&
          other.flavorName == this.flavorName &&
          other.manaCost == this.manaCost &&
          other.typeLine == this.typeLine &&
          other.printedTypeLine == this.printedTypeLine &&
          other.oracleText == this.oracleText &&
          other.printedText == this.printedText &&
          other.flavorText == this.flavorText &&
          other.colorsJson == this.colorsJson &&
          other.colorMask == this.colorMask &&
          other.colorIndicatorJson == this.colorIndicatorJson &&
          other.colorIndicatorMask == this.colorIndicatorMask &&
          other.power == this.power &&
          other.toughness == this.toughness &&
          other.loyalty == this.loyalty &&
          other.defense == this.defense &&
          other.cmc == this.cmc &&
          other.artist == this.artist &&
          other.artistId == this.artistId &&
          other.illustrationId == this.illustrationId &&
          other.highresImage == this.highresImage &&
          other.imageStatus == this.imageStatus &&
          other.imageSmall == this.imageSmall &&
          other.imageNormal == this.imageNormal &&
          other.imageLarge == this.imageLarge &&
          other.imagePng == this.imagePng &&
          other.imageArtCrop == this.imageArtCrop &&
          other.imageBorderCrop == this.imageBorderCrop &&
          other.watermark == this.watermark);
}

class ScryfallCardFacesCompanion extends UpdateCompanion<ScryfallCardFace> {
  final Value<String> cardId;
  final Value<int> faceIndex;
  final Value<String> name;
  final Value<String?> printedName;
  final Value<String?> flavorName;
  final Value<String?> manaCost;
  final Value<String?> typeLine;
  final Value<String?> printedTypeLine;
  final Value<String?> oracleText;
  final Value<String?> printedText;
  final Value<String?> flavorText;
  final Value<String?> colorsJson;
  final Value<int> colorMask;
  final Value<String?> colorIndicatorJson;
  final Value<int> colorIndicatorMask;
  final Value<String?> power;
  final Value<String?> toughness;
  final Value<String?> loyalty;
  final Value<String?> defense;
  final Value<double> cmc;
  final Value<String?> artist;
  final Value<String?> artistId;
  final Value<String?> illustrationId;
  final Value<bool> highresImage;
  final Value<String?> imageStatus;
  final Value<String?> imageSmall;
  final Value<String?> imageNormal;
  final Value<String?> imageLarge;
  final Value<String?> imagePng;
  final Value<String?> imageArtCrop;
  final Value<String?> imageBorderCrop;
  final Value<String?> watermark;
  final Value<int> rowid;
  const ScryfallCardFacesCompanion({
    this.cardId = const Value.absent(),
    this.faceIndex = const Value.absent(),
    this.name = const Value.absent(),
    this.printedName = const Value.absent(),
    this.flavorName = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.printedTypeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.printedText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.colorsJson = const Value.absent(),
    this.colorMask = const Value.absent(),
    this.colorIndicatorJson = const Value.absent(),
    this.colorIndicatorMask = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.defense = const Value.absent(),
    this.cmc = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistId = const Value.absent(),
    this.illustrationId = const Value.absent(),
    this.highresImage = const Value.absent(),
    this.imageStatus = const Value.absent(),
    this.imageSmall = const Value.absent(),
    this.imageNormal = const Value.absent(),
    this.imageLarge = const Value.absent(),
    this.imagePng = const Value.absent(),
    this.imageArtCrop = const Value.absent(),
    this.imageBorderCrop = const Value.absent(),
    this.watermark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScryfallCardFacesCompanion.insert({
    required String cardId,
    required int faceIndex,
    required String name,
    this.printedName = const Value.absent(),
    this.flavorName = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.printedTypeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.printedText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.colorsJson = const Value.absent(),
    this.colorMask = const Value.absent(),
    this.colorIndicatorJson = const Value.absent(),
    this.colorIndicatorMask = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.defense = const Value.absent(),
    required double cmc,
    this.artist = const Value.absent(),
    this.artistId = const Value.absent(),
    this.illustrationId = const Value.absent(),
    this.highresImage = const Value.absent(),
    this.imageStatus = const Value.absent(),
    this.imageSmall = const Value.absent(),
    this.imageNormal = const Value.absent(),
    this.imageLarge = const Value.absent(),
    this.imagePng = const Value.absent(),
    this.imageArtCrop = const Value.absent(),
    this.imageBorderCrop = const Value.absent(),
    this.watermark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       faceIndex = Value(faceIndex),
       name = Value(name),
       cmc = Value(cmc);
  static Insertable<ScryfallCardFace> custom({
    Expression<String>? cardId,
    Expression<int>? faceIndex,
    Expression<String>? name,
    Expression<String>? printedName,
    Expression<String>? flavorName,
    Expression<String>? manaCost,
    Expression<String>? typeLine,
    Expression<String>? printedTypeLine,
    Expression<String>? oracleText,
    Expression<String>? printedText,
    Expression<String>? flavorText,
    Expression<String>? colorsJson,
    Expression<int>? colorMask,
    Expression<String>? colorIndicatorJson,
    Expression<int>? colorIndicatorMask,
    Expression<String>? power,
    Expression<String>? toughness,
    Expression<String>? loyalty,
    Expression<String>? defense,
    Expression<double>? cmc,
    Expression<String>? artist,
    Expression<String>? artistId,
    Expression<String>? illustrationId,
    Expression<bool>? highresImage,
    Expression<String>? imageStatus,
    Expression<String>? imageSmall,
    Expression<String>? imageNormal,
    Expression<String>? imageLarge,
    Expression<String>? imagePng,
    Expression<String>? imageArtCrop,
    Expression<String>? imageBorderCrop,
    Expression<String>? watermark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (faceIndex != null) 'face_index': faceIndex,
      if (name != null) 'name': name,
      if (printedName != null) 'printed_name': printedName,
      if (flavorName != null) 'flavor_name': flavorName,
      if (manaCost != null) 'mana_cost': manaCost,
      if (typeLine != null) 'type_line': typeLine,
      if (printedTypeLine != null) 'printed_type_line': printedTypeLine,
      if (oracleText != null) 'oracle_text': oracleText,
      if (printedText != null) 'printed_text': printedText,
      if (flavorText != null) 'flavor_text': flavorText,
      if (colorsJson != null) 'colors_json': colorsJson,
      if (colorMask != null) 'color_mask': colorMask,
      if (colorIndicatorJson != null)
        'color_indicator_json': colorIndicatorJson,
      if (colorIndicatorMask != null)
        'color_indicator_mask': colorIndicatorMask,
      if (power != null) 'power': power,
      if (toughness != null) 'toughness': toughness,
      if (loyalty != null) 'loyalty': loyalty,
      if (defense != null) 'defense': defense,
      if (cmc != null) 'cmc': cmc,
      if (artist != null) 'artist': artist,
      if (artistId != null) 'artist_id': artistId,
      if (illustrationId != null) 'illustration_id': illustrationId,
      if (highresImage != null) 'highres_image': highresImage,
      if (imageStatus != null) 'image_status': imageStatus,
      if (imageSmall != null) 'image_small': imageSmall,
      if (imageNormal != null) 'image_normal': imageNormal,
      if (imageLarge != null) 'image_large': imageLarge,
      if (imagePng != null) 'image_png': imagePng,
      if (imageArtCrop != null) 'image_art_crop': imageArtCrop,
      if (imageBorderCrop != null) 'image_border_crop': imageBorderCrop,
      if (watermark != null) 'watermark': watermark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScryfallCardFacesCompanion copyWith({
    Value<String>? cardId,
    Value<int>? faceIndex,
    Value<String>? name,
    Value<String?>? printedName,
    Value<String?>? flavorName,
    Value<String?>? manaCost,
    Value<String?>? typeLine,
    Value<String?>? printedTypeLine,
    Value<String?>? oracleText,
    Value<String?>? printedText,
    Value<String?>? flavorText,
    Value<String?>? colorsJson,
    Value<int>? colorMask,
    Value<String?>? colorIndicatorJson,
    Value<int>? colorIndicatorMask,
    Value<String?>? power,
    Value<String?>? toughness,
    Value<String?>? loyalty,
    Value<String?>? defense,
    Value<double>? cmc,
    Value<String?>? artist,
    Value<String?>? artistId,
    Value<String?>? illustrationId,
    Value<bool>? highresImage,
    Value<String?>? imageStatus,
    Value<String?>? imageSmall,
    Value<String?>? imageNormal,
    Value<String?>? imageLarge,
    Value<String?>? imagePng,
    Value<String?>? imageArtCrop,
    Value<String?>? imageBorderCrop,
    Value<String?>? watermark,
    Value<int>? rowid,
  }) {
    return ScryfallCardFacesCompanion(
      cardId: cardId ?? this.cardId,
      faceIndex: faceIndex ?? this.faceIndex,
      name: name ?? this.name,
      printedName: printedName ?? this.printedName,
      flavorName: flavorName ?? this.flavorName,
      manaCost: manaCost ?? this.manaCost,
      typeLine: typeLine ?? this.typeLine,
      printedTypeLine: printedTypeLine ?? this.printedTypeLine,
      oracleText: oracleText ?? this.oracleText,
      printedText: printedText ?? this.printedText,
      flavorText: flavorText ?? this.flavorText,
      colorsJson: colorsJson ?? this.colorsJson,
      colorMask: colorMask ?? this.colorMask,
      colorIndicatorJson: colorIndicatorJson ?? this.colorIndicatorJson,
      colorIndicatorMask: colorIndicatorMask ?? this.colorIndicatorMask,
      power: power ?? this.power,
      toughness: toughness ?? this.toughness,
      loyalty: loyalty ?? this.loyalty,
      defense: defense ?? this.defense,
      cmc: cmc ?? this.cmc,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      illustrationId: illustrationId ?? this.illustrationId,
      highresImage: highresImage ?? this.highresImage,
      imageStatus: imageStatus ?? this.imageStatus,
      imageSmall: imageSmall ?? this.imageSmall,
      imageNormal: imageNormal ?? this.imageNormal,
      imageLarge: imageLarge ?? this.imageLarge,
      imagePng: imagePng ?? this.imagePng,
      imageArtCrop: imageArtCrop ?? this.imageArtCrop,
      imageBorderCrop: imageBorderCrop ?? this.imageBorderCrop,
      watermark: watermark ?? this.watermark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (faceIndex.present) {
      map['face_index'] = Variable<int>(faceIndex.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (printedName.present) {
      map['printed_name'] = Variable<String>(printedName.value);
    }
    if (flavorName.present) {
      map['flavor_name'] = Variable<String>(flavorName.value);
    }
    if (manaCost.present) {
      map['mana_cost'] = Variable<String>(manaCost.value);
    }
    if (typeLine.present) {
      map['type_line'] = Variable<String>(typeLine.value);
    }
    if (printedTypeLine.present) {
      map['printed_type_line'] = Variable<String>(printedTypeLine.value);
    }
    if (oracleText.present) {
      map['oracle_text'] = Variable<String>(oracleText.value);
    }
    if (printedText.present) {
      map['printed_text'] = Variable<String>(printedText.value);
    }
    if (flavorText.present) {
      map['flavor_text'] = Variable<String>(flavorText.value);
    }
    if (colorsJson.present) {
      map['colors_json'] = Variable<String>(colorsJson.value);
    }
    if (colorMask.present) {
      map['color_mask'] = Variable<int>(colorMask.value);
    }
    if (colorIndicatorJson.present) {
      map['color_indicator_json'] = Variable<String>(colorIndicatorJson.value);
    }
    if (colorIndicatorMask.present) {
      map['color_indicator_mask'] = Variable<int>(colorIndicatorMask.value);
    }
    if (power.present) {
      map['power'] = Variable<String>(power.value);
    }
    if (toughness.present) {
      map['toughness'] = Variable<String>(toughness.value);
    }
    if (loyalty.present) {
      map['loyalty'] = Variable<String>(loyalty.value);
    }
    if (defense.present) {
      map['defense'] = Variable<String>(defense.value);
    }
    if (cmc.present) {
      map['cmc'] = Variable<double>(cmc.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (illustrationId.present) {
      map['illustration_id'] = Variable<String>(illustrationId.value);
    }
    if (highresImage.present) {
      map['highres_image'] = Variable<bool>(highresImage.value);
    }
    if (imageStatus.present) {
      map['image_status'] = Variable<String>(imageStatus.value);
    }
    if (imageSmall.present) {
      map['image_small'] = Variable<String>(imageSmall.value);
    }
    if (imageNormal.present) {
      map['image_normal'] = Variable<String>(imageNormal.value);
    }
    if (imageLarge.present) {
      map['image_large'] = Variable<String>(imageLarge.value);
    }
    if (imagePng.present) {
      map['image_png'] = Variable<String>(imagePng.value);
    }
    if (imageArtCrop.present) {
      map['image_art_crop'] = Variable<String>(imageArtCrop.value);
    }
    if (imageBorderCrop.present) {
      map['image_border_crop'] = Variable<String>(imageBorderCrop.value);
    }
    if (watermark.present) {
      map['watermark'] = Variable<String>(watermark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScryfallCardFacesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('faceIndex: $faceIndex, ')
          ..write('name: $name, ')
          ..write('printedName: $printedName, ')
          ..write('flavorName: $flavorName, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('printedTypeLine: $printedTypeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('printedText: $printedText, ')
          ..write('flavorText: $flavorText, ')
          ..write('colorsJson: $colorsJson, ')
          ..write('colorMask: $colorMask, ')
          ..write('colorIndicatorJson: $colorIndicatorJson, ')
          ..write('colorIndicatorMask: $colorIndicatorMask, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('defense: $defense, ')
          ..write('cmc: $cmc, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('illustrationId: $illustrationId, ')
          ..write('highresImage: $highresImage, ')
          ..write('imageStatus: $imageStatus, ')
          ..write('imageSmall: $imageSmall, ')
          ..write('imageNormal: $imageNormal, ')
          ..write('imageLarge: $imageLarge, ')
          ..write('imagePng: $imagePng, ')
          ..write('imageArtCrop: $imageArtCrop, ')
          ..write('imageBorderCrop: $imageBorderCrop, ')
          ..write('watermark: $watermark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScryfallTagsTable extends ScryfallTags
    with TableInfo<$ScryfallTagsTable, ScryfallTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScryfallTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scryfallIdMeta = const VerificationMeta(
    'scryfallId',
  );
  @override
  late final GeneratedColumn<String> scryfallId = GeneratedColumn<String>(
    'scryfall_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  parentIdsJson = GeneratedColumn<String>(
    'parent_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ScryfallTagsTable.$converterparentIdsJson);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  childIdsJson = GeneratedColumn<String>(
    'child_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ScryfallTagsTable.$converterchildIdsJson);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  aliasesJson = GeneratedColumn<String>(
    'aliases_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ScryfallTagsTable.$converteraliasesJson);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> taggedJson =
      GeneratedColumn<String>(
        'tagged_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ScryfallTagsTable.$convertertaggedJson);
  @override
  List<GeneratedColumn> get $columns => [
    scryfallId,
    label,
    slug,
    description,
    type,
    parentIdsJson,
    childIdsJson,
    aliasesJson,
    taggedJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scryfall_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScryfallTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scryfall_id')) {
      context.handle(
        _scryfallIdMeta,
        scryfallId.isAcceptableOrUnknown(data['scryfall_id']!, _scryfallIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scryfallIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scryfallId};
  @override
  ScryfallTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScryfallTag(
      scryfallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scryfall_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentIdsJson: $ScryfallTagsTable.$converterparentIdsJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}parent_ids_json'],
        )!,
      ),
      childIdsJson: $ScryfallTagsTable.$converterchildIdsJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}child_ids_json'],
        )!,
      ),
      aliasesJson: $ScryfallTagsTable.$converteraliasesJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}aliases_json'],
        )!,
      ),
      taggedJson: $ScryfallTagsTable.$convertertaggedJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tagged_json'],
        )!,
      ),
    );
  }

  @override
  $ScryfallTagsTable createAlias(String alias) {
    return $ScryfallTagsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterparentIdsJson =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterchildIdsJson =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converteraliasesJson =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertertaggedJson =
      const StringListConverter();
}

class ScryfallTag extends DataClass implements Insertable<ScryfallTag> {
  final String scryfallId;
  final String label;
  final String slug;
  final String description;
  final String type;
  final List<String> parentIdsJson;
  final List<String> childIdsJson;
  final List<String> aliasesJson;
  final List<String> taggedJson;
  const ScryfallTag({
    required this.scryfallId,
    required this.label,
    required this.slug,
    required this.description,
    required this.type,
    required this.parentIdsJson,
    required this.childIdsJson,
    required this.aliasesJson,
    required this.taggedJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scryfall_id'] = Variable<String>(scryfallId);
    map['label'] = Variable<String>(label);
    map['slug'] = Variable<String>(slug);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    {
      map['parent_ids_json'] = Variable<String>(
        $ScryfallTagsTable.$converterparentIdsJson.toSql(parentIdsJson),
      );
    }
    {
      map['child_ids_json'] = Variable<String>(
        $ScryfallTagsTable.$converterchildIdsJson.toSql(childIdsJson),
      );
    }
    {
      map['aliases_json'] = Variable<String>(
        $ScryfallTagsTable.$converteraliasesJson.toSql(aliasesJson),
      );
    }
    {
      map['tagged_json'] = Variable<String>(
        $ScryfallTagsTable.$convertertaggedJson.toSql(taggedJson),
      );
    }
    return map;
  }

  ScryfallTagsCompanion toCompanion(bool nullToAbsent) {
    return ScryfallTagsCompanion(
      scryfallId: Value(scryfallId),
      label: Value(label),
      slug: Value(slug),
      description: Value(description),
      type: Value(type),
      parentIdsJson: Value(parentIdsJson),
      childIdsJson: Value(childIdsJson),
      aliasesJson: Value(aliasesJson),
      taggedJson: Value(taggedJson),
    );
  }

  factory ScryfallTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScryfallTag(
      scryfallId: serializer.fromJson<String>(json['scryfallId']),
      label: serializer.fromJson<String>(json['label']),
      slug: serializer.fromJson<String>(json['slug']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      parentIdsJson: serializer.fromJson<List<String>>(json['parentIdsJson']),
      childIdsJson: serializer.fromJson<List<String>>(json['childIdsJson']),
      aliasesJson: serializer.fromJson<List<String>>(json['aliasesJson']),
      taggedJson: serializer.fromJson<List<String>>(json['taggedJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scryfallId': serializer.toJson<String>(scryfallId),
      'label': serializer.toJson<String>(label),
      'slug': serializer.toJson<String>(slug),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'parentIdsJson': serializer.toJson<List<String>>(parentIdsJson),
      'childIdsJson': serializer.toJson<List<String>>(childIdsJson),
      'aliasesJson': serializer.toJson<List<String>>(aliasesJson),
      'taggedJson': serializer.toJson<List<String>>(taggedJson),
    };
  }

  ScryfallTag copyWith({
    String? scryfallId,
    String? label,
    String? slug,
    String? description,
    String? type,
    List<String>? parentIdsJson,
    List<String>? childIdsJson,
    List<String>? aliasesJson,
    List<String>? taggedJson,
  }) => ScryfallTag(
    scryfallId: scryfallId ?? this.scryfallId,
    label: label ?? this.label,
    slug: slug ?? this.slug,
    description: description ?? this.description,
    type: type ?? this.type,
    parentIdsJson: parentIdsJson ?? this.parentIdsJson,
    childIdsJson: childIdsJson ?? this.childIdsJson,
    aliasesJson: aliasesJson ?? this.aliasesJson,
    taggedJson: taggedJson ?? this.taggedJson,
  );
  ScryfallTag copyWithCompanion(ScryfallTagsCompanion data) {
    return ScryfallTag(
      scryfallId: data.scryfallId.present
          ? data.scryfallId.value
          : this.scryfallId,
      label: data.label.present ? data.label.value : this.label,
      slug: data.slug.present ? data.slug.value : this.slug,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      parentIdsJson: data.parentIdsJson.present
          ? data.parentIdsJson.value
          : this.parentIdsJson,
      childIdsJson: data.childIdsJson.present
          ? data.childIdsJson.value
          : this.childIdsJson,
      aliasesJson: data.aliasesJson.present
          ? data.aliasesJson.value
          : this.aliasesJson,
      taggedJson: data.taggedJson.present
          ? data.taggedJson.value
          : this.taggedJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScryfallTag(')
          ..write('scryfallId: $scryfallId, ')
          ..write('label: $label, ')
          ..write('slug: $slug, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('parentIdsJson: $parentIdsJson, ')
          ..write('childIdsJson: $childIdsJson, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('taggedJson: $taggedJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    scryfallId,
    label,
    slug,
    description,
    type,
    parentIdsJson,
    childIdsJson,
    aliasesJson,
    taggedJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScryfallTag &&
          other.scryfallId == this.scryfallId &&
          other.label == this.label &&
          other.slug == this.slug &&
          other.description == this.description &&
          other.type == this.type &&
          other.parentIdsJson == this.parentIdsJson &&
          other.childIdsJson == this.childIdsJson &&
          other.aliasesJson == this.aliasesJson &&
          other.taggedJson == this.taggedJson);
}

class ScryfallTagsCompanion extends UpdateCompanion<ScryfallTag> {
  final Value<String> scryfallId;
  final Value<String> label;
  final Value<String> slug;
  final Value<String> description;
  final Value<String> type;
  final Value<List<String>> parentIdsJson;
  final Value<List<String>> childIdsJson;
  final Value<List<String>> aliasesJson;
  final Value<List<String>> taggedJson;
  final Value<int> rowid;
  const ScryfallTagsCompanion({
    this.scryfallId = const Value.absent(),
    this.label = const Value.absent(),
    this.slug = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.parentIdsJson = const Value.absent(),
    this.childIdsJson = const Value.absent(),
    this.aliasesJson = const Value.absent(),
    this.taggedJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScryfallTagsCompanion.insert({
    required String scryfallId,
    required String label,
    required String slug,
    required String description,
    required String type,
    required List<String> parentIdsJson,
    required List<String> childIdsJson,
    required List<String> aliasesJson,
    required List<String> taggedJson,
    this.rowid = const Value.absent(),
  }) : scryfallId = Value(scryfallId),
       label = Value(label),
       slug = Value(slug),
       description = Value(description),
       type = Value(type),
       parentIdsJson = Value(parentIdsJson),
       childIdsJson = Value(childIdsJson),
       aliasesJson = Value(aliasesJson),
       taggedJson = Value(taggedJson);
  static Insertable<ScryfallTag> custom({
    Expression<String>? scryfallId,
    Expression<String>? label,
    Expression<String>? slug,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? parentIdsJson,
    Expression<String>? childIdsJson,
    Expression<String>? aliasesJson,
    Expression<String>? taggedJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scryfallId != null) 'scryfall_id': scryfallId,
      if (label != null) 'label': label,
      if (slug != null) 'slug': slug,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (parentIdsJson != null) 'parent_ids_json': parentIdsJson,
      if (childIdsJson != null) 'child_ids_json': childIdsJson,
      if (aliasesJson != null) 'aliases_json': aliasesJson,
      if (taggedJson != null) 'tagged_json': taggedJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScryfallTagsCompanion copyWith({
    Value<String>? scryfallId,
    Value<String>? label,
    Value<String>? slug,
    Value<String>? description,
    Value<String>? type,
    Value<List<String>>? parentIdsJson,
    Value<List<String>>? childIdsJson,
    Value<List<String>>? aliasesJson,
    Value<List<String>>? taggedJson,
    Value<int>? rowid,
  }) {
    return ScryfallTagsCompanion(
      scryfallId: scryfallId ?? this.scryfallId,
      label: label ?? this.label,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      type: type ?? this.type,
      parentIdsJson: parentIdsJson ?? this.parentIdsJson,
      childIdsJson: childIdsJson ?? this.childIdsJson,
      aliasesJson: aliasesJson ?? this.aliasesJson,
      taggedJson: taggedJson ?? this.taggedJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scryfallId.present) {
      map['scryfall_id'] = Variable<String>(scryfallId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentIdsJson.present) {
      map['parent_ids_json'] = Variable<String>(
        $ScryfallTagsTable.$converterparentIdsJson.toSql(parentIdsJson.value),
      );
    }
    if (childIdsJson.present) {
      map['child_ids_json'] = Variable<String>(
        $ScryfallTagsTable.$converterchildIdsJson.toSql(childIdsJson.value),
      );
    }
    if (aliasesJson.present) {
      map['aliases_json'] = Variable<String>(
        $ScryfallTagsTable.$converteraliasesJson.toSql(aliasesJson.value),
      );
    }
    if (taggedJson.present) {
      map['tagged_json'] = Variable<String>(
        $ScryfallTagsTable.$convertertaggedJson.toSql(taggedJson.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScryfallTagsCompanion(')
          ..write('scryfallId: $scryfallId, ')
          ..write('label: $label, ')
          ..write('slug: $slug, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('parentIdsJson: $parentIdsJson, ')
          ..write('childIdsJson: $childIdsJson, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('taggedJson: $taggedJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScryfallCardsTable scryfallCards = $ScryfallCardsTable(this);
  late final $ScryfallCardFacesTable scryfallCardFaces =
      $ScryfallCardFacesTable(this);
  late final $ScryfallTagsTable scryfallTags = $ScryfallTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scryfallCards,
    scryfallCardFaces,
    scryfallTags,
  ];
}

typedef $$ScryfallCardsTableCreateCompanionBuilder =
    ScryfallCardsCompanion Function({
      required String scryfallId,
      Value<String?> oracleId,
      Value<String?> tcgplayerId,
      Value<String?> cardmarketId,
      Value<String?> multiverseIdsJson,
      required String layout,
      required String name,
      Value<String?> printedName,
      Value<String?> flavorName,
      required String setId,
      required String setCode,
      required String setName,
      required String setType,
      required String setUri,
      required String setSearchUri,
      required String scryfallSetUri,
      required String collectorNumber,
      required String lang,
      required String rarity,
      Value<int> rarityValue,
      required String releasedAt,
      required String scryfallUri,
      required String uri,
      required String rulingsUri,
      required String printsSearchUri,
      Value<String?> manaCost,
      required String typeLine,
      Value<String?> printedTypeLine,
      Value<String?> oracleText,
      Value<String?> printedText,
      Value<String?> flavorText,
      Value<String?> colorsJson,
      Value<int> colorMask,
      Value<String?> colorIdentityJson,
      Value<int> colorIdentityMask,
      Value<String?> producedManaJson,
      Value<int> producedManaMask,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> defense,
      required double cmc,
      Value<String?> keywordsJson,
      Value<bool> hasCardFaces,
      Value<bool> hasColorIndicator,
      Value<String?> borderColor,
      Value<String?> frame,
      Value<String?> frameEffectsJson,
      Value<String?> securityStamp,
      Value<bool> highresImage,
      Value<String?> imageStatus,
      Value<String?> imageUpdatedAt,
      Value<String?> imageSmall,
      Value<String?> imageNormal,
      Value<String?> imageLarge,
      Value<String?> imagePng,
      Value<String?> imageArtCrop,
      Value<String?> imageBorderCrop,
      Value<String?> artist,
      Value<String?> artistIdsJson,
      Value<String?> illustrationId,
      Value<String?> watermark,
      Value<bool> fullArt,
      Value<bool> textless,
      Value<bool> booster,
      Value<bool> storySpotlight,
      Value<bool> promo,
      Value<bool> reprint,
      Value<bool> variation,
      Value<bool> reserved,
      Value<bool> gameChanger,
      Value<bool> oversized,
      Value<bool> nonfoil,
      Value<bool> foil,
      Value<bool> etched,
      Value<bool> glossy,
      Value<bool> paper,
      Value<String?> legalStandard,
      Value<String?> legalFuture,
      Value<String?> legalHistoric,
      Value<String?> legalTimeless,
      Value<String?> legalGladiator,
      Value<String?> legalPioneer,
      Value<String?> legalModern,
      Value<String?> legalLegacy,
      Value<String?> legalPauper,
      Value<String?> legalVintage,
      Value<String?> legalPenny,
      Value<String?> legalCommander,
      Value<String?> legalOathbreaker,
      Value<String?> legalStandardBrawl,
      Value<String?> legalBrawl,
      Value<String?> legalCompetitiveBrawl,
      Value<String?> legalAlchemy,
      Value<String?> legalPauperCommander,
      Value<String?> legalDuel,
      Value<String?> legalOldSchool,
      Value<String?> legalPremodern,
      Value<String?> legalPredh,
      Value<String?> legalTlr,
      Value<String?> pricesUsd,
      Value<String?> pricesUsdFoil,
      Value<String?> pricesUsdEtched,
      Value<String?> pricesEur,
      Value<String?> pricesEurFoil,
      Value<String?> pricesTix,
      Value<String?> relatedGathererUri,
      Value<String?> relatedTcgplayerInfiniteArticlesUri,
      Value<String?> relatedTcgplayerInfiniteDecksUri,
      Value<String?> relatedEdhrecUri,
      Value<String?> purchaseTcgplayerUri,
      Value<String?> purchaseCardmarketUri,
      Value<String?> purchaseCardhoarderUri,
      Value<String?> cardBackId,
      Value<String?> allPartsJson,
      Value<int> rowid,
    });
typedef $$ScryfallCardsTableUpdateCompanionBuilder =
    ScryfallCardsCompanion Function({
      Value<String> scryfallId,
      Value<String?> oracleId,
      Value<String?> tcgplayerId,
      Value<String?> cardmarketId,
      Value<String?> multiverseIdsJson,
      Value<String> layout,
      Value<String> name,
      Value<String?> printedName,
      Value<String?> flavorName,
      Value<String> setId,
      Value<String> setCode,
      Value<String> setName,
      Value<String> setType,
      Value<String> setUri,
      Value<String> setSearchUri,
      Value<String> scryfallSetUri,
      Value<String> collectorNumber,
      Value<String> lang,
      Value<String> rarity,
      Value<int> rarityValue,
      Value<String> releasedAt,
      Value<String> scryfallUri,
      Value<String> uri,
      Value<String> rulingsUri,
      Value<String> printsSearchUri,
      Value<String?> manaCost,
      Value<String> typeLine,
      Value<String?> printedTypeLine,
      Value<String?> oracleText,
      Value<String?> printedText,
      Value<String?> flavorText,
      Value<String?> colorsJson,
      Value<int> colorMask,
      Value<String?> colorIdentityJson,
      Value<int> colorIdentityMask,
      Value<String?> producedManaJson,
      Value<int> producedManaMask,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> defense,
      Value<double> cmc,
      Value<String?> keywordsJson,
      Value<bool> hasCardFaces,
      Value<bool> hasColorIndicator,
      Value<String?> borderColor,
      Value<String?> frame,
      Value<String?> frameEffectsJson,
      Value<String?> securityStamp,
      Value<bool> highresImage,
      Value<String?> imageStatus,
      Value<String?> imageUpdatedAt,
      Value<String?> imageSmall,
      Value<String?> imageNormal,
      Value<String?> imageLarge,
      Value<String?> imagePng,
      Value<String?> imageArtCrop,
      Value<String?> imageBorderCrop,
      Value<String?> artist,
      Value<String?> artistIdsJson,
      Value<String?> illustrationId,
      Value<String?> watermark,
      Value<bool> fullArt,
      Value<bool> textless,
      Value<bool> booster,
      Value<bool> storySpotlight,
      Value<bool> promo,
      Value<bool> reprint,
      Value<bool> variation,
      Value<bool> reserved,
      Value<bool> gameChanger,
      Value<bool> oversized,
      Value<bool> nonfoil,
      Value<bool> foil,
      Value<bool> etched,
      Value<bool> glossy,
      Value<bool> paper,
      Value<String?> legalStandard,
      Value<String?> legalFuture,
      Value<String?> legalHistoric,
      Value<String?> legalTimeless,
      Value<String?> legalGladiator,
      Value<String?> legalPioneer,
      Value<String?> legalModern,
      Value<String?> legalLegacy,
      Value<String?> legalPauper,
      Value<String?> legalVintage,
      Value<String?> legalPenny,
      Value<String?> legalCommander,
      Value<String?> legalOathbreaker,
      Value<String?> legalStandardBrawl,
      Value<String?> legalBrawl,
      Value<String?> legalCompetitiveBrawl,
      Value<String?> legalAlchemy,
      Value<String?> legalPauperCommander,
      Value<String?> legalDuel,
      Value<String?> legalOldSchool,
      Value<String?> legalPremodern,
      Value<String?> legalPredh,
      Value<String?> legalTlr,
      Value<String?> pricesUsd,
      Value<String?> pricesUsdFoil,
      Value<String?> pricesUsdEtched,
      Value<String?> pricesEur,
      Value<String?> pricesEurFoil,
      Value<String?> pricesTix,
      Value<String?> relatedGathererUri,
      Value<String?> relatedTcgplayerInfiniteArticlesUri,
      Value<String?> relatedTcgplayerInfiniteDecksUri,
      Value<String?> relatedEdhrecUri,
      Value<String?> purchaseTcgplayerUri,
      Value<String?> purchaseCardmarketUri,
      Value<String?> purchaseCardhoarderUri,
      Value<String?> cardBackId,
      Value<String?> allPartsJson,
      Value<int> rowid,
    });

final class $$ScryfallCardsTableReferences
    extends BaseReferences<_$AppDatabase, $ScryfallCardsTable, ScryfallCard> {
  $$ScryfallCardsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ScryfallCardFacesTable, List<ScryfallCardFace>>
  _scryfallCardFacesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scryfallCardFaces,
        aliasName: 'scryfall_cards__scryfall_id__scryfall_card_faces__card_id',
      );

  $$ScryfallCardFacesTableProcessedTableManager get scryfallCardFacesRefs {
    final manager =
        $$ScryfallCardFacesTableTableManager(
          $_db,
          $_db.scryfallCardFaces,
        ).filter(
          (f) => f.cardId.scryfallId.sqlEquals(
            $_itemColumn<String>('scryfall_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _scryfallCardFacesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScryfallCardsTableFilterComposer
    extends Composer<_$AppDatabase, $ScryfallCardsTable> {
  $$ScryfallCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oracleId => $composableBuilder(
    column: $table.oracleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tcgplayerId => $composableBuilder(
    column: $table.tcgplayerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardmarketId => $composableBuilder(
    column: $table.cardmarketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get multiverseIdsJson => $composableBuilder(
    column: $table.multiverseIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printedName => $composableBuilder(
    column: $table.printedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setUri => $composableBuilder(
    column: $table.setUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setSearchUri => $composableBuilder(
    column: $table.setSearchUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scryfallSetUri => $composableBuilder(
    column: $table.scryfallSetUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rarityValue => $composableBuilder(
    column: $table.rarityValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scryfallUri => $composableBuilder(
    column: $table.scryfallUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulingsUri => $composableBuilder(
    column: $table.rulingsUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printsSearchUri => $composableBuilder(
    column: $table.printsSearchUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printedTypeLine => $composableBuilder(
    column: $table.printedTypeLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printedText => $composableBuilder(
    column: $table.printedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorsJson => $composableBuilder(
    column: $table.colorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorMask => $composableBuilder(
    column: $table.colorMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorIdentityJson => $composableBuilder(
    column: $table.colorIdentityJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorIdentityMask => $composableBuilder(
    column: $table.colorIdentityMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producedManaJson => $composableBuilder(
    column: $table.producedManaJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get producedManaMask => $composableBuilder(
    column: $table.producedManaMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cmc => $composableBuilder(
    column: $table.cmc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywordsJson => $composableBuilder(
    column: $table.keywordsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasCardFaces => $composableBuilder(
    column: $table.hasCardFaces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasColorIndicator => $composableBuilder(
    column: $table.hasColorIndicator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borderColor => $composableBuilder(
    column: $table.borderColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frameEffectsJson => $composableBuilder(
    column: $table.frameEffectsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get securityStamp => $composableBuilder(
    column: $table.securityStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get highresImage => $composableBuilder(
    column: $table.highresImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageStatus => $composableBuilder(
    column: $table.imageStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUpdatedAt => $composableBuilder(
    column: $table.imageUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageSmall => $composableBuilder(
    column: $table.imageSmall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageNormal => $composableBuilder(
    column: $table.imageNormal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageLarge => $composableBuilder(
    column: $table.imageLarge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePng => $composableBuilder(
    column: $table.imagePng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageArtCrop => $composableBuilder(
    column: $table.imageArtCrop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageBorderCrop => $composableBuilder(
    column: $table.imageBorderCrop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistIdsJson => $composableBuilder(
    column: $table.artistIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get illustrationId => $composableBuilder(
    column: $table.illustrationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fullArt => $composableBuilder(
    column: $table.fullArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get textless => $composableBuilder(
    column: $table.textless,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get booster => $composableBuilder(
    column: $table.booster,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get storySpotlight => $composableBuilder(
    column: $table.storySpotlight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get promo => $composableBuilder(
    column: $table.promo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reprint => $composableBuilder(
    column: $table.reprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get variation => $composableBuilder(
    column: $table.variation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reserved => $composableBuilder(
    column: $table.reserved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gameChanger => $composableBuilder(
    column: $table.gameChanger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get oversized => $composableBuilder(
    column: $table.oversized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nonfoil => $composableBuilder(
    column: $table.nonfoil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get etched => $composableBuilder(
    column: $table.etched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get glossy => $composableBuilder(
    column: $table.glossy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paper => $composableBuilder(
    column: $table.paper,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalStandard => $composableBuilder(
    column: $table.legalStandard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalFuture => $composableBuilder(
    column: $table.legalFuture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalHistoric => $composableBuilder(
    column: $table.legalHistoric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalTimeless => $composableBuilder(
    column: $table.legalTimeless,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalGladiator => $composableBuilder(
    column: $table.legalGladiator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalPioneer => $composableBuilder(
    column: $table.legalPioneer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalModern => $composableBuilder(
    column: $table.legalModern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalLegacy => $composableBuilder(
    column: $table.legalLegacy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalPauper => $composableBuilder(
    column: $table.legalPauper,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalVintage => $composableBuilder(
    column: $table.legalVintage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalPenny => $composableBuilder(
    column: $table.legalPenny,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalCommander => $composableBuilder(
    column: $table.legalCommander,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalOathbreaker => $composableBuilder(
    column: $table.legalOathbreaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalStandardBrawl => $composableBuilder(
    column: $table.legalStandardBrawl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalBrawl => $composableBuilder(
    column: $table.legalBrawl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalCompetitiveBrawl => $composableBuilder(
    column: $table.legalCompetitiveBrawl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalAlchemy => $composableBuilder(
    column: $table.legalAlchemy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalPauperCommander => $composableBuilder(
    column: $table.legalPauperCommander,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalDuel => $composableBuilder(
    column: $table.legalDuel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalOldSchool => $composableBuilder(
    column: $table.legalOldSchool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalPremodern => $composableBuilder(
    column: $table.legalPremodern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalPredh => $composableBuilder(
    column: $table.legalPredh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalTlr => $composableBuilder(
    column: $table.legalTlr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricesUsd => $composableBuilder(
    column: $table.pricesUsd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricesUsdFoil => $composableBuilder(
    column: $table.pricesUsdFoil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricesUsdEtched => $composableBuilder(
    column: $table.pricesUsdEtched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricesEur => $composableBuilder(
    column: $table.pricesEur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricesEurFoil => $composableBuilder(
    column: $table.pricesEurFoil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricesTix => $composableBuilder(
    column: $table.pricesTix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedGathererUri => $composableBuilder(
    column: $table.relatedGathererUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedTcgplayerInfiniteArticlesUri =>
      $composableBuilder(
        column: $table.relatedTcgplayerInfiniteArticlesUri,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get relatedTcgplayerInfiniteDecksUri =>
      $composableBuilder(
        column: $table.relatedTcgplayerInfiniteDecksUri,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get relatedEdhrecUri => $composableBuilder(
    column: $table.relatedEdhrecUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseTcgplayerUri => $composableBuilder(
    column: $table.purchaseTcgplayerUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseCardmarketUri => $composableBuilder(
    column: $table.purchaseCardmarketUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseCardhoarderUri => $composableBuilder(
    column: $table.purchaseCardhoarderUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardBackId => $composableBuilder(
    column: $table.cardBackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allPartsJson => $composableBuilder(
    column: $table.allPartsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scryfallCardFacesRefs(
    Expression<bool> Function($$ScryfallCardFacesTableFilterComposer f) f,
  ) {
    final $$ScryfallCardFacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scryfallId,
      referencedTable: $db.scryfallCardFaces,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScryfallCardFacesTableFilterComposer(
            $db: $db,
            $table: $db.scryfallCardFaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScryfallCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScryfallCardsTable> {
  $$ScryfallCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oracleId => $composableBuilder(
    column: $table.oracleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tcgplayerId => $composableBuilder(
    column: $table.tcgplayerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardmarketId => $composableBuilder(
    column: $table.cardmarketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get multiverseIdsJson => $composableBuilder(
    column: $table.multiverseIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printedName => $composableBuilder(
    column: $table.printedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setUri => $composableBuilder(
    column: $table.setUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setSearchUri => $composableBuilder(
    column: $table.setSearchUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scryfallSetUri => $composableBuilder(
    column: $table.scryfallSetUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rarityValue => $composableBuilder(
    column: $table.rarityValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scryfallUri => $composableBuilder(
    column: $table.scryfallUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulingsUri => $composableBuilder(
    column: $table.rulingsUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printsSearchUri => $composableBuilder(
    column: $table.printsSearchUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printedTypeLine => $composableBuilder(
    column: $table.printedTypeLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printedText => $composableBuilder(
    column: $table.printedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorsJson => $composableBuilder(
    column: $table.colorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorMask => $composableBuilder(
    column: $table.colorMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorIdentityJson => $composableBuilder(
    column: $table.colorIdentityJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorIdentityMask => $composableBuilder(
    column: $table.colorIdentityMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producedManaJson => $composableBuilder(
    column: $table.producedManaJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get producedManaMask => $composableBuilder(
    column: $table.producedManaMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cmc => $composableBuilder(
    column: $table.cmc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywordsJson => $composableBuilder(
    column: $table.keywordsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasCardFaces => $composableBuilder(
    column: $table.hasCardFaces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasColorIndicator => $composableBuilder(
    column: $table.hasColorIndicator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borderColor => $composableBuilder(
    column: $table.borderColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frameEffectsJson => $composableBuilder(
    column: $table.frameEffectsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get securityStamp => $composableBuilder(
    column: $table.securityStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get highresImage => $composableBuilder(
    column: $table.highresImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageStatus => $composableBuilder(
    column: $table.imageStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUpdatedAt => $composableBuilder(
    column: $table.imageUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageSmall => $composableBuilder(
    column: $table.imageSmall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageNormal => $composableBuilder(
    column: $table.imageNormal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageLarge => $composableBuilder(
    column: $table.imageLarge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePng => $composableBuilder(
    column: $table.imagePng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageArtCrop => $composableBuilder(
    column: $table.imageArtCrop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageBorderCrop => $composableBuilder(
    column: $table.imageBorderCrop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistIdsJson => $composableBuilder(
    column: $table.artistIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get illustrationId => $composableBuilder(
    column: $table.illustrationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fullArt => $composableBuilder(
    column: $table.fullArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get textless => $composableBuilder(
    column: $table.textless,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get booster => $composableBuilder(
    column: $table.booster,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get storySpotlight => $composableBuilder(
    column: $table.storySpotlight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get promo => $composableBuilder(
    column: $table.promo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reprint => $composableBuilder(
    column: $table.reprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get variation => $composableBuilder(
    column: $table.variation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reserved => $composableBuilder(
    column: $table.reserved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gameChanger => $composableBuilder(
    column: $table.gameChanger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get oversized => $composableBuilder(
    column: $table.oversized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nonfoil => $composableBuilder(
    column: $table.nonfoil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get etched => $composableBuilder(
    column: $table.etched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get glossy => $composableBuilder(
    column: $table.glossy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paper => $composableBuilder(
    column: $table.paper,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalStandard => $composableBuilder(
    column: $table.legalStandard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalFuture => $composableBuilder(
    column: $table.legalFuture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalHistoric => $composableBuilder(
    column: $table.legalHistoric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalTimeless => $composableBuilder(
    column: $table.legalTimeless,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalGladiator => $composableBuilder(
    column: $table.legalGladiator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalPioneer => $composableBuilder(
    column: $table.legalPioneer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalModern => $composableBuilder(
    column: $table.legalModern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalLegacy => $composableBuilder(
    column: $table.legalLegacy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalPauper => $composableBuilder(
    column: $table.legalPauper,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalVintage => $composableBuilder(
    column: $table.legalVintage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalPenny => $composableBuilder(
    column: $table.legalPenny,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalCommander => $composableBuilder(
    column: $table.legalCommander,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalOathbreaker => $composableBuilder(
    column: $table.legalOathbreaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalStandardBrawl => $composableBuilder(
    column: $table.legalStandardBrawl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalBrawl => $composableBuilder(
    column: $table.legalBrawl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalCompetitiveBrawl => $composableBuilder(
    column: $table.legalCompetitiveBrawl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalAlchemy => $composableBuilder(
    column: $table.legalAlchemy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalPauperCommander => $composableBuilder(
    column: $table.legalPauperCommander,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalDuel => $composableBuilder(
    column: $table.legalDuel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalOldSchool => $composableBuilder(
    column: $table.legalOldSchool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalPremodern => $composableBuilder(
    column: $table.legalPremodern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalPredh => $composableBuilder(
    column: $table.legalPredh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalTlr => $composableBuilder(
    column: $table.legalTlr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricesUsd => $composableBuilder(
    column: $table.pricesUsd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricesUsdFoil => $composableBuilder(
    column: $table.pricesUsdFoil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricesUsdEtched => $composableBuilder(
    column: $table.pricesUsdEtched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricesEur => $composableBuilder(
    column: $table.pricesEur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricesEurFoil => $composableBuilder(
    column: $table.pricesEurFoil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricesTix => $composableBuilder(
    column: $table.pricesTix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedGathererUri => $composableBuilder(
    column: $table.relatedGathererUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedTcgplayerInfiniteArticlesUri =>
      $composableBuilder(
        column: $table.relatedTcgplayerInfiniteArticlesUri,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get relatedTcgplayerInfiniteDecksUri =>
      $composableBuilder(
        column: $table.relatedTcgplayerInfiniteDecksUri,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get relatedEdhrecUri => $composableBuilder(
    column: $table.relatedEdhrecUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseTcgplayerUri => $composableBuilder(
    column: $table.purchaseTcgplayerUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseCardmarketUri => $composableBuilder(
    column: $table.purchaseCardmarketUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseCardhoarderUri => $composableBuilder(
    column: $table.purchaseCardhoarderUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardBackId => $composableBuilder(
    column: $table.cardBackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allPartsJson => $composableBuilder(
    column: $table.allPartsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScryfallCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScryfallCardsTable> {
  $$ScryfallCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oracleId =>
      $composableBuilder(column: $table.oracleId, builder: (column) => column);

  GeneratedColumn<String> get tcgplayerId => $composableBuilder(
    column: $table.tcgplayerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardmarketId => $composableBuilder(
    column: $table.cardmarketId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get multiverseIdsJson => $composableBuilder(
    column: $table.multiverseIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get layout =>
      $composableBuilder(column: $table.layout, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get printedName => $composableBuilder(
    column: $table.printedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get setType =>
      $composableBuilder(column: $table.setType, builder: (column) => column);

  GeneratedColumn<String> get setUri =>
      $composableBuilder(column: $table.setUri, builder: (column) => column);

  GeneratedColumn<String> get setSearchUri => $composableBuilder(
    column: $table.setSearchUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scryfallSetUri => $composableBuilder(
    column: $table.scryfallSetUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<int> get rarityValue => $composableBuilder(
    column: $table.rarityValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scryfallUri => $composableBuilder(
    column: $table.scryfallUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get rulingsUri => $composableBuilder(
    column: $table.rulingsUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printsSearchUri => $composableBuilder(
    column: $table.printsSearchUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manaCost =>
      $composableBuilder(column: $table.manaCost, builder: (column) => column);

  GeneratedColumn<String> get typeLine =>
      $composableBuilder(column: $table.typeLine, builder: (column) => column);

  GeneratedColumn<String> get printedTypeLine => $composableBuilder(
    column: $table.printedTypeLine,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printedText => $composableBuilder(
    column: $table.printedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorsJson => $composableBuilder(
    column: $table.colorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorMask =>
      $composableBuilder(column: $table.colorMask, builder: (column) => column);

  GeneratedColumn<String> get colorIdentityJson => $composableBuilder(
    column: $table.colorIdentityJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorIdentityMask => $composableBuilder(
    column: $table.colorIdentityMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producedManaJson => $composableBuilder(
    column: $table.producedManaJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get producedManaMask => $composableBuilder(
    column: $table.producedManaMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<String> get toughness =>
      $composableBuilder(column: $table.toughness, builder: (column) => column);

  GeneratedColumn<String> get loyalty =>
      $composableBuilder(column: $table.loyalty, builder: (column) => column);

  GeneratedColumn<String> get defense =>
      $composableBuilder(column: $table.defense, builder: (column) => column);

  GeneratedColumn<double> get cmc =>
      $composableBuilder(column: $table.cmc, builder: (column) => column);

  GeneratedColumn<String> get keywordsJson => $composableBuilder(
    column: $table.keywordsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasCardFaces => $composableBuilder(
    column: $table.hasCardFaces,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasColorIndicator => $composableBuilder(
    column: $table.hasColorIndicator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get borderColor => $composableBuilder(
    column: $table.borderColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frame =>
      $composableBuilder(column: $table.frame, builder: (column) => column);

  GeneratedColumn<String> get frameEffectsJson => $composableBuilder(
    column: $table.frameEffectsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get securityStamp => $composableBuilder(
    column: $table.securityStamp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get highresImage => $composableBuilder(
    column: $table.highresImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageStatus => $composableBuilder(
    column: $table.imageStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUpdatedAt => $composableBuilder(
    column: $table.imageUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageSmall => $composableBuilder(
    column: $table.imageSmall,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageNormal => $composableBuilder(
    column: $table.imageNormal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageLarge => $composableBuilder(
    column: $table.imageLarge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePng =>
      $composableBuilder(column: $table.imagePng, builder: (column) => column);

  GeneratedColumn<String> get imageArtCrop => $composableBuilder(
    column: $table.imageArtCrop,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageBorderCrop => $composableBuilder(
    column: $table.imageBorderCrop,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistIdsJson => $composableBuilder(
    column: $table.artistIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get illustrationId => $composableBuilder(
    column: $table.illustrationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get watermark =>
      $composableBuilder(column: $table.watermark, builder: (column) => column);

  GeneratedColumn<bool> get fullArt =>
      $composableBuilder(column: $table.fullArt, builder: (column) => column);

  GeneratedColumn<bool> get textless =>
      $composableBuilder(column: $table.textless, builder: (column) => column);

  GeneratedColumn<bool> get booster =>
      $composableBuilder(column: $table.booster, builder: (column) => column);

  GeneratedColumn<bool> get storySpotlight => $composableBuilder(
    column: $table.storySpotlight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get promo =>
      $composableBuilder(column: $table.promo, builder: (column) => column);

  GeneratedColumn<bool> get reprint =>
      $composableBuilder(column: $table.reprint, builder: (column) => column);

  GeneratedColumn<bool> get variation =>
      $composableBuilder(column: $table.variation, builder: (column) => column);

  GeneratedColumn<bool> get reserved =>
      $composableBuilder(column: $table.reserved, builder: (column) => column);

  GeneratedColumn<bool> get gameChanger => $composableBuilder(
    column: $table.gameChanger,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get oversized =>
      $composableBuilder(column: $table.oversized, builder: (column) => column);

  GeneratedColumn<bool> get nonfoil =>
      $composableBuilder(column: $table.nonfoil, builder: (column) => column);

  GeneratedColumn<bool> get foil =>
      $composableBuilder(column: $table.foil, builder: (column) => column);

  GeneratedColumn<bool> get etched =>
      $composableBuilder(column: $table.etched, builder: (column) => column);

  GeneratedColumn<bool> get glossy =>
      $composableBuilder(column: $table.glossy, builder: (column) => column);

  GeneratedColumn<bool> get paper =>
      $composableBuilder(column: $table.paper, builder: (column) => column);

  GeneratedColumn<String> get legalStandard => $composableBuilder(
    column: $table.legalStandard,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalFuture => $composableBuilder(
    column: $table.legalFuture,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalHistoric => $composableBuilder(
    column: $table.legalHistoric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalTimeless => $composableBuilder(
    column: $table.legalTimeless,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalGladiator => $composableBuilder(
    column: $table.legalGladiator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalPioneer => $composableBuilder(
    column: $table.legalPioneer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalModern => $composableBuilder(
    column: $table.legalModern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalLegacy => $composableBuilder(
    column: $table.legalLegacy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalPauper => $composableBuilder(
    column: $table.legalPauper,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalVintage => $composableBuilder(
    column: $table.legalVintage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalPenny => $composableBuilder(
    column: $table.legalPenny,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalCommander => $composableBuilder(
    column: $table.legalCommander,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalOathbreaker => $composableBuilder(
    column: $table.legalOathbreaker,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalStandardBrawl => $composableBuilder(
    column: $table.legalStandardBrawl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalBrawl => $composableBuilder(
    column: $table.legalBrawl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalCompetitiveBrawl => $composableBuilder(
    column: $table.legalCompetitiveBrawl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalAlchemy => $composableBuilder(
    column: $table.legalAlchemy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalPauperCommander => $composableBuilder(
    column: $table.legalPauperCommander,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalDuel =>
      $composableBuilder(column: $table.legalDuel, builder: (column) => column);

  GeneratedColumn<String> get legalOldSchool => $composableBuilder(
    column: $table.legalOldSchool,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalPremodern => $composableBuilder(
    column: $table.legalPremodern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalPredh => $composableBuilder(
    column: $table.legalPredh,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalTlr =>
      $composableBuilder(column: $table.legalTlr, builder: (column) => column);

  GeneratedColumn<String> get pricesUsd =>
      $composableBuilder(column: $table.pricesUsd, builder: (column) => column);

  GeneratedColumn<String> get pricesUsdFoil => $composableBuilder(
    column: $table.pricesUsdFoil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pricesUsdEtched => $composableBuilder(
    column: $table.pricesUsdEtched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pricesEur =>
      $composableBuilder(column: $table.pricesEur, builder: (column) => column);

  GeneratedColumn<String> get pricesEurFoil => $composableBuilder(
    column: $table.pricesEurFoil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pricesTix =>
      $composableBuilder(column: $table.pricesTix, builder: (column) => column);

  GeneratedColumn<String> get relatedGathererUri => $composableBuilder(
    column: $table.relatedGathererUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedTcgplayerInfiniteArticlesUri =>
      $composableBuilder(
        column: $table.relatedTcgplayerInfiniteArticlesUri,
        builder: (column) => column,
      );

  GeneratedColumn<String> get relatedTcgplayerInfiniteDecksUri =>
      $composableBuilder(
        column: $table.relatedTcgplayerInfiniteDecksUri,
        builder: (column) => column,
      );

  GeneratedColumn<String> get relatedEdhrecUri => $composableBuilder(
    column: $table.relatedEdhrecUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseTcgplayerUri => $composableBuilder(
    column: $table.purchaseTcgplayerUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseCardmarketUri => $composableBuilder(
    column: $table.purchaseCardmarketUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseCardhoarderUri => $composableBuilder(
    column: $table.purchaseCardhoarderUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardBackId => $composableBuilder(
    column: $table.cardBackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allPartsJson => $composableBuilder(
    column: $table.allPartsJson,
    builder: (column) => column,
  );

  Expression<T> scryfallCardFacesRefs<T extends Object>(
    Expression<T> Function($$ScryfallCardFacesTableAnnotationComposer a) f,
  ) {
    final $$ScryfallCardFacesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scryfallId,
          referencedTable: $db.scryfallCardFaces,
          getReferencedColumn: (t) => t.cardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScryfallCardFacesTableAnnotationComposer(
                $db: $db,
                $table: $db.scryfallCardFaces,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScryfallCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScryfallCardsTable,
          ScryfallCard,
          $$ScryfallCardsTableFilterComposer,
          $$ScryfallCardsTableOrderingComposer,
          $$ScryfallCardsTableAnnotationComposer,
          $$ScryfallCardsTableCreateCompanionBuilder,
          $$ScryfallCardsTableUpdateCompanionBuilder,
          (ScryfallCard, $$ScryfallCardsTableReferences),
          ScryfallCard,
          PrefetchHooks Function({bool scryfallCardFacesRefs})
        > {
  $$ScryfallCardsTableTableManager(_$AppDatabase db, $ScryfallCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScryfallCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScryfallCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScryfallCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scryfallId = const Value.absent(),
                Value<String?> oracleId = const Value.absent(),
                Value<String?> tcgplayerId = const Value.absent(),
                Value<String?> cardmarketId = const Value.absent(),
                Value<String?> multiverseIdsJson = const Value.absent(),
                Value<String> layout = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> printedName = const Value.absent(),
                Value<String?> flavorName = const Value.absent(),
                Value<String> setId = const Value.absent(),
                Value<String> setCode = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> setType = const Value.absent(),
                Value<String> setUri = const Value.absent(),
                Value<String> setSearchUri = const Value.absent(),
                Value<String> scryfallSetUri = const Value.absent(),
                Value<String> collectorNumber = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<int> rarityValue = const Value.absent(),
                Value<String> releasedAt = const Value.absent(),
                Value<String> scryfallUri = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> rulingsUri = const Value.absent(),
                Value<String> printsSearchUri = const Value.absent(),
                Value<String?> manaCost = const Value.absent(),
                Value<String> typeLine = const Value.absent(),
                Value<String?> printedTypeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> printedText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> colorsJson = const Value.absent(),
                Value<int> colorMask = const Value.absent(),
                Value<String?> colorIdentityJson = const Value.absent(),
                Value<int> colorIdentityMask = const Value.absent(),
                Value<String?> producedManaJson = const Value.absent(),
                Value<int> producedManaMask = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> defense = const Value.absent(),
                Value<double> cmc = const Value.absent(),
                Value<String?> keywordsJson = const Value.absent(),
                Value<bool> hasCardFaces = const Value.absent(),
                Value<bool> hasColorIndicator = const Value.absent(),
                Value<String?> borderColor = const Value.absent(),
                Value<String?> frame = const Value.absent(),
                Value<String?> frameEffectsJson = const Value.absent(),
                Value<String?> securityStamp = const Value.absent(),
                Value<bool> highresImage = const Value.absent(),
                Value<String?> imageStatus = const Value.absent(),
                Value<String?> imageUpdatedAt = const Value.absent(),
                Value<String?> imageSmall = const Value.absent(),
                Value<String?> imageNormal = const Value.absent(),
                Value<String?> imageLarge = const Value.absent(),
                Value<String?> imagePng = const Value.absent(),
                Value<String?> imageArtCrop = const Value.absent(),
                Value<String?> imageBorderCrop = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> artistIdsJson = const Value.absent(),
                Value<String?> illustrationId = const Value.absent(),
                Value<String?> watermark = const Value.absent(),
                Value<bool> fullArt = const Value.absent(),
                Value<bool> textless = const Value.absent(),
                Value<bool> booster = const Value.absent(),
                Value<bool> storySpotlight = const Value.absent(),
                Value<bool> promo = const Value.absent(),
                Value<bool> reprint = const Value.absent(),
                Value<bool> variation = const Value.absent(),
                Value<bool> reserved = const Value.absent(),
                Value<bool> gameChanger = const Value.absent(),
                Value<bool> oversized = const Value.absent(),
                Value<bool> nonfoil = const Value.absent(),
                Value<bool> foil = const Value.absent(),
                Value<bool> etched = const Value.absent(),
                Value<bool> glossy = const Value.absent(),
                Value<bool> paper = const Value.absent(),
                Value<String?> legalStandard = const Value.absent(),
                Value<String?> legalFuture = const Value.absent(),
                Value<String?> legalHistoric = const Value.absent(),
                Value<String?> legalTimeless = const Value.absent(),
                Value<String?> legalGladiator = const Value.absent(),
                Value<String?> legalPioneer = const Value.absent(),
                Value<String?> legalModern = const Value.absent(),
                Value<String?> legalLegacy = const Value.absent(),
                Value<String?> legalPauper = const Value.absent(),
                Value<String?> legalVintage = const Value.absent(),
                Value<String?> legalPenny = const Value.absent(),
                Value<String?> legalCommander = const Value.absent(),
                Value<String?> legalOathbreaker = const Value.absent(),
                Value<String?> legalStandardBrawl = const Value.absent(),
                Value<String?> legalBrawl = const Value.absent(),
                Value<String?> legalCompetitiveBrawl = const Value.absent(),
                Value<String?> legalAlchemy = const Value.absent(),
                Value<String?> legalPauperCommander = const Value.absent(),
                Value<String?> legalDuel = const Value.absent(),
                Value<String?> legalOldSchool = const Value.absent(),
                Value<String?> legalPremodern = const Value.absent(),
                Value<String?> legalPredh = const Value.absent(),
                Value<String?> legalTlr = const Value.absent(),
                Value<String?> pricesUsd = const Value.absent(),
                Value<String?> pricesUsdFoil = const Value.absent(),
                Value<String?> pricesUsdEtched = const Value.absent(),
                Value<String?> pricesEur = const Value.absent(),
                Value<String?> pricesEurFoil = const Value.absent(),
                Value<String?> pricesTix = const Value.absent(),
                Value<String?> relatedGathererUri = const Value.absent(),
                Value<String?> relatedTcgplayerInfiniteArticlesUri =
                    const Value.absent(),
                Value<String?> relatedTcgplayerInfiniteDecksUri =
                    const Value.absent(),
                Value<String?> relatedEdhrecUri = const Value.absent(),
                Value<String?> purchaseTcgplayerUri = const Value.absent(),
                Value<String?> purchaseCardmarketUri = const Value.absent(),
                Value<String?> purchaseCardhoarderUri = const Value.absent(),
                Value<String?> cardBackId = const Value.absent(),
                Value<String?> allPartsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScryfallCardsCompanion(
                scryfallId: scryfallId,
                oracleId: oracleId,
                tcgplayerId: tcgplayerId,
                cardmarketId: cardmarketId,
                multiverseIdsJson: multiverseIdsJson,
                layout: layout,
                name: name,
                printedName: printedName,
                flavorName: flavorName,
                setId: setId,
                setCode: setCode,
                setName: setName,
                setType: setType,
                setUri: setUri,
                setSearchUri: setSearchUri,
                scryfallSetUri: scryfallSetUri,
                collectorNumber: collectorNumber,
                lang: lang,
                rarity: rarity,
                rarityValue: rarityValue,
                releasedAt: releasedAt,
                scryfallUri: scryfallUri,
                uri: uri,
                rulingsUri: rulingsUri,
                printsSearchUri: printsSearchUri,
                manaCost: manaCost,
                typeLine: typeLine,
                printedTypeLine: printedTypeLine,
                oracleText: oracleText,
                printedText: printedText,
                flavorText: flavorText,
                colorsJson: colorsJson,
                colorMask: colorMask,
                colorIdentityJson: colorIdentityJson,
                colorIdentityMask: colorIdentityMask,
                producedManaJson: producedManaJson,
                producedManaMask: producedManaMask,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                defense: defense,
                cmc: cmc,
                keywordsJson: keywordsJson,
                hasCardFaces: hasCardFaces,
                hasColorIndicator: hasColorIndicator,
                borderColor: borderColor,
                frame: frame,
                frameEffectsJson: frameEffectsJson,
                securityStamp: securityStamp,
                highresImage: highresImage,
                imageStatus: imageStatus,
                imageUpdatedAt: imageUpdatedAt,
                imageSmall: imageSmall,
                imageNormal: imageNormal,
                imageLarge: imageLarge,
                imagePng: imagePng,
                imageArtCrop: imageArtCrop,
                imageBorderCrop: imageBorderCrop,
                artist: artist,
                artistIdsJson: artistIdsJson,
                illustrationId: illustrationId,
                watermark: watermark,
                fullArt: fullArt,
                textless: textless,
                booster: booster,
                storySpotlight: storySpotlight,
                promo: promo,
                reprint: reprint,
                variation: variation,
                reserved: reserved,
                gameChanger: gameChanger,
                oversized: oversized,
                nonfoil: nonfoil,
                foil: foil,
                etched: etched,
                glossy: glossy,
                paper: paper,
                legalStandard: legalStandard,
                legalFuture: legalFuture,
                legalHistoric: legalHistoric,
                legalTimeless: legalTimeless,
                legalGladiator: legalGladiator,
                legalPioneer: legalPioneer,
                legalModern: legalModern,
                legalLegacy: legalLegacy,
                legalPauper: legalPauper,
                legalVintage: legalVintage,
                legalPenny: legalPenny,
                legalCommander: legalCommander,
                legalOathbreaker: legalOathbreaker,
                legalStandardBrawl: legalStandardBrawl,
                legalBrawl: legalBrawl,
                legalCompetitiveBrawl: legalCompetitiveBrawl,
                legalAlchemy: legalAlchemy,
                legalPauperCommander: legalPauperCommander,
                legalDuel: legalDuel,
                legalOldSchool: legalOldSchool,
                legalPremodern: legalPremodern,
                legalPredh: legalPredh,
                legalTlr: legalTlr,
                pricesUsd: pricesUsd,
                pricesUsdFoil: pricesUsdFoil,
                pricesUsdEtched: pricesUsdEtched,
                pricesEur: pricesEur,
                pricesEurFoil: pricesEurFoil,
                pricesTix: pricesTix,
                relatedGathererUri: relatedGathererUri,
                relatedTcgplayerInfiniteArticlesUri:
                    relatedTcgplayerInfiniteArticlesUri,
                relatedTcgplayerInfiniteDecksUri:
                    relatedTcgplayerInfiniteDecksUri,
                relatedEdhrecUri: relatedEdhrecUri,
                purchaseTcgplayerUri: purchaseTcgplayerUri,
                purchaseCardmarketUri: purchaseCardmarketUri,
                purchaseCardhoarderUri: purchaseCardhoarderUri,
                cardBackId: cardBackId,
                allPartsJson: allPartsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scryfallId,
                Value<String?> oracleId = const Value.absent(),
                Value<String?> tcgplayerId = const Value.absent(),
                Value<String?> cardmarketId = const Value.absent(),
                Value<String?> multiverseIdsJson = const Value.absent(),
                required String layout,
                required String name,
                Value<String?> printedName = const Value.absent(),
                Value<String?> flavorName = const Value.absent(),
                required String setId,
                required String setCode,
                required String setName,
                required String setType,
                required String setUri,
                required String setSearchUri,
                required String scryfallSetUri,
                required String collectorNumber,
                required String lang,
                required String rarity,
                Value<int> rarityValue = const Value.absent(),
                required String releasedAt,
                required String scryfallUri,
                required String uri,
                required String rulingsUri,
                required String printsSearchUri,
                Value<String?> manaCost = const Value.absent(),
                required String typeLine,
                Value<String?> printedTypeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> printedText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> colorsJson = const Value.absent(),
                Value<int> colorMask = const Value.absent(),
                Value<String?> colorIdentityJson = const Value.absent(),
                Value<int> colorIdentityMask = const Value.absent(),
                Value<String?> producedManaJson = const Value.absent(),
                Value<int> producedManaMask = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> defense = const Value.absent(),
                required double cmc,
                Value<String?> keywordsJson = const Value.absent(),
                Value<bool> hasCardFaces = const Value.absent(),
                Value<bool> hasColorIndicator = const Value.absent(),
                Value<String?> borderColor = const Value.absent(),
                Value<String?> frame = const Value.absent(),
                Value<String?> frameEffectsJson = const Value.absent(),
                Value<String?> securityStamp = const Value.absent(),
                Value<bool> highresImage = const Value.absent(),
                Value<String?> imageStatus = const Value.absent(),
                Value<String?> imageUpdatedAt = const Value.absent(),
                Value<String?> imageSmall = const Value.absent(),
                Value<String?> imageNormal = const Value.absent(),
                Value<String?> imageLarge = const Value.absent(),
                Value<String?> imagePng = const Value.absent(),
                Value<String?> imageArtCrop = const Value.absent(),
                Value<String?> imageBorderCrop = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> artistIdsJson = const Value.absent(),
                Value<String?> illustrationId = const Value.absent(),
                Value<String?> watermark = const Value.absent(),
                Value<bool> fullArt = const Value.absent(),
                Value<bool> textless = const Value.absent(),
                Value<bool> booster = const Value.absent(),
                Value<bool> storySpotlight = const Value.absent(),
                Value<bool> promo = const Value.absent(),
                Value<bool> reprint = const Value.absent(),
                Value<bool> variation = const Value.absent(),
                Value<bool> reserved = const Value.absent(),
                Value<bool> gameChanger = const Value.absent(),
                Value<bool> oversized = const Value.absent(),
                Value<bool> nonfoil = const Value.absent(),
                Value<bool> foil = const Value.absent(),
                Value<bool> etched = const Value.absent(),
                Value<bool> glossy = const Value.absent(),
                Value<bool> paper = const Value.absent(),
                Value<String?> legalStandard = const Value.absent(),
                Value<String?> legalFuture = const Value.absent(),
                Value<String?> legalHistoric = const Value.absent(),
                Value<String?> legalTimeless = const Value.absent(),
                Value<String?> legalGladiator = const Value.absent(),
                Value<String?> legalPioneer = const Value.absent(),
                Value<String?> legalModern = const Value.absent(),
                Value<String?> legalLegacy = const Value.absent(),
                Value<String?> legalPauper = const Value.absent(),
                Value<String?> legalVintage = const Value.absent(),
                Value<String?> legalPenny = const Value.absent(),
                Value<String?> legalCommander = const Value.absent(),
                Value<String?> legalOathbreaker = const Value.absent(),
                Value<String?> legalStandardBrawl = const Value.absent(),
                Value<String?> legalBrawl = const Value.absent(),
                Value<String?> legalCompetitiveBrawl = const Value.absent(),
                Value<String?> legalAlchemy = const Value.absent(),
                Value<String?> legalPauperCommander = const Value.absent(),
                Value<String?> legalDuel = const Value.absent(),
                Value<String?> legalOldSchool = const Value.absent(),
                Value<String?> legalPremodern = const Value.absent(),
                Value<String?> legalPredh = const Value.absent(),
                Value<String?> legalTlr = const Value.absent(),
                Value<String?> pricesUsd = const Value.absent(),
                Value<String?> pricesUsdFoil = const Value.absent(),
                Value<String?> pricesUsdEtched = const Value.absent(),
                Value<String?> pricesEur = const Value.absent(),
                Value<String?> pricesEurFoil = const Value.absent(),
                Value<String?> pricesTix = const Value.absent(),
                Value<String?> relatedGathererUri = const Value.absent(),
                Value<String?> relatedTcgplayerInfiniteArticlesUri =
                    const Value.absent(),
                Value<String?> relatedTcgplayerInfiniteDecksUri =
                    const Value.absent(),
                Value<String?> relatedEdhrecUri = const Value.absent(),
                Value<String?> purchaseTcgplayerUri = const Value.absent(),
                Value<String?> purchaseCardmarketUri = const Value.absent(),
                Value<String?> purchaseCardhoarderUri = const Value.absent(),
                Value<String?> cardBackId = const Value.absent(),
                Value<String?> allPartsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScryfallCardsCompanion.insert(
                scryfallId: scryfallId,
                oracleId: oracleId,
                tcgplayerId: tcgplayerId,
                cardmarketId: cardmarketId,
                multiverseIdsJson: multiverseIdsJson,
                layout: layout,
                name: name,
                printedName: printedName,
                flavorName: flavorName,
                setId: setId,
                setCode: setCode,
                setName: setName,
                setType: setType,
                setUri: setUri,
                setSearchUri: setSearchUri,
                scryfallSetUri: scryfallSetUri,
                collectorNumber: collectorNumber,
                lang: lang,
                rarity: rarity,
                rarityValue: rarityValue,
                releasedAt: releasedAt,
                scryfallUri: scryfallUri,
                uri: uri,
                rulingsUri: rulingsUri,
                printsSearchUri: printsSearchUri,
                manaCost: manaCost,
                typeLine: typeLine,
                printedTypeLine: printedTypeLine,
                oracleText: oracleText,
                printedText: printedText,
                flavorText: flavorText,
                colorsJson: colorsJson,
                colorMask: colorMask,
                colorIdentityJson: colorIdentityJson,
                colorIdentityMask: colorIdentityMask,
                producedManaJson: producedManaJson,
                producedManaMask: producedManaMask,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                defense: defense,
                cmc: cmc,
                keywordsJson: keywordsJson,
                hasCardFaces: hasCardFaces,
                hasColorIndicator: hasColorIndicator,
                borderColor: borderColor,
                frame: frame,
                frameEffectsJson: frameEffectsJson,
                securityStamp: securityStamp,
                highresImage: highresImage,
                imageStatus: imageStatus,
                imageUpdatedAt: imageUpdatedAt,
                imageSmall: imageSmall,
                imageNormal: imageNormal,
                imageLarge: imageLarge,
                imagePng: imagePng,
                imageArtCrop: imageArtCrop,
                imageBorderCrop: imageBorderCrop,
                artist: artist,
                artistIdsJson: artistIdsJson,
                illustrationId: illustrationId,
                watermark: watermark,
                fullArt: fullArt,
                textless: textless,
                booster: booster,
                storySpotlight: storySpotlight,
                promo: promo,
                reprint: reprint,
                variation: variation,
                reserved: reserved,
                gameChanger: gameChanger,
                oversized: oversized,
                nonfoil: nonfoil,
                foil: foil,
                etched: etched,
                glossy: glossy,
                paper: paper,
                legalStandard: legalStandard,
                legalFuture: legalFuture,
                legalHistoric: legalHistoric,
                legalTimeless: legalTimeless,
                legalGladiator: legalGladiator,
                legalPioneer: legalPioneer,
                legalModern: legalModern,
                legalLegacy: legalLegacy,
                legalPauper: legalPauper,
                legalVintage: legalVintage,
                legalPenny: legalPenny,
                legalCommander: legalCommander,
                legalOathbreaker: legalOathbreaker,
                legalStandardBrawl: legalStandardBrawl,
                legalBrawl: legalBrawl,
                legalCompetitiveBrawl: legalCompetitiveBrawl,
                legalAlchemy: legalAlchemy,
                legalPauperCommander: legalPauperCommander,
                legalDuel: legalDuel,
                legalOldSchool: legalOldSchool,
                legalPremodern: legalPremodern,
                legalPredh: legalPredh,
                legalTlr: legalTlr,
                pricesUsd: pricesUsd,
                pricesUsdFoil: pricesUsdFoil,
                pricesUsdEtched: pricesUsdEtched,
                pricesEur: pricesEur,
                pricesEurFoil: pricesEurFoil,
                pricesTix: pricesTix,
                relatedGathererUri: relatedGathererUri,
                relatedTcgplayerInfiniteArticlesUri:
                    relatedTcgplayerInfiniteArticlesUri,
                relatedTcgplayerInfiniteDecksUri:
                    relatedTcgplayerInfiniteDecksUri,
                relatedEdhrecUri: relatedEdhrecUri,
                purchaseTcgplayerUri: purchaseTcgplayerUri,
                purchaseCardmarketUri: purchaseCardmarketUri,
                purchaseCardhoarderUri: purchaseCardhoarderUri,
                cardBackId: cardBackId,
                allPartsJson: allPartsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScryfallCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scryfallCardFacesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (scryfallCardFacesRefs) db.scryfallCardFaces,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scryfallCardFacesRefs)
                    await $_getPrefetchedData<
                      ScryfallCard,
                      $ScryfallCardsTable,
                      ScryfallCardFace
                    >(
                      currentTable: table,
                      referencedTable: $$ScryfallCardsTableReferences
                          ._scryfallCardFacesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScryfallCardsTableReferences(
                            db,
                            table,
                            p0,
                          ).scryfallCardFacesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.cardId == item.scryfallId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScryfallCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScryfallCardsTable,
      ScryfallCard,
      $$ScryfallCardsTableFilterComposer,
      $$ScryfallCardsTableOrderingComposer,
      $$ScryfallCardsTableAnnotationComposer,
      $$ScryfallCardsTableCreateCompanionBuilder,
      $$ScryfallCardsTableUpdateCompanionBuilder,
      (ScryfallCard, $$ScryfallCardsTableReferences),
      ScryfallCard,
      PrefetchHooks Function({bool scryfallCardFacesRefs})
    >;
typedef $$ScryfallCardFacesTableCreateCompanionBuilder =
    ScryfallCardFacesCompanion Function({
      required String cardId,
      required int faceIndex,
      required String name,
      Value<String?> printedName,
      Value<String?> flavorName,
      Value<String?> manaCost,
      Value<String?> typeLine,
      Value<String?> printedTypeLine,
      Value<String?> oracleText,
      Value<String?> printedText,
      Value<String?> flavorText,
      Value<String?> colorsJson,
      Value<int> colorMask,
      Value<String?> colorIndicatorJson,
      Value<int> colorIndicatorMask,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> defense,
      required double cmc,
      Value<String?> artist,
      Value<String?> artistId,
      Value<String?> illustrationId,
      Value<bool> highresImage,
      Value<String?> imageStatus,
      Value<String?> imageSmall,
      Value<String?> imageNormal,
      Value<String?> imageLarge,
      Value<String?> imagePng,
      Value<String?> imageArtCrop,
      Value<String?> imageBorderCrop,
      Value<String?> watermark,
      Value<int> rowid,
    });
typedef $$ScryfallCardFacesTableUpdateCompanionBuilder =
    ScryfallCardFacesCompanion Function({
      Value<String> cardId,
      Value<int> faceIndex,
      Value<String> name,
      Value<String?> printedName,
      Value<String?> flavorName,
      Value<String?> manaCost,
      Value<String?> typeLine,
      Value<String?> printedTypeLine,
      Value<String?> oracleText,
      Value<String?> printedText,
      Value<String?> flavorText,
      Value<String?> colorsJson,
      Value<int> colorMask,
      Value<String?> colorIndicatorJson,
      Value<int> colorIndicatorMask,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> defense,
      Value<double> cmc,
      Value<String?> artist,
      Value<String?> artistId,
      Value<String?> illustrationId,
      Value<bool> highresImage,
      Value<String?> imageStatus,
      Value<String?> imageSmall,
      Value<String?> imageNormal,
      Value<String?> imageLarge,
      Value<String?> imagePng,
      Value<String?> imageArtCrop,
      Value<String?> imageBorderCrop,
      Value<String?> watermark,
      Value<int> rowid,
    });

final class $$ScryfallCardFacesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScryfallCardFacesTable,
          ScryfallCardFace
        > {
  $$ScryfallCardFacesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScryfallCardsTable _cardIdTable(_$AppDatabase db) => db.scryfallCards
      .createAlias('scryfall_card_faces__card_id__scryfall_cards__scryfall_id');

  $$ScryfallCardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$ScryfallCardsTableTableManager(
      $_db,
      $_db.scryfallCards,
    ).filter((f) => f.scryfallId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScryfallCardFacesTableFilterComposer
    extends Composer<_$AppDatabase, $ScryfallCardFacesTable> {
  $$ScryfallCardFacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get faceIndex => $composableBuilder(
    column: $table.faceIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printedName => $composableBuilder(
    column: $table.printedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printedTypeLine => $composableBuilder(
    column: $table.printedTypeLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printedText => $composableBuilder(
    column: $table.printedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorsJson => $composableBuilder(
    column: $table.colorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorMask => $composableBuilder(
    column: $table.colorMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorIndicatorJson => $composableBuilder(
    column: $table.colorIndicatorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorIndicatorMask => $composableBuilder(
    column: $table.colorIndicatorMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cmc => $composableBuilder(
    column: $table.cmc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get illustrationId => $composableBuilder(
    column: $table.illustrationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get highresImage => $composableBuilder(
    column: $table.highresImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageStatus => $composableBuilder(
    column: $table.imageStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageSmall => $composableBuilder(
    column: $table.imageSmall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageNormal => $composableBuilder(
    column: $table.imageNormal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageLarge => $composableBuilder(
    column: $table.imageLarge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePng => $composableBuilder(
    column: $table.imagePng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageArtCrop => $composableBuilder(
    column: $table.imageArtCrop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageBorderCrop => $composableBuilder(
    column: $table.imageBorderCrop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnFilters(column),
  );

  $$ScryfallCardsTableFilterComposer get cardId {
    final $$ScryfallCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.scryfallCards,
      getReferencedColumn: (t) => t.scryfallId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScryfallCardsTableFilterComposer(
            $db: $db,
            $table: $db.scryfallCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScryfallCardFacesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScryfallCardFacesTable> {
  $$ScryfallCardFacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get faceIndex => $composableBuilder(
    column: $table.faceIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printedName => $composableBuilder(
    column: $table.printedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printedTypeLine => $composableBuilder(
    column: $table.printedTypeLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printedText => $composableBuilder(
    column: $table.printedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorsJson => $composableBuilder(
    column: $table.colorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorMask => $composableBuilder(
    column: $table.colorMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorIndicatorJson => $composableBuilder(
    column: $table.colorIndicatorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorIndicatorMask => $composableBuilder(
    column: $table.colorIndicatorMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cmc => $composableBuilder(
    column: $table.cmc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get illustrationId => $composableBuilder(
    column: $table.illustrationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get highresImage => $composableBuilder(
    column: $table.highresImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageStatus => $composableBuilder(
    column: $table.imageStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageSmall => $composableBuilder(
    column: $table.imageSmall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageNormal => $composableBuilder(
    column: $table.imageNormal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageLarge => $composableBuilder(
    column: $table.imageLarge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePng => $composableBuilder(
    column: $table.imagePng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageArtCrop => $composableBuilder(
    column: $table.imageArtCrop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageBorderCrop => $composableBuilder(
    column: $table.imageBorderCrop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScryfallCardsTableOrderingComposer get cardId {
    final $$ScryfallCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.scryfallCards,
      getReferencedColumn: (t) => t.scryfallId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScryfallCardsTableOrderingComposer(
            $db: $db,
            $table: $db.scryfallCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScryfallCardFacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScryfallCardFacesTable> {
  $$ScryfallCardFacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get faceIndex =>
      $composableBuilder(column: $table.faceIndex, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get printedName => $composableBuilder(
    column: $table.printedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manaCost =>
      $composableBuilder(column: $table.manaCost, builder: (column) => column);

  GeneratedColumn<String> get typeLine =>
      $composableBuilder(column: $table.typeLine, builder: (column) => column);

  GeneratedColumn<String> get printedTypeLine => $composableBuilder(
    column: $table.printedTypeLine,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printedText => $composableBuilder(
    column: $table.printedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorsJson => $composableBuilder(
    column: $table.colorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorMask =>
      $composableBuilder(column: $table.colorMask, builder: (column) => column);

  GeneratedColumn<String> get colorIndicatorJson => $composableBuilder(
    column: $table.colorIndicatorJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorIndicatorMask => $composableBuilder(
    column: $table.colorIndicatorMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<String> get toughness =>
      $composableBuilder(column: $table.toughness, builder: (column) => column);

  GeneratedColumn<String> get loyalty =>
      $composableBuilder(column: $table.loyalty, builder: (column) => column);

  GeneratedColumn<String> get defense =>
      $composableBuilder(column: $table.defense, builder: (column) => column);

  GeneratedColumn<double> get cmc =>
      $composableBuilder(column: $table.cmc, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get illustrationId => $composableBuilder(
    column: $table.illustrationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get highresImage => $composableBuilder(
    column: $table.highresImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageStatus => $composableBuilder(
    column: $table.imageStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageSmall => $composableBuilder(
    column: $table.imageSmall,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageNormal => $composableBuilder(
    column: $table.imageNormal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageLarge => $composableBuilder(
    column: $table.imageLarge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePng =>
      $composableBuilder(column: $table.imagePng, builder: (column) => column);

  GeneratedColumn<String> get imageArtCrop => $composableBuilder(
    column: $table.imageArtCrop,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageBorderCrop => $composableBuilder(
    column: $table.imageBorderCrop,
    builder: (column) => column,
  );

  GeneratedColumn<String> get watermark =>
      $composableBuilder(column: $table.watermark, builder: (column) => column);

  $$ScryfallCardsTableAnnotationComposer get cardId {
    final $$ScryfallCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.scryfallCards,
      getReferencedColumn: (t) => t.scryfallId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScryfallCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.scryfallCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScryfallCardFacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScryfallCardFacesTable,
          ScryfallCardFace,
          $$ScryfallCardFacesTableFilterComposer,
          $$ScryfallCardFacesTableOrderingComposer,
          $$ScryfallCardFacesTableAnnotationComposer,
          $$ScryfallCardFacesTableCreateCompanionBuilder,
          $$ScryfallCardFacesTableUpdateCompanionBuilder,
          (ScryfallCardFace, $$ScryfallCardFacesTableReferences),
          ScryfallCardFace,
          PrefetchHooks Function({bool cardId})
        > {
  $$ScryfallCardFacesTableTableManager(
    _$AppDatabase db,
    $ScryfallCardFacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScryfallCardFacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScryfallCardFacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScryfallCardFacesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<int> faceIndex = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> printedName = const Value.absent(),
                Value<String?> flavorName = const Value.absent(),
                Value<String?> manaCost = const Value.absent(),
                Value<String?> typeLine = const Value.absent(),
                Value<String?> printedTypeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> printedText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> colorsJson = const Value.absent(),
                Value<int> colorMask = const Value.absent(),
                Value<String?> colorIndicatorJson = const Value.absent(),
                Value<int> colorIndicatorMask = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> defense = const Value.absent(),
                Value<double> cmc = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> illustrationId = const Value.absent(),
                Value<bool> highresImage = const Value.absent(),
                Value<String?> imageStatus = const Value.absent(),
                Value<String?> imageSmall = const Value.absent(),
                Value<String?> imageNormal = const Value.absent(),
                Value<String?> imageLarge = const Value.absent(),
                Value<String?> imagePng = const Value.absent(),
                Value<String?> imageArtCrop = const Value.absent(),
                Value<String?> imageBorderCrop = const Value.absent(),
                Value<String?> watermark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScryfallCardFacesCompanion(
                cardId: cardId,
                faceIndex: faceIndex,
                name: name,
                printedName: printedName,
                flavorName: flavorName,
                manaCost: manaCost,
                typeLine: typeLine,
                printedTypeLine: printedTypeLine,
                oracleText: oracleText,
                printedText: printedText,
                flavorText: flavorText,
                colorsJson: colorsJson,
                colorMask: colorMask,
                colorIndicatorJson: colorIndicatorJson,
                colorIndicatorMask: colorIndicatorMask,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                defense: defense,
                cmc: cmc,
                artist: artist,
                artistId: artistId,
                illustrationId: illustrationId,
                highresImage: highresImage,
                imageStatus: imageStatus,
                imageSmall: imageSmall,
                imageNormal: imageNormal,
                imageLarge: imageLarge,
                imagePng: imagePng,
                imageArtCrop: imageArtCrop,
                imageBorderCrop: imageBorderCrop,
                watermark: watermark,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required int faceIndex,
                required String name,
                Value<String?> printedName = const Value.absent(),
                Value<String?> flavorName = const Value.absent(),
                Value<String?> manaCost = const Value.absent(),
                Value<String?> typeLine = const Value.absent(),
                Value<String?> printedTypeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> printedText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> colorsJson = const Value.absent(),
                Value<int> colorMask = const Value.absent(),
                Value<String?> colorIndicatorJson = const Value.absent(),
                Value<int> colorIndicatorMask = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> defense = const Value.absent(),
                required double cmc,
                Value<String?> artist = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> illustrationId = const Value.absent(),
                Value<bool> highresImage = const Value.absent(),
                Value<String?> imageStatus = const Value.absent(),
                Value<String?> imageSmall = const Value.absent(),
                Value<String?> imageNormal = const Value.absent(),
                Value<String?> imageLarge = const Value.absent(),
                Value<String?> imagePng = const Value.absent(),
                Value<String?> imageArtCrop = const Value.absent(),
                Value<String?> imageBorderCrop = const Value.absent(),
                Value<String?> watermark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScryfallCardFacesCompanion.insert(
                cardId: cardId,
                faceIndex: faceIndex,
                name: name,
                printedName: printedName,
                flavorName: flavorName,
                manaCost: manaCost,
                typeLine: typeLine,
                printedTypeLine: printedTypeLine,
                oracleText: oracleText,
                printedText: printedText,
                flavorText: flavorText,
                colorsJson: colorsJson,
                colorMask: colorMask,
                colorIndicatorJson: colorIndicatorJson,
                colorIndicatorMask: colorIndicatorMask,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                defense: defense,
                cmc: cmc,
                artist: artist,
                artistId: artistId,
                illustrationId: illustrationId,
                highresImage: highresImage,
                imageStatus: imageStatus,
                imageSmall: imageSmall,
                imageNormal: imageNormal,
                imageLarge: imageLarge,
                imagePng: imagePng,
                imageArtCrop: imageArtCrop,
                imageBorderCrop: imageBorderCrop,
                watermark: watermark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScryfallCardFacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable:
                                    $$ScryfallCardFacesTableReferences
                                        ._cardIdTable(db),
                                referencedColumn:
                                    $$ScryfallCardFacesTableReferences
                                        ._cardIdTable(db)
                                        .scryfallId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScryfallCardFacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScryfallCardFacesTable,
      ScryfallCardFace,
      $$ScryfallCardFacesTableFilterComposer,
      $$ScryfallCardFacesTableOrderingComposer,
      $$ScryfallCardFacesTableAnnotationComposer,
      $$ScryfallCardFacesTableCreateCompanionBuilder,
      $$ScryfallCardFacesTableUpdateCompanionBuilder,
      (ScryfallCardFace, $$ScryfallCardFacesTableReferences),
      ScryfallCardFace,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$ScryfallTagsTableCreateCompanionBuilder =
    ScryfallTagsCompanion Function({
      required String scryfallId,
      required String label,
      required String slug,
      required String description,
      required String type,
      required List<String> parentIdsJson,
      required List<String> childIdsJson,
      required List<String> aliasesJson,
      required List<String> taggedJson,
      Value<int> rowid,
    });
typedef $$ScryfallTagsTableUpdateCompanionBuilder =
    ScryfallTagsCompanion Function({
      Value<String> scryfallId,
      Value<String> label,
      Value<String> slug,
      Value<String> description,
      Value<String> type,
      Value<List<String>> parentIdsJson,
      Value<List<String>> childIdsJson,
      Value<List<String>> aliasesJson,
      Value<List<String>> taggedJson,
      Value<int> rowid,
    });

class $$ScryfallTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ScryfallTagsTable> {
  $$ScryfallTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get parentIdsJson => $composableBuilder(
    column: $table.parentIdsJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get childIdsJson => $composableBuilder(
    column: $table.childIdsJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get taggedJson => $composableBuilder(
    column: $table.taggedJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ScryfallTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScryfallTagsTable> {
  $$ScryfallTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentIdsJson => $composableBuilder(
    column: $table.parentIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childIdsJson => $composableBuilder(
    column: $table.childIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taggedJson => $composableBuilder(
    column: $table.taggedJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScryfallTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScryfallTagsTable> {
  $$ScryfallTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get parentIdsJson =>
      $composableBuilder(
        column: $table.parentIdsJson,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get childIdsJson =>
      $composableBuilder(
        column: $table.childIdsJson,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get aliasesJson =>
      $composableBuilder(
        column: $table.aliasesJson,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get taggedJson =>
      $composableBuilder(
        column: $table.taggedJson,
        builder: (column) => column,
      );
}

class $$ScryfallTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScryfallTagsTable,
          ScryfallTag,
          $$ScryfallTagsTableFilterComposer,
          $$ScryfallTagsTableOrderingComposer,
          $$ScryfallTagsTableAnnotationComposer,
          $$ScryfallTagsTableCreateCompanionBuilder,
          $$ScryfallTagsTableUpdateCompanionBuilder,
          (
            ScryfallTag,
            BaseReferences<_$AppDatabase, $ScryfallTagsTable, ScryfallTag>,
          ),
          ScryfallTag,
          PrefetchHooks Function()
        > {
  $$ScryfallTagsTableTableManager(_$AppDatabase db, $ScryfallTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScryfallTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScryfallTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScryfallTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scryfallId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<List<String>> parentIdsJson = const Value.absent(),
                Value<List<String>> childIdsJson = const Value.absent(),
                Value<List<String>> aliasesJson = const Value.absent(),
                Value<List<String>> taggedJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScryfallTagsCompanion(
                scryfallId: scryfallId,
                label: label,
                slug: slug,
                description: description,
                type: type,
                parentIdsJson: parentIdsJson,
                childIdsJson: childIdsJson,
                aliasesJson: aliasesJson,
                taggedJson: taggedJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scryfallId,
                required String label,
                required String slug,
                required String description,
                required String type,
                required List<String> parentIdsJson,
                required List<String> childIdsJson,
                required List<String> aliasesJson,
                required List<String> taggedJson,
                Value<int> rowid = const Value.absent(),
              }) => ScryfallTagsCompanion.insert(
                scryfallId: scryfallId,
                label: label,
                slug: slug,
                description: description,
                type: type,
                parentIdsJson: parentIdsJson,
                childIdsJson: childIdsJson,
                aliasesJson: aliasesJson,
                taggedJson: taggedJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScryfallTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScryfallTagsTable,
      ScryfallTag,
      $$ScryfallTagsTableFilterComposer,
      $$ScryfallTagsTableOrderingComposer,
      $$ScryfallTagsTableAnnotationComposer,
      $$ScryfallTagsTableCreateCompanionBuilder,
      $$ScryfallTagsTableUpdateCompanionBuilder,
      (
        ScryfallTag,
        BaseReferences<_$AppDatabase, $ScryfallTagsTable, ScryfallTag>,
      ),
      ScryfallTag,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScryfallCardsTableTableManager get scryfallCards =>
      $$ScryfallCardsTableTableManager(_db, _db.scryfallCards);
  $$ScryfallCardFacesTableTableManager get scryfallCardFaces =>
      $$ScryfallCardFacesTableTableManager(_db, _db.scryfallCardFaces);
  $$ScryfallTagsTableTableManager get scryfallTags =>
      $$ScryfallTagsTableTableManager(_db, _db.scryfallTags);
}
