import 'package:flutter/material.dart';

import '../../services/localization_service.dart';
import '../../services/card_database/scryfall_data_parser.dart';
import '../home/home_shell.dart';

class ParserScreen extends StatefulWidget {
  const ParserScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale locale;
  final Future<void> Function(Locale locale) onLocaleChanged;

  @override
  State<ParserScreen> createState() => _ParserScreenState();
}

class _ParserScreenState extends State<ParserScreen> {
  final _parserService = ScryfallDataParser();
  bool _isRunning = false;
  bool _isFinished = false;
  String? _error;
  ParserProgress? _progress;

  @override
  void initState() {
    super.initState();
    _parserService.progressStream.listen((progress) {
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _isRunning = progress.isRunning;
      });
    });
    _startParsing();
  }

  @override
  void dispose() {
    _parserService.dispose();
    super.dispose();
  }

  Future<void> _startParsing() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _error = null;
      _isFinished = false;
    });

    try {
      await _parserService.parseAllCardData();
      if (!mounted) return;
      setState(() {
        _isFinished = true;
        _isRunning = false;
      });
      _openHome();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isRunning = false;
      });
    }
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeShell(
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
                  const Icon(Icons.storage_rounded, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _isFinished
                        ? appLocalizations.translate('parser.complete')
                        : appLocalizations.translate('parser.loading'),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error != null  
                        ? '${appLocalizations.translate('parser.failed')}\n$_error'
                        : _progress?.currentType != null
                            ? '${appLocalizations.translate('parser.current')}${_progress!.currentType}'
                            : appLocalizations.translate('parser.waiting'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_progress != null && _progress!.cardsParsed != null)
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          '${appLocalizations.translate('parser.progress')}${_progress!.cardsParsed ?? 0}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  else if (_isRunning)
                    const LinearProgressIndicator(),
                  const SizedBox(height: 24),
                  if (_error != null)
                    ElevatedButton(
                      onPressed: _startParsing,
                      child: Text(appLocalizations.translate('parser.retry')),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}