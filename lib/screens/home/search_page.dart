import 'package:flutter/material.dart';

import '../../services/scryfall_search_engine.dart';
import '../../services/scryfall_service.dart';
import '../../services/localization_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScryfallService _scry = ScryfallService();
  final ScryfallSearchEngine _searchEngine = ScryfallSearchEngine();
  static const ScryfallBulkType _bulkType = ScryfallBulkType.oracleCards;
  String _status = 'idle';
  double _progress = 0.0;
  List<dynamic>? _data;
  List<dynamic>? _results;
  final _controller = TextEditingController();
  bool _loadingData = false;
  DateTime? _lastDownload;
  int? _fileSizeBytes;
  bool _isCacheStale = true;
  String? _errorDetails;

  @override
  void initState() {
    super.initState();
    _loadCacheMetadata();
  }

  Future<void> _loadCacheMetadata() async {
    final lastDownload = await _scry.lastDownload(bulkType: _bulkType);
    final fileSizeBytes = await _scry.localFileSizeBytes(bulkType: _bulkType);
    final isCacheStale = await _scry.isCacheStale(bulkType: _bulkType);
    final hasLocalCache = await _scry.hasLocalCache(bulkType: _bulkType);

    if (!mounted) {
      return;
    }

    setState(() {
      _lastDownload = lastDownload;
      _fileSizeBytes = fileSizeBytes;
      _isCacheStale = isCacheStale;
      _status = hasLocalCache ? 'ready' : 'empty';
      _loadingData = false;
    });
  }

  Future<void> _checkAndLoad({bool forceDownload = false}) async {
    setState(() {
      _status = 'checking';
      _loadingData = true;
    });

    final hasLocalCache = await _scry.hasLocalCache(bulkType: _bulkType);
    final stale = await _scry.isCacheStale(bulkType: _bulkType);
    final shouldDownload = forceDownload || !hasLocalCache || stale;

    if (shouldDownload) {
      setState(() {
        _status = 'downloading';
        _progress = 0;
        _errorDetails = null;
      });

      final uri = await _scry.fetchBulkIndexAndChooseUri(bulkType: _bulkType);
      if (uri != null) {
        try {
          await _scry.downloadBulk(uri, bulkType: _bulkType, onProgress: (p) {
            if (!mounted) {
              return;
            }
            setState(() => _progress = p);
          });
        } catch (error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _status = 'error';
            _loadingData = false;
            _errorDetails = error.toString();
          });
          return;
        }
      } else {
        setState(() {
          _status = 'error';
          _loadingData = false;
          _errorDetails = appLocalizations.translate('search.statusError');
        });
        return;
      }
    }

    setState(() {
      _status = 'loading_local';
    });

    final loaded = await _scry.loadLocalData(bulkType: _bulkType);
    final lastDownload = await _scry.lastDownload(bulkType: _bulkType);
    final fileSizeBytes = await _scry.localFileSizeBytes(bulkType: _bulkType);
    final isCacheStale = await _scry.isCacheStale(bulkType: _bulkType);

    if (!mounted) {
      return;
    }

    setState(() {
      _data = loaded;
      _results = null;
      _loadingData = false;
      _lastDownload = lastDownload;
      _fileSizeBytes = fileSizeBytes;
      _isCacheStale = isCacheStale;
      _status = (_data != null) ? 'ready' : 'empty';
    });
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return appLocalizations.translate('search.metaUnknown');
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _formatBytes(int? value) {
    if (value == null) {
      return appLocalizations.translate('search.metaUnknown');
    }

    final mb = value / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  void _onSearchChanged(String q) {
    if (_data == null || q.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }
    final matches = _searchEngine.filterCards(_data!, q);
    setState(() => _results = matches.length > 50 ? matches.sublist(0, 50) : matches);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('nav.search')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingData ? null : () => _checkAndLoad(forceDownload: true),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.translate('search.metaTitle'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appLocalizations.translate('search.syntaxHint'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appLocalizations.translate('search.defaultCardsSource'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appLocalizations
                          .translate('search.metaLastDownload')
                          .replaceAll('{value}', _formatDateTime(_lastDownload)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appLocalizations
                          .translate('search.metaFileSize')
                          .replaceAll('{value}', _formatBytes(_fileSizeBytes)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appLocalizations.translate(_isCacheStale ? 'search.metaStale' : 'search.metaFresh'),
                    ),
                    if (_data != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        appLocalizations
                            .translate('search.metaCardsLoaded')
                            .replaceAll('{count}', _data!.length.toString()),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _loadingData ? null : () => _checkAndLoad(forceDownload: true),
                      icon: const Icon(Icons.download),
                      label: Text(appLocalizations.translate('search.downloadAction')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_status == 'checking') ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(appLocalizations.translate('search.statusChecking')),
            ] else if (_status == 'downloading') ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(
                appLocalizations.translate('search.statusDownloading').replaceAll(
                  '{progress}',
                  (100 * _progress).toStringAsFixed(0),
                ),
              ),
            ] else if (_status == 'loading_local') ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(appLocalizations.translate('search.statusLoadingLocal')),
            ] else if (_status == 'error') ...[
              Icon(Icons.error, color: theme.colorScheme.error),
              const SizedBox(height: 8),
              Text(_errorDetails ?? appLocalizations.translate('search.statusError')),
            ] else if (_status == 'empty') ...[
              const SizedBox(height: 8),
              Text(appLocalizations.translate('search.statusEmpty')),
            ],

            TextField(
              controller: _controller,
              enabled: _data != null,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('search.placeholder'),
                helperText: appLocalizations.translate('search.syntaxExamples'),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results == null
                  ? Center(
                      child: _loadingData
                    ? Text(appLocalizations.translate('search.statusPreparing'))
                          : Text(appLocalizations.translate('search.hint')),
                    )
                  : ListView.builder(
                      itemCount: _results!.length,
                      itemBuilder: (context, index) {
                        final item = _results![index] as Map<String, dynamic>;
                        return ListTile(
                          title: Text(item['name'] ?? ''),
                          subtitle: Text(item['set_name'] ?? ''),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
