enum ScryfallBulkDataType {
  defaultCards(
    apiType: 'default_cards',
    localFileName: 'scryfall_default_cards.json',
    userFacingName: 'Default Cards',
  ),
  allCards(
    apiType: 'all_cards',
    localFileName: 'scryfall_all_cards.json',
    userFacingName: 'All Cards',
  );

  const ScryfallBulkDataType({
    required this.apiType,
    required this.localFileName,
    required this.userFacingName,
  });

  final String apiType;
  final String localFileName;
  final String userFacingName;
}

class ScryfallBulkDataMetadata {
  const ScryfallBulkDataMetadata({
    required this.type,
    required this.updatedAt,
    required this.downloadUri,
    this.size,
    this.contentType,
    this.contentEncoding,
  });

  final ScryfallBulkDataType type;
  final DateTime updatedAt;
  final Uri downloadUri;
  final int? size;
  final String? contentType;
  final String? contentEncoding;

  factory ScryfallBulkDataMetadata.fromJson(
    ScryfallBulkDataType type,
    Map<String, dynamic> json,
  ) {
    final updatedAt = json['updated_at'] as String?;
    final downloadUri = json['download_uri'] as String?;

    if (updatedAt == null || downloadUri == null) {
      throw FormatException(
        'Bulk metadata for ${type.apiType} is missing updated_at or download_uri.',
      );
    }

    return ScryfallBulkDataMetadata(
      type: type,
      updatedAt: DateTime.parse(updatedAt).toUtc(),
      downloadUri: Uri.parse(downloadUri),
      size: json['size'] is int ? json['size'] as int : null,
      contentType: json['content_type'] as String?,
      contentEncoding: json['content_encoding'] as String?,
    );
  }
}
