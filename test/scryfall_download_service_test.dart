import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_aethervault/services/scryfall_download_service.dart';

void main() {
  group('ScryfallDownloadService cache decision', () {
    test('downloads when no cached file exists', () {
      expect(
        ScryfallDownloadService.shouldDownloadCacheEntry(
          cachedFileExists: false,
          metadataFileExists: false,
          cachedUpdatedAt: null,
          remoteUpdatedAt: '2024-01-01T00:00:00Z',
        ),
        isTrue,
      );
    });

    test('skips download when cached file and metadata match the remote timestamp', () {
      expect(
        ScryfallDownloadService.shouldDownloadCacheEntry(
          cachedFileExists: true,
          metadataFileExists: true,
          cachedUpdatedAt: '2024-01-01T00:00:00Z',
          remoteUpdatedAt: '2024-01-01T00:00:00Z',
        ),
        isFalse,
      );
    });

    test('downloads again when the remote timestamp changed', () {
      expect(
        ScryfallDownloadService.shouldDownloadCacheEntry(
          cachedFileExists: true,
          metadataFileExists: true,
          cachedUpdatedAt: '2024-01-01T00:00:00Z',
          remoteUpdatedAt: '2024-01-02T00:00:00Z',
        ),
        isTrue,
      );
    });
  });
}
