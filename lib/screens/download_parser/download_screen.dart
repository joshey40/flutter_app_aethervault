import 'package:flutter/material.dart';

import '../../services/localization_service.dart';
import '../../services/card_database/scryfall_download.dart';
import 'parser_screen.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
    required this.forcedDownload
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale locale;
  final Future<void> Function(Locale locale) onLocaleChanged;
  final bool forcedDownload;

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final _downloadService = ScryfallDownloadService();
  bool _isRunning = false;
  bool _isFinished = false;
  String? _error;
  DownloadProgress? _progress;

  @override
  void initState() {
    super.initState();
    _downloadService.progressStream.listen((progress) {
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _isRunning = progress.isRunning;
      });
    });
    _startDownload();
  }

  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _error = null;
      _isFinished = false;
    });

    try {
      await _downloadService.downloadAllBulkData(widget.forcedDownload);
      if (!mounted) return;
      setState(() {
        _isFinished = true;
        _isRunning = false;
      });
      _openParser();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isRunning = false;
      });
    }
  }

  /// Navigate to the ParserScreen after the download is complete.
  void _openParser() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ParserScreen(
          themeMode: widget.themeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
          locale: widget.locale,
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download_rounded, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _isFinished
                        ? appLocalizations.translate('download.complete')
                        : appLocalizations.translate('download.loading'),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error != null
                        ? '${appLocalizations.translate('download.failed')}\n$_error'
                        : _progress?.currentType != null
                            ? '${appLocalizations.translate('download.current')}${_progress!.currentType}'
                            : appLocalizations.translate('download.waiting'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_progress != null && _progress!.bytesTotal != null && _progress!.bytesTotal! > 0)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: (_progress!.bytesDownloaded ?? 0) / _progress!.bytesTotal!,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatBytes(_progress!.bytesDownloaded ?? 0)} / ${_formatBytes(_progress!.bytesTotal!)}',
                        ),
                      ],
                    )
                  else if (_isRunning)
                    const LinearProgressIndicator(),
                  const SizedBox(height: 24),
                  if (_error != null)
                    ElevatedButton.icon(
                      onPressed: _startDownload,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(appLocalizations.translate('download.retry')),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
