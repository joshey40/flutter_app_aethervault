import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_aethervault/services/card_database/scryfall_download.dart';

void main() {
  group('ScryfallDownloadService', () {
    late ScryfallDownloadService service;
    late Directory tempDirectory;

    setUp(() async {
      service = ScryfallDownloadService();
      tempDirectory = await Directory.systemTemp.createTemp('scryfall_test_');
    });

    tearDown(() async {
      service.dispose();
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    group('shouldDownloadCacheEntry', () {
      test('downloads when cached file does not exist', () {
        expect(
          ScryfallDownloadService.shouldDownloadCacheEntry(
            cachedFileExists: false,
            metadataFileExists: true,
            cachedUpdatedAt: '2026-01-01T00:00:00Z',
            remoteUpdatedAt: '2026-01-02T00:00:00Z',
          ),
          isTrue,
        );
      });

      test('downloads when metadata does not exist', () {
        expect(
          ScryfallDownloadService.shouldDownloadCacheEntry(
            cachedFileExists: true,
            metadataFileExists: false,
            cachedUpdatedAt: '2026-01-01T00:00:00Z',
            remoteUpdatedAt: '2026-01-02T00:00:00Z',
          ),
          isTrue,
        );
      });

      test('downloads when remote timestamp is missing', () {
        expect(
          ScryfallDownloadService.shouldDownloadCacheEntry(
            cachedFileExists: true,
            metadataFileExists: true,
            cachedUpdatedAt: '2026-01-01T00:00:00Z',
            remoteUpdatedAt: null,
          ),
          isTrue,
        );
      });

      test('downloads when cached timestamp is missing', () {
        expect(
          ScryfallDownloadService.shouldDownloadCacheEntry(
            cachedFileExists: true,
            metadataFileExists: true,
            cachedUpdatedAt: null,
            remoteUpdatedAt: '2026-01-01T00:00:00Z',
          ),
          isTrue,
        );
      });

      test('does not download when cache is up to date', () {
        expect(
          ScryfallDownloadService.shouldDownloadCacheEntry(
            cachedFileExists: true,
            metadataFileExists: true,
            cachedUpdatedAt: '2026-01-01T00:00:00Z',
            remoteUpdatedAt: '2026-01-20T00:00:00Z',
          ),
          isFalse,
        );
      });

      test('downloads when cache is exactly 28 days old', () {
        expect(
          ScryfallDownloadService.shouldDownloadCacheEntry(
            cachedFileExists: true,
            metadataFileExists: true,
            cachedUpdatedAt: '2026-01-01T00:00:00Z',
            remoteUpdatedAt: '2026-01-29T00:00:00Z',
          ),
          isTrue,
        );
      });

      test('downloads when cache is older than 28 days', () {
        expect(
          ScryfallDownloadService.shouldDownloadCacheEntry(
            cachedFileExists: true,
            metadataFileExists: true,
            cachedUpdatedAt: '2026-01-01T00:00:00Z',
            remoteUpdatedAt: '2026-02-01T00:00:00Z',
          ),
          isTrue,
        );
      });
    });

    group('writeStreamToFile', () {
      test('writes all stream data to the target file', () async {
        final path = '${tempDirectory.path}/test.jsonl.gz';
        final chunks = <List<int>>[
          [1, 2, 3],
          [4, 5],
          [6],
        ];

        final progress = <int>[];

        await service.writeStreamToFile(
          Stream.fromIterable(chunks),
          path,
          onProgress: progress.add,
        );

        final file = File(path);

        expect(await file.exists(), isTrue);
        expect(await file.readAsBytes(), [1, 2, 3, 4, 5, 6]);
        expect(progress, [3, 5, 6]);
      });

      test('reports zero bytes for an empty stream', () async {
        final path = '${tempDirectory.path}/empty.jsonl.gz';
        final progress = <int>[];

        await service.writeStreamToFile(
          const Stream<List<int>>.empty(),
          path,
          onProgress: progress.add,
        );

        expect(await File(path).exists(), isTrue);
        expect(await File(path).length(), 0);
        expect(progress, isEmpty);
      });
    });

    group('pruneStaleCacheFiles', () {
      test('does nothing when the cache directory does not exist', () async {
        final directory = Directory(
          '${tempDirectory.path}/missing',
        );

        await service.pruneStaleCacheFiles(
          directory,
          {'oracle_cards'},
        );

        expect(await directory.exists(), isFalse);
      });

      test('removes temporary files', () async {
        final tmp = File('${tempDirectory.path}/cards.tmp');
        await tmp.writeAsString('temporary');

        await service.pruneStaleCacheFiles(
          tempDirectory,
          {'oracle_cards'},
        );

        expect(await tmp.exists(), isFalse);
      });

      test('removes inactive data files', () async {
        final stale = File(
          '${tempDirectory.path}/old_cards.jsonl.gz',
        );
        await stale.writeAsString('old');

        final active = File(
          '${tempDirectory.path}/oracle_cards.jsonl.gz',
        );
        await active.writeAsString('active');

        await service.pruneStaleCacheFiles(
          tempDirectory,
          {'oracle_cards'},
        );

        expect(await stale.exists(), isFalse);
        expect(await active.exists(), isTrue);
      });

      test('keeps unrelated non-cache files', () async {
        final file = File('${tempDirectory.path}/keep.txt');
        await file.writeAsString('keep');

        await service.pruneStaleCacheFiles(
          tempDirectory,
          {'oracle_cards'},
        );

        expect(await file.exists(), isTrue);
      });
    });

    group('progress', () {
      test('dispose closes the progress stream', () async {
        final done = expectLater(
          service.progressStream,
          emitsDone,
        );

        service.dispose();

        await done;
      });
    });
  });
}
